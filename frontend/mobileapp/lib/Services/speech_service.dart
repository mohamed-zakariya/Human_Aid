import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/graphql_client.dart';
import 'package:mobileapp/graphql/queries/speech_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpeechService {
  /// 1) Upload the audio via REST (with JWT in headers)
  static Future<String?> _uploadAudioFile(String audioFilePath) async {
    // Retrieve the token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("accessToken");

    final uri = Uri.parse('http://10.0.2.2:5500/upload-audio');
    
    // Create a MultipartRequest
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath(
        'audio', // must match `upload.single('audio')` in Node
        audioFilePath,
      ));
    
    // Add the Authorization header if the token exists
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    // Send the request
    var streamedResponse = await request.send();
    var responseString = await streamedResponse.stream.bytesToString();
    
    if (streamedResponse.statusCode == 200) {
      // Parse JSON response and return the fileUrl
      final Map<String, dynamic> jsonResponse = json.decode(responseString);
      return jsonResponse['fileUrl']; // e.g., "http://localhost:5500/uploads/filename..."
    } else {
      print('Failed to upload audio. Status code: ${streamedResponse.statusCode}');
      print('Response: $responseString');
      return null;
    }
  }

  /// 2) Use the returned `fileUrl` to call the GraphQL mutation
  static Future<Map<String, dynamic>?> processSpeech({
    required String userId,
    required String exerciseId,
    required String wordId,
    required String audioFilePath,
  }) async {
    try {
      // Step A: Upload the audio file to the Node.js server via REST
      String? fileUrl = await _uploadAudioFile(audioFilePath);
      if (fileUrl == null) {
        throw Exception('Audio upload failed – no fileUrl received');
      }

      // Step B: Call the GraphQL mutation with the fileUrl
      final client = await GraphQLService.getClient();
      final MutationOptions options = MutationOptions(
        document: gql(processSpeechMutation),
        variables: {
          'userId': userId,
          'exerciseId': exerciseId,
          'wordId': wordId,
          // IMPORTANT: pass the fileUrl here (not raw file bytes)
          'audioFile': fileUrl,
        },
      );

      final result = await client.mutate(options);
      if (result.hasException) {
        print("GraphQL Exception: ${result.exception}");
        return null;
      }

      return result.data?['wordsExercise'];
    } catch (e) {
      print("Error processing speech: $e");
      return null;
    }
  }
}
