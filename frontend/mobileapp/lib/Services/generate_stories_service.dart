import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../graphql/graphql_client.dart';
import '../graphql/queries/stories_query.dart';

class GenerateStoriesService {
  final Random _random = Random();

  // Creative Arabic names pools
  final List<String> _boyNames = [
    'أحمد', 'محمد', 'علي', 'حسن', 'يوسف', 'خالد', 'عمر', 'سعد', 'فهد', 'نايف',
    'راشد', 'سلطان', 'ماجد', 'طارق', 'زياد', 'كريم', 'أنس', 'عبدالله', 'فيصل', 'نواف'
  ];

  final List<String> _girlNames = [
    'فاطمة', 'عائشة', 'زينب', 'مريم', 'خديجة', 'هند', 'نورا', 'سارة', 'دانة', 'لينا',
    'رهف', 'جود', 'ريم', 'شهد', 'غلا', 'روان', 'لمى', 'هيا', 'تالا', 'جنى'
  ];

  final List<String> _animalNames = [
    'لؤلؤ', 'نجمة', 'شهاب', 'بدر', 'قمر', 'ورد', 'ياسمين', 'عسل', 'سكر', 'فراشة',
    'نسيم', 'غيمة', 'مطر', 'شمس', 'نور', 'ضوء', 'أمل', 'حلم', 'سعادة', 'فرح'
  ];

  /// Generate Arabic story with enhanced timeout handling
  /// Generate Arabic story with enhanced timeout handling
  Future<Map<String, dynamic>?> generateArabicStory({
    required String topic,
    required String setting,
    required String goal,
    required String age,
    required String length,
    String? heroType,
    String? secondaryValues,
  }) async {
    print("Starting story generation with parameters:");
    print("Topic: $topic, Setting: $setting, Goal: $goal, Age: $age, Length: $length");

    try {
      // Use the long-running client for story generation
      final client = await GraphQLService.getLongRunningClient();

      final prefs = await SharedPreferences.getInstance();
      String? refreshToken = prefs.getString("refreshToken");
      print("Using refresh token: ${refreshToken?.substring(0, 10)}...");

      // Configure mutation with proper settings
      final mutationOptions = MutationOptions(
        document: gql(generateStoryMutation),
        variables: {
          "topic": topic,
          "setting": setting,
          "goal": goal,
          "age": age,
          "length": length,
          "heroType": heroType,
        },
        fetchPolicy: FetchPolicy.networkOnly,
        errorPolicy: ErrorPolicy.all,
      );

      print("Executing story generation mutation with progressive timeout...");

      // Execute mutation with progressive timeout strategy
      QueryResult result;
      try {
        result = await GraphQLService.executeWithProgressiveTimeout(
          client: client,
          options: mutationOptions,
          timeoutStages: [
            const Duration(seconds: 60),   // First try: 1 minute
            const Duration(minutes: 5),    // Second try: 5 minutes
            const Duration(minutes: 10),   // Third try: 10 minutes
            const Duration(minutes: 15),   // Final try: 15 minutes
          ],
        );
      } on TimeoutException catch (e) {
        print("All timeout attempts failed: ${e.message}");
        throw Exception("انتهت مهلة إنشاء القصة. الخدمة مشغولة جداً، يرجى المحاولة لاحقاً.");
      } catch (e) {
        print("Network error during story generation: $e");
        _handleNetworkError(e);
        // This line will never be reached due to _handleNetworkError throwing,
        // but we need to satisfy the compiler
        rethrow;
      }

      print("Story generation mutation completed, checking for auth errors...");

      // Handle authentication errors with retry
      QueryResult? finalResult = await GraphQLService.handleAuthErrors(
        result: result,
        role: "learner",
        retryRequest: () async {
          print("Retrying story generation after token refresh...");
          final retryClient = await GraphQLService.getLongRunningClient();
          try {
            return await GraphQLService.executeWithProgressiveTimeout(
              client: retryClient,
              options: mutationOptions,
              timeoutStages: [
                const Duration(minutes: 5),   // Shorter retry timeouts
                const Duration(minutes: 10),
              ],
            );
          } on TimeoutException catch (e) {
            print("Retry timeout: ${e.message}");
            throw Exception("انتهت مهلة إعادة محاولة إنشاء القصة.");
          }
        },
      );

      // Process the result
      if (finalResult == null) {
        print("Final result is null - authentication failed");
        throw Exception("فشل في المصادقة. يرجى تسجيل الدخول مرة أخرى.");
      }

      if (finalResult.hasException) {
        final exceptionStr = finalResult.exception.toString().toLowerCase();

        if (exceptionStr.contains('timeout')) {
          print("Timeout after auth handling: $exceptionStr");
          throw Exception("انتهت مهلة إنشاء القصة. يرجى المحاولة مرة أخرى لاحقاً.");
        }

        print("Story generation failed with exception: ${finalResult.exception}");
        _handleGraphQLException(finalResult.exception!);
      }


      final dynamic storyData = finalResult.data?["generateArabicStory"];

      if (storyData == null) {
        print("No story data returned from server");
        throw Exception("فشل في توليد القصة: لم يتم إرجاع بيانات من الخادم");
      }

      print("Story generated successfully!");
      print("Story data type: ${storyData.runtimeType}");


      return _processStoryData(storyData, heroType);

    } catch (e) {
      print("Story generation failed: $e");
      rethrow;
    }
  }

  /// Handle network errors with specific error messages
  void _handleNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('timeout')) {
      throw Exception("انتهت مهلة الطلب. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.");
    } else if (errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('connection')) {
      throw Exception("مشكلة في الاتصال بالشبكة. يرجى التحقق من اتصال الإنترنت.");
    } else if (errorString.contains('server') || errorString.contains('500')) {
      throw Exception("خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً.");
    }

    throw Exception("خطأ في الشبكة أثناء إنشاء القصة: $error");
  }

  /// Handle GraphQL specific exceptions
  void _handleGraphQLException(OperationException exception) {
    final exceptionStr = exception.toString().toLowerCase();

    if (exceptionStr.contains('timeout')) {
      throw Exception("انتهت مهلة إنشاء القصة. يرجى المحاولة مرة أخرى لاحقاً.");
    }

    if (exceptionStr.contains('network') ||
        exceptionStr.contains('socket') ||
        exceptionStr.contains('connection') ||
        exceptionStr.contains('no internet')) {
      throw Exception("مشكلة في الاتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى.");
    }

    if (exceptionStr.contains('server') || exceptionStr.contains('500')) {
      throw Exception("خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً.");
    }

    // Check for specific GraphQL errors
    if (exception.graphqlErrors.isNotEmpty) {
      final graphqlError = exception.graphqlErrors.first;
      print("GraphQL Error: ${graphqlError.message}");

      if (graphqlError.message.toLowerCase().contains('rate limit')) {
        throw Exception("تم تجاوز الحد المسموح من الطلبات. يرجى الانتظار قليلاً والمحاولة مرة أخرى.");
      }

      if (graphqlError.message.toLowerCase().contains('server overload')) {
        throw Exception("الخادم مشغول حالياً. يرجى المحاولة مرة أخرى لاحقاً.");
      }
    }

    throw Exception("فشل في توليد القصة: $exception");
  }

  /// Process story data from server response
  Map<String, dynamic> _processStoryData(dynamic storyData, String? heroType) {
    if (storyData is String) {
      // If the response is a string, wrap it in a map
      return {
        'story': _cleanAndFormatArabicText(storyData),
        'title': 'قصة جديدة',
        'characters': _generateCharacterNames(heroType).values.toList(),
        'moral': _extractMoralFromStory(storyData),
      };
    } else if (storyData is Map<String, dynamic>) {
      // If it's already a map, clean the story text and return
      if (storyData['story'] is String) {
        storyData['story'] = _cleanAndFormatArabicText(storyData['story']);
      }
      return storyData;
    } else {
      print("Unexpected story data type: ${storyData.runtimeType}");
      print("Story data content: $storyData");
      throw Exception("فشل في توليد القصة: نوع البيانات غير متوقع");
    }
  }

  /// Generate story with exponential backoff retry mechanism
  Future<Map<String, dynamic>?> generateArabicStoryWithRetry({
    required String topic,
    required String setting,
    required String goal,
    required String age,
    required String length,
    String? heroType,
    String? secondaryValues,
    int maxRetries = 2,
  }) async {
    int attempt = 0;
    Exception? lastException;

    // Base delay in seconds
    const baseDelay = 15; // Increased base delay

    while (attempt < maxRetries) {
      attempt++;
      print("Story generation attempt $attempt/$maxRetries");

      try {
        final result = await generateArabicStory(
          topic: topic,
          setting: setting,
          goal: goal,
          age: age,
          length: length,
          heroType: heroType,
          secondaryValues: secondaryValues,
        );

        return result;

      } catch (e) {
        lastException = e as Exception;
        print("Attempt $attempt failed: $e");

        // Don't retry certain types of errors
        if (_isNonRetryableError(e.toString())) {
          print("Non-retryable error - not retrying");
          break;
        }

        if (attempt < maxRetries) {
          // Exponential backoff: 15s, 30s
          int delaySeconds = baseDelay * (1 << (attempt - 1));
          print("Waiting $delaySeconds seconds before retry...");
          await Future.delayed(Duration(seconds: delaySeconds));
        }
      }
    }

    // All attempts failed
    _handleFinalError(lastException, maxRetries);
    return null; // This line won't be reached due to throw above
  }

  /// Check if error is non-retryable
  bool _isNonRetryableError(String errorString) {
    final lowerError = errorString.toLowerCase();
    return lowerError.contains('فشل في المصادقة') ||
        lowerError.contains('authentication') ||
        lowerError.contains('unauthorized') ||
        lowerError.contains('rate limit') ||
        lowerError.contains('تم تجاوز الحد');
  }

  /// Handle final error after all retries failed
  void _handleFinalError(Exception? lastException, int maxRetries) {
    final errorMsg = lastException?.toString() ?? "Unknown error";
    if (errorMsg.contains('timeout') || errorMsg.contains('انتهت مهلة')) {
      throw Exception("انتهت مهلة إنشاء القصة بعد $maxRetries محاولات. الخدمة قد تكون مشغولة جداً.");
    } else if (errorMsg.contains('network') || errorMsg.contains('اتصال')) {
      throw Exception("مشكلة في الاتصال بالإنترنت. يرجى التحقق من اتصالك.");
    } else {
      throw Exception("فشل في توليد القصة بعد $maxRetries محاولات: $errorMsg");
    }
  }

  /// Legacy method for backward compatibility
  Future<String> generateArabicStoryLegacy({
    required String topic,
    required String setting,
    required String goal,
    required String age,
    required String length,
    String? style,
    String? heroType,
  }) async {
    try {
      final result = await generateArabicStoryWithRetry(
        topic: topic,
        setting: setting,
        goal: goal,
        age: age,
        length: length,
        heroType: heroType,
      );

      return result?['story'] ?? 'فشل في توليد القصة';
    } catch (e) {
      print("Legacy story generation failed: $e");
      rethrow;
    }
  }

  // Utility methods for character generation
  Map<String, String> _generateCharacterNames(String? heroType) {
    final names = <String, String>{};

    switch (heroType) {
      case 'ولد':
        names['main'] = _boyNames[_random.nextInt(_boyNames.length)];
        names['friend'] = _boyNames[_random.nextInt(_boyNames.length)];
        break;
      case 'بنت':
        names['main'] = _girlNames[_random.nextInt(_girlNames.length)];
        names['friend'] = _girlNames[_random.nextInt(_girlNames.length)];
        break;
      case 'حيوان':
      case 'طائر':
        names['main'] = _animalNames[_random.nextInt(_animalNames.length)];
        names['friend'] = _animalNames[_random.nextInt(_animalNames.length)];
        break;
      case 'مجموعة':
        names['main'] = _boyNames[_random.nextInt(_boyNames.length)];
        names['friend'] = _girlNames[_random.nextInt(_girlNames.length)];
        names['third'] = _boyNames[_random.nextInt(_boyNames.length)];
        break;
      default:
        names['main'] = _boyNames[_random.nextInt(_boyNames.length)];
        names['friend'] = _girlNames[_random.nextInt(_girlNames.length)];
    }

    return names;
  }

  /// Extract moral/lesson from story text
  String _extractMoralFromStory(String story) {
    // Simple extraction based on common Arabic moral indicators
    final moralIndicators = [
      'تعلم', 'درس', 'حكمة', 'عبرة', 'فائدة', 'أهمية', 'قيمة'
    ];

    final sentences = story.split('.');
    for (final sentence in sentences.reversed) {
      for (final indicator in moralIndicators) {
        if (sentence.contains(indicator)) {
          return sentence.trim();
        }
      }
    }

    return 'قصة مفيدة ومليئة بالحكم';
  }

  /// Clean and format Arabic text
  String _cleanAndFormatArabicText(String input) {
    final arabicPattern = RegExp(
        r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\s\.,!?؟،؛:"()«»\-\n\r]+');

    final matches = arabicPattern.allMatches(input);
    String result = matches.map((match) => match.group(0)).join(' ');

    result = result
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^\s+|\s+$'), '')
        .replaceAll('،،', '،')
        .replaceAll('..', '.')
        .replaceAll('؟؟', '؟')
        .replaceAll('!!', '!')
        .replaceAll(RegExp(r'\s+([،؛:.!؟])'), r'$1')
        .replaceAll(RegExp(r'([،؛:.!؟])([^\s])'), r'$1 $2')
        .replaceAll(RegExp(r'[\$\d#]+'), '')
        .replaceAll(RegExp(r'[a-zA-Z]+'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (result.isNotEmpty &&
        !result.endsWith('.') &&
        !result.endsWith('!') &&
        !result.endsWith('؟')) {
      result += '.';
    }

    return result;
  }
}