// Enhanced GenerateStoriesService with Proper Authentication Handling
import 'dart:convert';
import 'dart:math';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../graphql/graphql_client.dart';
import '../graphql/queries/stories_query.dart';

class GenerateStoriesService {

  static Future<String?> generateArabicStory({
    required String topic,
    required String setting,
    required String goal,
    required String age,
    required String length,
    String? heroType,
    required String role,
  }) async {
    try {
      final GraphQLClient client = await GraphQLService.getClient();

      final QueryResult result = await client.mutate(
        MutationOptions(
          document: gql(generateStoryMutation),
          variables: {
            "topic": topic,
            "setting": setting,
            "goal": goal,
            "age": age,
            "length": length,
            "heroType": heroType ?? "ولد",
          },
        ),
      );

      // Handle authentication errors with proper retry function
      final QueryResult? handledResult = await GraphQLService.handleAuthErrors(
        result: result,
        role: role,
        retryRequest: () async {
          final client = await GraphQLService.getClient();
          return await client.mutate(
            MutationOptions(
              document: gql(generateStoryMutation),
              variables: {
                "topic": topic,
                "setting": setting,
                "goal": goal,
                "age": age,
                "length": length,
                "heroType": heroType ?? "ولد",
              },
            ),
          );
        },
      );

      if (handledResult == null) {
        print("Authentication failed and could not be refreshed");
        return null;
      }

      if (handledResult.hasException) {
        print("Generate story mutation failed: ${handledResult.exception}");
        return null;
      }

      final String? jobId = handledResult.data?["generateArabicStory"]?["jobId"];
      print("Story generation started with job ID: $jobId");
      return jobId;

    } catch (e) {
      print("Error in generateArabicStory: $e");
      return null;
    }
  }

  /// Get Story Job Status - Check the progress of story generation
  static Future<Map<String, dynamic>?> getStoryJobStatus({
    required String jobId,
    required String role,
  }) async {
    try {
      final GraphQLClient client = await GraphQLService.getClient();

      final QueryResult result = await client.query(
        QueryOptions(
          document: gql(getStoryJobStatusQuery),
          variables: {
            "jobId": jobId,
          },
          fetchPolicy: FetchPolicy.networkOnly, // Always fetch from network for real-time status
        ),
      );

      // Handle authentication errors with proper retry function
      final QueryResult? handledResult = await GraphQLService.handleAuthErrors(
        result: result,
        role: role,
        retryRequest: () async {
          final client = await GraphQLService.getClient();
          return await client.query(
            QueryOptions(
              document: gql(getStoryJobStatusQuery),
              variables: {
                "jobId": jobId,
              },
              fetchPolicy: FetchPolicy.networkOnly,
            ),
          );
        },
      );

      if (handledResult == null) {
        print("Authentication failed and could not be refreshed");
        return null;
      }

      if (handledResult.hasException) {
        print("Get story status query failed: ${handledResult.exception}");
        return null;
      }

      final storyJobData = handledResult.data?["getStoryJobStatus"];

      if (storyJobData != null) {
        String? rawStory = storyJobData["story"];
        String? cleanedStory;

        // Clean and format the story if it exists
        if (rawStory != null && rawStory.isNotEmpty) {
          cleanedStory = _cleanAndFormatArabicText(rawStory);
        }

        return {
          "story": cleanedStory,
          "status": storyJobData["status"], // e.g., "pending", "completed", "failed"
          "error": storyJobData["error"],
        };
      }

      return null;

    } catch (e) {
      print("Error in getStoryJobStatus: $e");
      return null;
    }
  }

  /// Poll for story completion - Helper method to continuously check status
  static Future<Map<String, dynamic>?> pollForStoryCompletion({
    required String jobId,
    required String role,
    int maxAttempts = 30, // Maximum number of polling attempts
    Duration pollInterval = const Duration(seconds: 2), // Polling interval
  }) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final statusResult = await getStoryJobStatus(
          jobId: jobId,
          role: role,
        );

        if (statusResult == null) {
          attempts++;
          await Future.delayed(pollInterval);
          continue;
        }

        final String status = statusResult["status"] ?? "";

        switch (status) {
          case "completed":
            print("Story generation completed successfully!");
            return statusResult;

          case "failed":
            print("Story generation failed: ${statusResult["error"]}");
            return statusResult;

          case "pending":
          case "processing":
            print("Story generation in progress... (attempt $attempts/$maxAttempts)");
            attempts++;
            await Future.delayed(pollInterval);
            break;

          default:
            print("Unknown status: $status");
            attempts++;
            await Future.delayed(pollInterval);
            break;
        }

      } catch (e) {
        print("Error during polling attempt $attempts: $e");
        attempts++;
        await Future.delayed(pollInterval);
      }
    }

    print("Story generation polling timed out after $maxAttempts attempts");
    return {
      "story": null,
      "status": "timeout",
      "error": "Story generation timed out after ${maxAttempts * pollInterval.inSeconds} seconds"
    };
  }

  /// Complete story generation workflow - Generate and wait for completion
  static Future<Map<String, dynamic>?> generateStoryComplete({
    required String topic,
    required String setting,
    required String goal,
    required String age,
    required String length,
    String? heroType,
    required String role,
  }) async {
    try {
      // Step 1: Start story generation
      final String? jobId = await generateArabicStory(
        topic: topic,
        setting: setting,
        goal: goal,
        age: age,
        length: length,
        heroType: heroType,
        role: role,
      );

      if (jobId == null) {
        return {
          "story": null,
          "status": "failed",
          "error": "Failed to start story generation"
        };
      }

      // Step 2: Poll for completion
      final result = await pollForStoryCompletion(
        jobId: jobId,
        role: role,
      );

      return result;

    } catch (e) {
      print("Error in generateStoryComplete: $e");
      return {
        "story": null,
        "status": "failed",
        "error": "Unexpected error: $e"
      };
    }
  }

  /// Get story by progress with proper auth handling
  static Future<Map<String, dynamic>?> getStoryByProgress({
    required String learnerId,
    required String role,
  }) async {
    try {
      final GraphQLClient client = await GraphQLService.getClient();

      final QueryResult result = await client.query(
        QueryOptions(
          document: gql(getStoryByProgressQuery),
          variables: {
            "learnerId": learnerId,
          },
        ),
      );

      // Handle authentication errors with proper retry function
      final QueryResult? handledResult = await GraphQLService.handleAuthErrors(
        result: result,
        role: role,
        retryRequest: () async {
          final client = await GraphQLService.getClient();
          return await client.query(
            QueryOptions(
              document: gql(getStoryByProgressQuery),
              variables: {
                "learnerId": learnerId,
              },
            ),
          );
        },
      );

      if (handledResult == null) {
        print("Authentication failed and could not be refreshed");
        return null;
      }

      if (handledResult.hasException) {
        print("Get story by progress query failed: ${handledResult.exception}");
        return null;
      }

      final storyData = handledResult.data?["getStoryByProgress"];
      return storyData;

    } catch (e) {
      print("Error in getStoryByProgress: $e");
      return null;
    }
  }

  // Improved Arabic text cleaning function
  static String _cleanAndFormatArabicText(String input) {
    // Remove unwanted characters while preserving Arabic text and basic punctuation
    final arabicPattern = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\s\.,!?؟،؛:"()«»\-\n\r]+');

    // Extract only Arabic content
    final matches = arabicPattern.allMatches(input);
    String result = matches.map((match) => match.group(0)).join(' ');

    // Clean and format the text
    result = result
        .replaceAll(RegExp(r'\s+'), ' ') // Remove extra spaces
        .replaceAll(RegExp(r'^\s+|\s+$'), '') // Trim
        .replaceAll('،،', '،') // Fix double commas
        .replaceAll('..', '.') // Fix double periods
        .replaceAll('؟؟', '؟') // Fix double question marks
        .replaceAll('!!', '!') // Fix double exclamations
        .replaceAll(RegExp(r'\s+([،؛:.!؟])'), r'$1') // Fix spacing before punctuation
        .replaceAll(RegExp(r'([،؛:.!؟])([^\s])'), r'$1 $2') // Add space after punctuation
        .replaceAll(RegExp(r'[\$\d#]+'), '') // Remove any stray numbers, dollar signs, hashtags
        .replaceAll(RegExp(r'[a-zA-Z]+'), '') // Remove any English letters
        .replaceAll(RegExp(r'\s+'), ' ') // Clean up spaces again
        .trim();

    // Ensure the story ends with proper punctuation
    if (result.isNotEmpty && !result.endsWith('.') && !result.endsWith('!') && !result.endsWith('؟')) {
      result += '.';
    }

    return result;
  }
}