import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadService {

  final supabase = Supabase.instance.client;

  Future<bool> uploadMaterial({
    required File file,
    required String fileName,
    required String title,
    required String subject,
    required int semester,
    required String type,        // added
    required String uploadedBy,
  }) async {

    try {

      /// generate unique file path (prevents overwrite)
      final path =
          "materials/${DateTime.now().millisecondsSinceEpoch}_$fileName";

      /// upload file to storage
      await supabase.storage
          .from("materials")
          .upload(path, file, fileOptions: const FileOptions(upsert: true));

      final publicUrl =
          supabase.storage.from("materials").getPublicUrl(path);

      /// insert record into database
      await supabase.from("materials").insert({

        "title": title,
        "subject": subject,
        "semester": semester,
        "type": type,                // fixed
        "uploaded_by": uploadedBy,
        "file_url": publicUrl,
        "created_at": DateTime.now().toIso8601String()

      });

      return true;

    } catch (e) {

      print("Upload error: $e");
      return false;

    }
  }
}