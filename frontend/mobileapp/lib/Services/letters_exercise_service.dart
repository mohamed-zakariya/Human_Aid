import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../graphql/graphql_client.dart';
import '../graphql/queries/letters_excercise_query.dart';
import '../services/letters_service.dart';
import '../models/letter.dart';
import 'arabic_letter_mapping_service.dart'; // Add this import

/// Handles GraphQL calls for the letter-pronunciation workflow.
///
/// 1. startExercise / endExercise
/// 2. fetchLetters 
/// 3. submitLetter → uploads + transcription + mutation (using its own flow)
class LetterExerciseService {
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

  static Future<List<Letter>> fetchLetters() async {
    // Use the existing LettersService instead of duplicating the logic
    final letters = await LettersService.fetchLetters();
    return letters ?? [];
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

  /// (C) Calls the GraphQL `updateLetterProgress` mutation with the result.
  /// This returns the GraphQL response data (or null on error).
  static Future<Map<String, dynamic>?> _callUpdateLetterProgress({
    String? userId,
    required String exerciseId,
    required String letterId,
    required String levelId,
    String? fileUrl,
    String? spokenLetter,
    required bool isCorrect, // Add this parameter
  }) async {
    try {
      final client = await GraphQLService.getClient();
      final MutationOptions options = MutationOptions(
        document: gql(updateLetterProgressMutation),
        variables: {
          'userId': userId,
          'exerciseId': exerciseId,
          'letterId': letterId,
          'levelId': levelId,
          if (fileUrl != null) 'audioFile': fileUrl,
          'spokenLetter': spokenLetter,
          'isCorrect': isCorrect, // Include the local validation result
        },
      );

      final result = await client.mutate(options);
      if (result.hasException) {
        print("GraphQL updateLetterProgress exception: ${result.exception}");
        return null;
      }

      return result.data?['updateLetterProgress'];
    } catch (e) {
      print("GraphQL error calling updateLetterProgress: $e");
      return null;
    }
  }

  /// Upload, transcribe, and call the letter-specific mutation.
  /// Always returns a map the UI can display—even when something fails.
  static Future<Map<String, dynamic>> submitLetter({
    String? userId,
    required String exerciseId,
    required String levelId,
    required Letter letter,
    String? recordingPath, // <-- make optional
    String? spokenLetter, // <-- make optional
  }) async {
    try {
      String? fileUrl;
      String? transcript;

      // Step 1: Upload if path provided
      if (recordingPath != null && recordingPath.isNotEmpty) {
        fileUrl = await _uploadAudioFile(recordingPath);
        if (fileUrl == null) {
          return {
            'isCorrect': false,
            'message': 'فشل في رفع الملف الصوتي، حاول مجددًا.',
            'transcript': null,
            'updatedData': null,
          };
        }

        // Step 2: Transcribe
        transcript = await _transcribeAudio(fileUrl);
        if (transcript == null) {
          return {
            'isCorrect': false,
            'message': 'تعذّر تحويل الصوت إلى نص، حاول مجددًا.',
            'transcript': null,
            'updatedData': null,
          };
        }
      } else {
        // If no audio provided, fallback to empty transcript or a default value
        transcript = ''; // You could make this a required argument too
      }

      // Step 3: LOCAL VALIDATION using our mapping
      final String rawSpokenText = (transcript != null && transcript.isNotEmpty)
          ? transcript
          : (spokenLetter ?? '');

      // Use our mapping to check if the pronunciation is correct
      final bool isLocallyCorrect = ArabicLetterMapping.isCorrectPronunciation(
        letter.letter,
        rawSpokenText,
      );

      // Step 4: NORMALIZE the spoken text back to letter character
      // This is what we'll send to the mutation
      String normalizedSpokenLetter;
      if (isLocallyCorrect) {
        // If correct, send the expected letter
        normalizedSpokenLetter = letter.letter;
      } else {
        // If incorrect, try to normalize what they said to a letter
        // If no match found, send the original transcript
        normalizedSpokenLetter = ArabicLetterMapping.normalizeSpokenTextToLetter(rawSpokenText) ?? rawSpokenText;
      }

      print('Expected letter: ${letter.letter}');
      print('Raw spoken text: $rawSpokenText');
      print('Normalized spoken letter: $normalizedSpokenLetter');
      print('Is locally correct: $isLocallyCorrect');

      // Step 5: Call updateLetterProgress mutation with normalized letter
      final updatedData = await _callUpdateLetterProgress(
        userId: userId,
        exerciseId: exerciseId,
        letterId: letter.id,
        levelId: levelId,
        fileUrl: fileUrl, // nullable
        spokenLetter: normalizedSpokenLetter, // Send normalized letter, not raw transcript
        isCorrect: isLocallyCorrect,
      );

      // Generate appropriate feedback messages
      String feedbackMessage;
      if (isLocallyCorrect) {
        feedbackMessage = 'ممتاز! لقد نطقت الحرف بشكل صحيح.';
      } else if (rawSpokenText.isEmpty) {
        feedbackMessage = 'لم نتمكن من سماع صوتك، حاول مرة أخرى.';
      } else {
        final expectedName = ArabicLetterMapping.getLetterName(letter.letter);
        feedbackMessage = 'قلت "$rawSpokenText" ولكن الحرف المطلوب هو "$expectedName". حاول مرة أخرى.';
      }

      return {
        'isCorrect': isLocallyCorrect,
        'message': feedbackMessage,
        'transcript': rawSpokenText, // Keep original transcript for UI display
        'normalizedLetter': normalizedSpokenLetter, // Add this for reference
        'expectedName': ArabicLetterMapping.getLetterName(letter.letter),
        'updatedData': updatedData,
      };
    } catch (e) {
      print("Error processing letter: $e");
      return {
        'isCorrect': false,
        'message': 'حدث خطأ غير متوقع، حاول مجددًا.',
        'transcript': null,
        'updatedData': null,
      };
    }
  }
}