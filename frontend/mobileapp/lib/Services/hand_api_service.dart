import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';

class HandApiService {
  final String level1Url = 'http://handapi.bea3ctfwbsb0gpg5.uaenorth.azurecontainer.io:8000/analyze/';
  final String level2Url = 'http://handapi.bea3ctfwbsb0gpg5.uaenorth.azurecontainer.io:8000/level2/';

  Future<String?> uploadImage(File imageFile, {bool isLevel2 = false}) async {
    try {
      final uri = Uri.parse(isLevel2 ? level2Url : level1Url);
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // ✅ Must be 'file' (confirmed)
          imageFile.path,
          filename: basename(imageFile.path),
          contentType: MediaType('image', 'jpeg'), // or 'png'
        ),
      );

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      print("🔁 Status: ${response.statusCode}");
      print("📥 Response: $respStr");

      if (response.statusCode == 200) {
        return respStr;
      } else {
        return 'Error: $respStr';
      }
    } catch (e) {
      return 'Exception: $e';
    }
  }
}
