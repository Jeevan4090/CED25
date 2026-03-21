import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cloudinary_service.dart';

class UploadService {
  final supabase = Supabase.instance.client;

  Future<bool> uploadMaterial({
    required File file,
    required String fileName,
    required String title,
    required String subject,
    required int semester,
    required String type,
    required String uploadedBy,
  }) async {
    try {
      // 1. Upload file to Cloudinary
      final result = await CloudinaryService.uploadFile(
        file,
        folder: 'materials',
      );

      // 2. Save metadata to Supabase materials table
      await supabase.from("materials").insert({
        "title": title,
        "subject": subject,
        "semester": semester,
        "type": type,
        "uploaded_by": uploadedBy,
        "file_url": result.secureUrl,
        "cloudinary_public_id": result.publicId,
        "created_at": DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print("Upload error: $e");
      return false;
    }
  }
}