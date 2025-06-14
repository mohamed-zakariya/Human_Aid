import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../graphql/graphql_client.dart';
import '../graphql/queries/sentence_exercise_queries.dart';
import '../models/scentence.dart';

/// Handles GraphQL calls for the sentence-pronunciation workflow.
///
/// 1. startExercise / endExercise
/// 2. fetchSentences (random 5)
/// 3. submitSentence → uploads + transcription + mutation (using its own flow)
class SentenceExerciseService {
  static Future<void> startExercise(
      String userId, String exerciseId) async {
    final client = await GraphQLService.getClient();
    await client.mutate(
      MutationOptions(
        document: gql(startExerciseMutation),
        variables: {'userId': userId, 'exerciseId': exerciseId},
      ),
    );
  }

  static Future<void> endExercise(
      String userId, String exerciseId) async {
    final client = await GraphQLService.getClient();
    await client.mutate(
      MutationOptions(
        document: gql(endExerciseMutation),
        variables: {'userId': userId, 'exerciseId': exerciseId},
      ),
    );
  }

  static Future<List<Sentence>> fetchSentences(String level) async {
    final client = await GraphQLService.getClient();
    final result = await client.query(
      QueryOptions(
        document: gql(getSentencesQuery),
        variables: {'level': level},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final List<dynamic> raw = result.data?['getSentenceForExercise'] ?? [];
    return raw.map((e) => Sentence.fromJson(e)).toList();
  }

  /// (A) Uploads the audio file to `/upload-audio`.
  /// Returns the `fileUrl` on success, else null.
  static Future<String?> _uploadAudioFile(String audioFilePath) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    final uri = Uri.parse('https://human-aid-deployment.onrender.com/upload-audio');
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

    final uri = Uri.parse('https://human-aid-deployment.onrender.com/api/transcribe');
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

  /// (C) Calls the GraphQL `updateSentenceProgress` mutation with the result.
  /// This returns the GraphQL response data (or null on error).
  static Future<Map<String, dynamic>?> _callUpdateSentenceProgress({
    required String userId,
    required String exerciseId,
    required String sentenceId,
    required String levelId,
    required String fileUrl,
    required String spokenSentence,
    int? timeSpent,
  }) async {
    try {
      final client = await GraphQLService.getClient();
      final MutationOptions options = MutationOptions(
        document: gql(updateSentenceProgressMutation),
        variables: {
          'userId': userId,
          'exerciseId': exerciseId,
          'sentenceId': sentenceId,
          'levelId': levelId,
          'audioFile': fileUrl,
          'spokenSentence': spokenSentence,
          if (timeSpent != null) 'timeSpent': timeSpent,
        },
      );

      final result = await client.mutate(options);
      if (result.hasException) {
        print("GraphQL updateSentenceProgress exception: ${result.exception}");
        return null;
      }

      return result.data?['updateSentenceProgress'];
    } catch (e) {
      print("GraphQL error calling updateSentenceProgress: $e");
      return null;
    }
  }

  /// Upload, transcribe, and call the sentence-specific mutation.
  /// Always returns a map the UI can display—even when something fails.
  static Future<Map<String, dynamic>> submitSentence({
    required String userId,
    required String exerciseId,
    required String levelId,
    required Sentence sentence,
    required String recordingPath,
    int? timeSpent,
  }) async {
    try {
      // Step 1: Upload
      final fileUrl = await _uploadAudioFile(recordingPath);
      if (fileUrl == null) {
        return {
          'isCorrect': false,
          'message': 'فشل في رفع الملف الصوتي، حاول مجددًا.',
          'updatedData': null,
        };
      }

      // Step 2: Transcribe
      final transcript = await _transcribeAudio(fileUrl);
      if (transcript == null) {
        return {
          'isCorrect': false,
          'message': 'تعذّر تحويل الصوت إلى نص، حاول مجددًا.',
          'updatedData': null,
        };
      }

      // Step 3: Call updateSentenceProgress mutation
      final updatedData = await _callUpdateSentenceProgress(
        userId: userId,
        exerciseId: exerciseId,
        sentenceId: sentence.id,
        levelId: levelId,
        fileUrl: fileUrl,
        spokenSentence: transcript,
        timeSpent: timeSpent,
      );

      if (updatedData == null) {
        return {
          'isCorrect': false,
          'message': 'حدث خطأ أثناء معالجة البيانات، حاول مجددًا.',
          'updatedData': null,
        };
      }

      return {
        'isCorrect': updatedData['isCorrect'] ?? false,
        'message': updatedData['message'] ?? 'تم إرسال الإجابة',
        'transcript': transcript,
        'updatedData': updatedData,
      };
    } catch (e) {
      print("Error processing sentence: $e");
      return {
        'isCorrect': false,
        'message': 'حدث خطأ غير متوقع، حاول مجددًا.',
        'updatedData': null,
      };
    }
  }
}