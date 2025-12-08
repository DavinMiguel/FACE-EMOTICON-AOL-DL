import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AiService {
  Future<Map<String, dynamic>> analyzeImage(File image) async {
    var uri = Uri.parse("http://127.0.0.1:5000/predict");

    var request = http.MultipartRequest("POST", uri);
    request.files.add(await http.MultipartFile.fromPath("image", image.path));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    return jsonDecode(responseData);
  }
}
