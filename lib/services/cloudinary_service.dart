import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:typed_data';

class CloudinaryService {
  static const String cloudName = 'dtjlbbl1j';
  static const String uploadPreset = 'ced25jp';

  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/raw/upload';

  // ✅ MOBILE UPLOAD — streaming via Dio, handles large files
  static Future<Map<String, dynamic>> uploadFile(
    File file, {
    String? folder,
    void Function(int sent, int total)? onProgress,
  }) async {
    if (!file.existsSync()) {
      throw Exception('File not found at path: ${file.path}');
    }

    final formData = FormData.fromMap({
      'upload_preset': uploadPreset,
      if (folder != null) 'folder': folder,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    final response = await Dio().post(
      uploadUrl,
      data: formData,
      options: Options(
        sendTimeout: const Duration(minutes: 10),
        receiveTimeout: const Duration(minutes: 2),
      ),
      onSendProgress: onProgress,
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.data?['error']?['message'] ?? 'Upload failed',
      );
    }

    return Map<String, dynamic>.from(response.data);
  }

  // ✅ WEB UPLOAD — bytes (web has no file path)
  static Future<Map<String, dynamic>> uploadBytes(
    Uint8List bytes, {
    required String fileName,
    String? folder,
    void Function(int sent, int total)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'upload_preset': uploadPreset,
      if (folder != null) 'folder': folder,
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });

    final response = await Dio().post(
  uploadUrl,
  data: formData,
  options: Options(
    sendTimeout: const Duration(minutes: 10),
    receiveTimeout: const Duration(minutes: 2),
    validateStatus: (status) => true, // ← don't throw, let us inspect
  ),
  onSendProgress: onProgress,
);

print('Cloudinary response: ${response.statusCode} — ${response.data}');

if (response.statusCode != 200) {
  throw Exception(
    response.data?['error']?['message'] ?? 'Upload failed (${response.statusCode})',
  );
}

    return Map<String, dynamic>.from(response.data);
  }
}