import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadService {

  final supabase = Supabase.instance.client;

  Future<String?> uploadFile(File file, String fileName) async {

    try {

      final path = "materials/$fileName";

      await supabase.storage
          .from("materials")
          .upload(path, file);

      final publicUrl = supabase.storage
          .from("materials")
          .getPublicUrl(path);

      return publicUrl;

    } catch (e) {

      print("Upload error: $e");
      return null;

    }

  }
}