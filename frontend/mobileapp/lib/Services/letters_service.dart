import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/graphql_client.dart';
import '../graphql/queries/letters_query.dart';
import '../models/letter.dart';

class LettersService {
  // ───────── PUBLIC (unchanged signatures) ─────────

  static Future<List<Letter>?> getLettersForLevel1() =>
      _fetchLettersWithAuthRetry();

  // Level-2 uses the same backend query for now
  static Future<List<Letter>?> getLettersForLevel2() =>
      _fetchLettersWithAuthRetry();

  /// Old screens called this helper; keep it.
  static Future<List<Letter>?> fetchLetters() =>
      _fetchLettersWithAuthRetry();

  // ───────── INTERNAL ─────────

  static Future<List<Letter>?> _fetchLettersWithAuthRetry() async {
    final client = await GraphQLService.getClient();

    Future<QueryResult> _query() =>
        client.query(QueryOptions(document: gql(getLettersForExercise)));

    // first shot
    final first = await _query();

    // auto-refresh if token expired
    final handled = await GraphQLService.handleAuthErrors(
      result: first,
      role: 'learner',
      retryRequest: _query,
    );

    if (handled == null || handled.hasException) {
      print('[LettersService] fetch failed: ${handled?.exception}');
      return null;
    }

    final raw = handled.data?['getLettersForExercise'] as List<dynamic>?;
    return raw?.map((j) => Letter.fromJson(j)).toList();
  }
}