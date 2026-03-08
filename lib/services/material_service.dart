import 'package:supabase_flutter/supabase_flutter.dart';

class MaterialService {

  final supabase = Supabase.instance.client;

  Future<void> insertMaterial({
    required int semester,
    required String subject,
    required String title,
    required String type,
    required String fileUrl,
  }) async {

    await supabase.from('materials').insert({
      "semester": semester,
      "subject": subject,
      "title": title,
      "type": type,
      "file_url": fileUrl,
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
}