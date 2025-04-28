import 'package:graphql_flutter/graphql_flutter.dart';

import '../graphql/graphql_client.dart';
import '../graphql/queries/sentence_exercise_queries.dart';
import '../models/scentence.dart';
import 'speech_service.dart';

/// Handles GraphQL calls for the sentence-pronunciation workflow.
///
/// 1. startExercise / endExercise
/// 2. fetchSentences (random 5)
/// 3. submitSentence → uploads + transcription + mutation
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

  /// Upload, transcribe, compare, mutate. Always returns a map the UI can
  /// display—even when something fails.
  static Future<Map<String, dynamic>> submitSentence({
    required String userId,
    required String exerciseId,
    required Sentence sentence,
    required String recordingPath,
  }) async {
    final res = await SpeechService.processSpeech(
      userId: userId,
      exerciseId: exerciseId,
      wordId: sentence.id,   // treat sentence id like word id
      correctWord: sentence.text,
      audioFilePath: recordingPath,
    );

    return res ??
        {
          'isCorrect': false,
          'message': 'تعذّر تحويل الصوت إلى نص، حاول مجددًا.',
          'updatedData': null,
        };
  }
}
