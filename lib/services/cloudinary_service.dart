import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = 'dtjlbbl1j'; // replace this
  static const String _uploadPreset = 'ced25jp';

  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/raw/upload';

  static Future<CloudinaryUploadResult> uploadFile(
    File file, {
    String? folder,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));

      request.fields['upload_preset'] = _uploadPreset;
      request.fields['resource_type'] = 'raw';
      if (folder != null) request.fields['folder'] = folder;

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
      ));

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);

      if (response.statusCode != 200) {
        throw CloudinaryException(
          json['error']?['message'] ??
              'Upload failed with status ${response.statusCode}',
        );
      }

      return CloudinaryUploadResult.fromJson(json);
    } on CloudinaryException {
      rethrow;
    } catch (e) {
      throw CloudinaryException('Unexpected error: $e');
    }
  }
}

class CloudinaryUploadResult {
  final String publicId;
  final String secureUrl;
  final int bytes;

  const CloudinaryUploadResult({
    required this.publicId,
    required this.secureUrl,
    required this.bytes,
  });

  factory CloudinaryUploadResult.fromJson(Map<String, dynamic> json) {
    return CloudinaryUploadResult(
      publicId: json['public_id'] as String,
      secureUrl: json['secure_url'] as String,
      bytes: json['bytes'] as int,
    );
  }
}

class CloudinaryException implements Exception {
  final String message;
  const CloudinaryException(this.message);

  @override
  String toString() => 'CloudinaryException: $message';
}