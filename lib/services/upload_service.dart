import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cloudinary_service.dart';

class UploadService {
  final supabase = Supabase.instance.client;

  static const int _cloudinaryMaxBytes = 10 * 1024 * 1024; // 10 MB
  static const String _supabaseBucket = 'materials';       // your bucket name

  Future<bool> uploadMaterial({
    Uint8List? fileBytes,
    String? filePath,
    required String fileName,
    required String title,
    required String subject,
    required int semester,
    required String type,
    required String uploadedBy,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      // ── 1. Determine file size ──────────────────────────────────────────
      final int fileSize;
      if (kIsWeb) {
        if (fileBytes == null) throw Exception('No file bytes provided');
        fileSize = fileBytes.length;
      } else {
        if (filePath == null) throw Exception('No file path provided');
        fileSize = File(filePath).lengthSync();
      }

      // ── 2. Route: Cloudinary (≤10 MB) or Supabase (>10 MB) ─────────────
      final String fileUrl;
      final String? cloudinaryPublicId;
      final String storageProvider;

      if (fileSize <= _cloudinaryMaxBytes) {
        // ── Cloudinary upload ─────────────────────────────────────────────
        storageProvider = 'cloudinary';
        Map<String, dynamic> result;

        if (kIsWeb) {
          result = await CloudinaryService.uploadBytes(
            fileBytes!,
            fileName: fileName,
            folder: 'materials',
            onProgress: onProgress,
          );
        } else {
          result = await CloudinaryService.uploadFile(
            File(filePath!),
            folder: 'materials',
            onProgress: onProgress,
          );
        }

        fileUrl = result['secure_url'];
        cloudinaryPublicId = result['public_id'];
      } else {
        // ── Supabase Storage upload (large files) ─────────────────────────
        storageProvider = 'supabase';
        cloudinaryPublicId = null;

        final sanitizedName = fileName.replaceAll(RegExp(r'[^\w\.\-]'), '_');
        final storagePath = 'uploads/${DateTime.now().millisecondsSinceEpoch}_$sanitizedName';
        final Uint8List bytes;

        if (kIsWeb) {
          bytes = fileBytes!;
        } else {
          bytes = await File(filePath!).readAsBytes();
        }

        // Manual progress simulation for Supabase (no native progress callback)
        onProgress?.call(0, fileSize);

        await supabase.storage
            .from(_supabaseBucket)
            .uploadBinary(
              storagePath,
              bytes,
              fileOptions: const FileOptions(upsert: true),
            );

        onProgress?.call(fileSize, fileSize); // signal 100%

        fileUrl = supabase.storage
            .from(_supabaseBucket)
            .getPublicUrl(storagePath);
      }

      // ── 3. Save metadata to Supabase DB ────────────────────────────────
      final prefs = await SharedPreferences.getInstance();
      final accessCode = prefs.getString('access_code') ?? '';

      await supabase.from('materials').insert({
        'title': title,
        'subject': subject,
        'semester': semester,
        'type': type,
        'uploaded_by': uploadedBy,
        'file_url': fileUrl,
        'cloudinary_public_id': cloudinaryPublicId,
        'storage_provider': storageProvider,  // track where file lives
        'file_size': fileSize,
        'uploader_code': accessCode,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Upload error: $e');
      rethrow;
    }
  }
}