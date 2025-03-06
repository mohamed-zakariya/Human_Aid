import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/graphql_client.dart';
import 'package:mobileapp/graphql/queries/speech_query.dart';

class SpeechService {
  /// 1) Upload the audio via REST
  static Future<String?> _uploadAudioFile(String audioFilePath) async {
    final uri = Uri.parse('http://10.0.2.2:5500/upload-audio');
    
    // Create a MultipartRequest
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath(
        'audio', // must match `upload.single('audio')` in Node
        audioFilePath,
      ));

    // Send the request
    var streamedResponse = await request.send();
    var responseString = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      // Parse JSON
      final Map<String, dynamic> jsonResponse = json.decode(responseString);
      return jsonResponse['fileUrl']; // "http://localhost:5500/uploads/filename..."
    } else {
      // Error
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
      // Step A: First, upload the audio file to Node.js via REST
      String? fileUrl = await _uploadAudioFile(audioFilePath);
      if (fileUrl == null) {
        throw Exception('Audio upload failed – no fileUrl received');
      }

      // Step B: Then call GraphQL mutation with the fileUrl
      final client = await GraphQLService.getClient();
      final MutationOptions options = MutationOptions(
        document: gql(processSpeechMutation),
        variables: {
          'userId': userId,
          'exerciseId': exerciseId,
          'wordId': wordId,
          // IMPORTANT: pass the fileUrl here (not the raw file bytes)
          'audioFile': fileUrl,
        },
      );

      final result = await client.mutate(options);
      if (result.hasException) {
        print("GraphQL Exception: ${result.exception}");
        return null;
      }

      return result.data?['processSpeech'];
    } catch (e) {
      print("Error processing speech: $e");
      return null;
    }
  }
}
