import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class AIService {

  static const String apiUrl = "http://192.168.1.102:5000/predict";

  static Future<Map<String, dynamic>> analyzeImageBytes(
      PlatformFile file) async {
    var request = http.MultipartRequest("POST", Uri.parse(apiUrl));

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        file.bytes!,
        filename: file.name,
      ),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    return jsonDecode(responseBody);
  }
}
