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
  final String _apiKey = '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';
  final String _apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

  Future<List<Question>> generateQuestionsFromStory(String story) async {
    final prompt = '''
اقرأ القصة التالية المكتوبة باللغة العربية، ثم أنشئ 5 أسئلة اختيار من متعدد باللغة العربية أيضًا. يجب أن يكون لكل سؤال 4 اختيارات، وحدد الخيار الصحيح باستخدام الحقل "correctIndex" (مثلاً 0 أو 1).

القصة:
$story

رجاءً أعد النتيجة بصيغة JSON فقط، وبدون أي شرح أو نص إضافي، مثل الشكل التالي:
[
  {
    "question": "ما هو موضوع القصة؟",
    "choices": ["الأمان", "الصداقة", "النظافة", "الرياضة"],
    "correctIndex": 0
  },
  ...
]
''';

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'meta-llama/llama-3-70b-instruct',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.3,
      }),
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
        return jsonList.map((e) => Question.fromJson(e)).toList();
      } else {
        throw Exception("لم يتم العثور على بيانات JSON صالحة في رد النموذج.");
      }
    } else {
      throw Exception('فشل توليد الأسئلة من الذكاء الاصطناعي: ${response.statusCode}');
    }
  }
}
