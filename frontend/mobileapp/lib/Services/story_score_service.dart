import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../graphql/graphql_client.dart';
import '../graphql/queries/stories_query.dart';

class StoryDatabaseService {
  // Replace with your actual GraphQL endpoint
  final String _graphqlEndpoint = 'https://human-aid-deployment.onrender.com/graphql';

  // Summarization endpoint
  final String _summarizationEndpoint = 'http://summry.fbbtdmdjc3bucght.uaenorth.azurecontainer.io:8000/summarize';

  // Replace with your actual authorization token if needed

  /// Save a generated story to the database
  Future<Map<String, dynamic>?> saveStory({
    required String story,
    required String kind, // This will be the length (قصة قصيرة, قصة متوسطة, قصة طويلة)
    required String morale, // This will be the topic/moral lesson
  }) async {

    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString("accessToken");

    const String mutation = '''
      mutation CreateStory(\$story: String!, \$kind: String!, \$morale: String!) {
        createStory(story: \$story, kind: \$kind, morale: \$morale) {
          id
          story
          kind
          morale
        }
      }
    ''';

    final Map<String, dynamic> variables = {
      'story': story,
      'kind': kind,
      'morale': morale,
    };

    final Map<String, dynamic> requestBody = {
      'query': mutation,
      'variables': variables,
    };

    try {

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        if (accessToken != null && accessToken.isNotEmpty)
          'Authorization': 'Bearer $accessToken',
      };


      print('Saving story to database...');
      final response = await http.post(
        Uri.parse(_graphqlEndpoint),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));

        if (responseData.containsKey('errors')) {
          print('GraphQL errors: ${responseData['errors']}');
          throw Exception('GraphQL Error: ${responseData['errors'][0]['message']}');
        }

        if (responseData.containsKey('data') &&
            responseData['data'] != null &&
            responseData['data']['createStory'] != null) {

          final storyData = responseData['data']['createStory'];
          print('Story saved successfully with ID: ${storyData['id']}');
          return storyData;
        } else {
          throw Exception('فشل في حفظ القصة: لم يتم إرجاع بيانات صحيحة');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('فشل في حفظ القصة: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error saving story to database: $e');
      throw Exception('فشل في حفظ القصة في قاعدة البيانات: $e');
    }
  }

  /// Generate a summary from the story content
  String _generateSummary(String story) {
    // Simple summary generation - take first 150 characters or first sentence
    if (story.length <= 150) {
      return story.trim();
    }

    // Try to find the first sentence
    final sentences = story.split(RegExp(r'[.!?؟]'));
    if (sentences.isNotEmpty && sentences[0].length <= 150) {
      return sentences[0].trim() + '.';
    }

    // Fallback to first 150 characters
    return story.substring(0, 147).trim() + '...';
  }

  /// Convert Arabic length to database format
  String _convertLengthToKind(String length) {
    switch (length.toLowerCase()) {
      case 'قصة قصيرة':
        return 'قصة قصيرة';
      case 'قصة متوسطة':
        return 'قصة متوسطة';
      case 'قصة طويلة':
        return 'قصة طويلة';
      default:
        return length;
    }
  }

  /// Convert topic to morale format
  String _convertTopicToMorale(String topic) {
    // You can add more sophisticated mapping here
    switch (topic.toLowerCase()) {
      case 'الأمان':
        return 'أهمية الأمان والحذر';
      case 'الصداقة':
        return 'قيمة الصداقة الحقيقية';
      case 'النظافة':
        return 'أهمية النظافة الشخصية';
      case 'الأمانة':
        return 'فضيلة الأمانة والصدق';
      default:
        return 'تعلم $topic';
    }
  }

  /// Main method to save story with automatic processing
  Future<Map<String, dynamic>?> saveGeneratedStory({
    required String story,
    required String length, // Original length parameter
    required String topic,  // Original topic parameter
    String? customMorale,
  }) async {
    try {
      final String kind = _convertLengthToKind(length);

      final String morale = customMorale ?? _convertTopicToMorale(topic);

      return await saveStory(
        story: story,
        kind: kind,
        morale: morale,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get stories by progress for learner
  static Future<List<Map<String, dynamic>>?> getStoriesByProgress(String learnerId) async {
    final client = await GraphQLService.getClient();

    final result = await client.query(
      QueryOptions(
        document: gql(getStoryByProgressQuery),
        variables: {"learnerId": learnerId},
      ),
    );

    final handledResult = await GraphQLService.handleAuthErrors(
      result: result,
      role: "learner",
      retryRequest: () => client.query(
        QueryOptions(
          document: gql(getStoryByProgressQuery),
          variables: {"learnerId": learnerId},
        ),
      ),
    );

    if (handledResult == null || handledResult.hasException) {
      print("Error fetching stories: ${handledResult?.exception.toString()}");
      return null;
    }

    return (handledResult.data?['getStoryByProgress'] as List<dynamic>)
        .map((story) => story as Map<String, dynamic>)
        .toList();
  }

  /// Generate summary using external API
  Future<String?> generateStorySummary(String storyText) async {
    try {
      final Map<String, dynamic> requestBody = {
        'text': storyText,
        'top_k': 1,
      };

      print('Generating summary for story...');
      final response = await http.post(
        Uri.parse(_summarizationEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));

        // The API response structure may vary, adjust according to actual response
        if (responseData.containsKey('summary')) {
          return responseData['summary'];
        } else if (responseData.containsKey('summarized_text')) {
          return responseData['summarized_text'];
        } else {
          // If the response structure is different, return the whole response as string
          return responseData.toString();
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('فشل في توليد الملخص: ${response.statusCode}');
      }
    } catch (e) {
      print('Error generating summary: $e');
      throw Exception('فشل في توليد الملخص: $e');
    }
  }

  /// Generate summaries for multiple stories
  Future<List<String?>> generateMultipleStorySummaries(List<String> stories) async {
    List<String?> summaries = [];

    for (String story in stories) {
      try {
        String? summary = await generateStorySummary(story);
        summaries.add(summary);
      } catch (e) {
        print('Error generating summary for story: $e');
        summaries.add(null); // Add null for failed summaries
      }
    }

    return summaries;
  }

  /// Get random stories with their summaries for quiz
  Future<Map<String, dynamic>?> getRandomStoriesWithSummaries(String learnerId) async {
    try {
      // Get stories from progress
      List<Map<String, dynamic>>? stories = await getStoriesByProgress(learnerId);

      if (stories == null || stories.isEmpty) {
        throw Exception('لا توجد قصص متاحة');
      }

      // Shuffle and take up to 3 stories
      stories.shuffle();
      List<Map<String, dynamic>> selectedStories = stories.take(3).toList();

      // Extract story texts for summarization
      List<String> storyTexts = selectedStories.map((story) => story['story'] as String).toList();

      // Generate summaries
      List<String?> summaries = await generateMultipleStorySummaries(storyTexts);

      // Combine stories with their summaries
      List<Map<String, dynamic>> storiesWithSummaries = [];
      for (int i = 0; i < selectedStories.length; i++) {
        storiesWithSummaries.add({
          ...selectedStories[i],
          'generated_summary': summaries[i],
        });
      }

      print(storiesWithSummaries);

      return {
        'main_story': storiesWithSummaries[0], // First story as main story
        'all_stories': storiesWithSummaries,
        'summaries': summaries,
      };
    } catch (e) {
      print('Error getting random stories with summaries: $e');
      throw Exception('فشل في جلب القصص والملخصات: $e');
    }
  }
}