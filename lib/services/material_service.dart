import 'package:supabase_flutter/supabase_flutter.dart';

class MaterialService {

  final supabase = Supabase.instance.client;

  Future<void> insertMaterial({
    required int semester,
    required String subject,
    required String title,
    required String type,
    required String fileUrl,
    required String uploadedBy,
  }) async {

    await supabase.from('materials').insert({
      "semester": semester,
      "subject": subject,
      "title": title,
      "type": type,
      "file_url": fileUrl,
      "uploaded_by": uploadedBy,
    });

  }

  Future<List<Map<String, dynamic>>> fetchMaterials(
      int semester,
      String subject
  ) async {

    final response = await supabase
        .from('materials')
        .select()
        .eq('semester', semester)
        .eq('subject', subject)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);

  }

  /// DELETE MATERIAL (file + database row)
  Future<void> deleteMaterial(String id, String fileUrl) async {

    try {

      final uri = Uri.parse(fileUrl);

      final filePath =
          uri.pathSegments
              .sublist(uri.pathSegments.indexOf('materials') + 1)
              .join('/');

      /// delete file from storage
      await supabase.storage
          .from('materials')
          .remove([filePath]);

      /// delete database row
      await supabase
          .from('materials')
          .delete()
          .eq('id', id);

    } catch (e) {

      print("Delete material error: $e");

    }

  }

}