//speech_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:mobileapp/graphql/graphql_client.dart';
import 'package:mobileapp/graphql/queries/speech_query.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class SpeechService {
  /// (A) Uploads the audio file to `/upload-audio`.
  /// Returns the `fileUrl` on success, else null.
  static Future<String?> _uploadAudioFile(String audioFilePath) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    final uri = Uri.parse('http://10.0.2.2:5500/upload-audio');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('audio', audioFilePath));

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final streamedResponse = await request.send();
    final responseString = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(responseString);
      return jsonResponse['fileUrl']; 
    } else {
      print('Upload Error: ${streamedResponse.statusCode}');
      print('Upload Response: $responseString');
      return null;
    }
  }

  /// (B) Transcribes the uploaded audio by calling `/api/transcribe` 
  /// with JSON body `{ filePath: fileUrl }`. Returns the transcript or null.
  static Future<String?> _transcribeAudio(String fileUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    final uri = Uri.parse('http://10.0.2.2:5500/api/transcribe');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({'filePath': fileUrl}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse['transcript'] as String?;
    } else {
      print('Transcription Error: ${response.statusCode}');
      print('Transcription Body: ${response.body}');
      return null;
    }
  }

  /// (C) Calls the GraphQL `updateUserProgress` mutation with the final result.
  /// This returns the GraphQL response data (or null on error).
  static Future<Map<String, dynamic>?> _callUpdateUserProgress({
    required String userId,
    required String exerciseId,
    required String wordId,
    required String fileUrl,
    required String spokenWord,
  }) async {
    try {
      final client = await GraphQLService.getClient();
      final MutationOptions options = MutationOptions(
        document: gql(updateUserProgressMutation),
        variables: {
          'userId': userId,
          'exerciseId': exerciseId,
          'wordId': wordId,
          'audioFile': fileUrl,
          'spokenWord': spokenWord,
        },
      );

      final result = await client.mutate(options);
      if (result.hasException) {
        print("GraphQL updateUserProgress exception: ${result.exception}");
        return null;
      }

      return result.data?['updateUserProgress'];
    } catch (e) {
      print("GraphQL error calling updateUserProgress: $e");
      return null;
    }
  }

  /// (D) High-level function that ties everything together:
  ///     1. Upload audio
  ///     2. Transcribe
  ///     3. Compare with correctWord locally
  ///     4. (If desired) call updateUserProgress
  ///
  /// Returns a Map with: { 'isCorrect': bool, 'message': String } etc.
  static Future<Map<String, dynamic>?> processSpeech({
    required String userId,
    required String exerciseId,
    required String wordId,
    required String correctWord,
    required String audioFilePath,
  }) async {
    try {
      // Step 1: Upload
      final fileUrl = await _uploadAudioFile(audioFilePath);
      if (fileUrl == null) {
        throw Exception('Audio upload failed – no fileUrl received.');
      }

      // Step 2: Transcribe
      final transcript = await _transcribeAudio(fileUrl);
      if (transcript == null) {
        throw Exception('Transcription failed – no transcript received.');
      }

      // Step 3: Compare the transcript with correctWord
      final bool isCorrect = transcript.trim().toLowerCase() == correctWord.trim().toLowerCase();

      // Step 4: Call updateUserProgress mutation (optional)
      final updatedData = await _callUpdateUserProgress(
        userId: userId,
        exerciseId: exerciseId,
        wordId: wordId,
        fileUrl: fileUrl,
        spokenWord: transcript,
      );

      return {
        'isCorrect': isCorrect,
        'transcript': transcript,
        'message': isCorrect ? 'أحسنت!' : 'حاول مرة أخرى',
        'updatedData': updatedData,
      };
    } catch (e) {
      print("Error processing speech: $e");
      return null;
    }
  }
}
