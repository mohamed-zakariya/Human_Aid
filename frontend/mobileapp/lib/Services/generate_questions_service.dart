import 'dart:convert';
import 'package:http/http.dart' as http;

class Question {
  final String question;
  final List<String> choices;
  final int correctIndex;

  Question({
    required this.question,
    required this.choices,
    required this.correctIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      choices: List<String>.from(json['choices']),
      correctIndex: json['correctIndex'],
    );
  }
}

class GenerateQuestionsService {
  // List of API keys for fallback functionality
  final List<String> _apiKeys = [
    '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',
    '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',
    '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',
    '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',
  ];

  final String _apiUrl = 'https://openrouter.ai/api/v1/chat/completions';
  int _currentApiKeyIndex = 0;

  /// Get the current API key
  String get _currentApiKey => _apiKeys[_currentApiKeyIndex];

  /// Switch to the next API key
  bool _switchToNextApiKey() {
    if (_currentApiKeyIndex < _apiKeys.length - 1) {
      _currentApiKeyIndex++;
      print('Switching to API key #${_currentApiKeyIndex + 1} for questions generation');
      return true;
    }
    return false;
  }

  /// Reset API key index to the first one
  void _resetApiKeyIndex() {
    _currentApiKeyIndex = 0;
  }

  /// Check if the error is related to API key issues
  bool _isApiKeyError(int statusCode, String responseBody) {
    return statusCode == 401 ||
        statusCode == 403 ||
        responseBody.toLowerCase().contains('unauthorized') ||
        responseBody.toLowerCase().contains('invalid') ||
        responseBody.toLowerCase().contains('expired') ||
        responseBody.toLowerCase().contains('quota') ||
        responseBody.toLowerCase().contains('limit exceeded');
  }

  Future<List<Question>> generateQuestionsFromStory(String story) async {
    final prompt = '''
اقرأ القصة التالية المكتوبة باللغة العربية، ثم أنشئ 10 أسئلة اختيار من متعدد باللغة العربية أيضًا. يجب أن تكون الأسئلة متنوعة وغير متكررة وتغطي جوانب مختلفة من القصة. يجب أن يكون لكل سؤال 4 اختيارات، وحدد الخيار الصحيح باستخدام الحقل "correctIndex" (مثلاً 0 أو 1 أو 2 أو 3).

تأكد من أن الأسئلة تغطي:
- الأحداث الرئيسية في القصة
- الشخصيات المذكورة
- المكان والزمان
- الدروس المستفادة
- التفاصيل المهمة
- الأسباب والنتائج
- المشاعر والأفكار
- القيم والأخلاق المطروحة

القصة:
$story

رجاءً أعد النتيجة بصيغة JSON فقط، وبدون أي شرح أو نص إضافي، مثل الشكل التالي:
[
  {
    "question": "ما هو موضوع القصة الرئيسي؟",
    "choices": ["الأمان", "الصداقة", "النظافة", "الرياضة"],
    "correctIndex": 0
  },
  ...
]
''';

    final requestBody = jsonEncode({
      'model': 'meta-llama/llama-3-70b-instruct',
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'temperature': 0.3,
    });

    // Try each API key until one works or all fail
    for (int attempt = 0; attempt < _apiKeys.length; attempt++) {
      try {
        final headers = {
          'Authorization': 'Bearer $_currentApiKey',
          'Content-Type': 'application/json',
        };

        print('Attempting questions generation with API key #${_currentApiKeyIndex + 1}');
        final response = await http.post(
          Uri.parse(_apiUrl),
          headers: headers,
          body: requestBody,
        );

        if (response.statusCode == 200) {
          // Use utf8.decode to correctly decode Arabic characters
          final rawBody = utf8.decode(response.bodyBytes);
          final content = jsonDecode(rawBody)['choices'][0]['message']['content'];

          // Match the first valid JSON array
          final jsonArrayRegex = RegExp(r'\[\s*{[\s\S]*?}\s*]', multiLine: true);
          final match = jsonArrayRegex.firstMatch(content);

          if (match != null) {
            final jsonString = match.group(0)!;
            final List<dynamic> jsonList = jsonDecode(jsonString);
            final questions = jsonList.map((e) => Question.fromJson(e)).toList();
            print('Questions generated successfully with API key #${_currentApiKeyIndex + 1}');
            return questions;
          } else {
            print('No valid JSON found in response with API key #${_currentApiKeyIndex + 1}');
            throw Exception("لم يتم العثور على بيانات JSON صالحة في رد النموذج.");
          }
        } else {
          print('API key #${_currentApiKeyIndex + 1} failed with status: ${response.statusCode}');
          print('Response: ${response.body}');

          // Check if it's an API key related error
          if (_isApiKeyError(response.statusCode, response.body)) {
            if (!_switchToNextApiKey()) {
              // No more API keys to try
              _resetApiKeyIndex(); // Reset for next time
              throw Exception('جميع مفاتيح API فشلت في توليد الأسئلة. آخر خطأ: ${response.statusCode} - ${response.body}');
            }
            // Continue to next iteration to try the next API key
            continue;
          } else {
            // Non-API key error, throw immediately
            _resetApiKeyIndex(); // Reset for next time
            throw Exception('فشل توليد الأسئلة من الذكاء الاصطناعي: ${response.statusCode} - ${response.body}');
          }
        }
      } catch (e) {
        print('Error with API key #${_currentApiKeyIndex + 1} during questions generation: $e');

        // If it's a JSON parsing error or similar, and we have more API keys to try
        if (_currentApiKeyIndex < _apiKeys.length - 1 &&
            (e.toString().contains('JSON') || e.toString().contains('لم يتم العثور على بيانات JSON صالحة'))) {
          // Try next API key for JSON parsing issues (might be model-specific)
          _switchToNextApiKey();
          continue;
        }

        // If it's the last API key, throw the error
        if (_currentApiKeyIndex == _apiKeys.length - 1) {
          _resetApiKeyIndex(); // Reset for next time
          throw Exception('فشل في توليد الأسئلة بعد تجربة جميع مفاتيح API: $e');
        }

        // Try next API key for other errors
        _switchToNextApiKey();
      }
    }

    // This should never be reached, but just in case
    _resetApiKeyIndex();
    throw Exception('فشل في توليد الأسئلة: لم يتم العثور على مفتاح API صالح');
  }
}