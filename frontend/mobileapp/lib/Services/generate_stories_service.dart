// Enhanced GenerateStoriesService
import 'dart:convert';
import 'package:http/http.dart' as http;

class GenerateStoriesService {
  final String openRouterApiKey = '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';

  Future<String> generateArabicStory({
    required String topic,
    required String setting,
    required String goal,
    required String age,
    required String length,
    String? style,
    String? heroType,
    String? secondaryValues,
  }) async {
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Bearer $openRouterApiKey',
    };

    final String additionalInstructions = '''
${style != null ? "▪ نوع الأسلوب المطلوب: $style" : ""}
${heroType != null ? "▪ شخصية البطل: $heroType" : ""}
${secondaryValues != null ? "▪ قيم تربوية إضافية: $secondaryValues" : ""}
''';

    final systemPrompt = '''
أنت خبير في كتابة قصص الأطفال التعليمية باللغة العربية الفصحى. مهمتك إنشاء قصص إبداعية وممتعة تجمع بين التعلم والترفيه للأطفال.

🎯 المبادئ الأساسية:
- استخدم العربية الفصحى البسيطة والواضحة المناسبة لعمر $age سنوات
- اجعل القصة تحتوي على مغزى تربوي واضح مرتبط بالهدف المحدد
- استخدم أسلوب سرد شيق ومناسب للأطفال
- اختر أسماء عربية جميلة ومألوفة للشخصيات

✨ متطلبات الكتابة:
1. استخدم حروف عربية فقط مع علامات الترقيم المناسبة (، . ؟ ! ؛)
2. اجعل الجمل قصيرة وسهلة الفهم
3. استخدم كلمات بسيطة ومفهومة للأطفال
4. اجعل الحوار طبيعياً وممتعاً
5. تجنب المفردات المعقدة أو غير المألوفة

📚 هيكل القصة المطلوب:
- بداية جذابة تقدم الشخصيات والمكان
- حدث أو مشكلة تحتاج لحل
- تطور الأحداث مع تعلم الدرس
- نهاية إيجابية تؤكد على القيمة المستفادة

🎨 اجعل القصة:
- ممتعة ومشوقة للأطفال
- تحتوي على عناصر التفاعل والمشاركة
- تنمي الخيال والإبداع
- تركز على القيم الإيجابية والأخلاق الحميدة

⚠️ تجنب:
- الكلمات الصعبة أو المعقدة
- المواضيع المخيفة أو المحزنة
- الجمل الطويلة والمعقدة
- استخدام كلمات غير عربية
''';

    final userPrompt = '''
اكتب قصة تعليمية رائعة للأطفال باللغة العربية الفصحى بناءً على المعلومات التالية:

🎭 تفاصيل القصة:
▪ موضوع القصة: $topic
▪ مكان الأحداث: $setting  
▪ الهدف التعليمي: $goal
▪ عمر الطفل: $age سنة
▪ طول القصة المطلوب: $length
$additionalInstructions

📋 متطلبات خاصة:
- اجعل القصة مناسبة تماماً لعمر $age سنوات
- ركز على تحقيق الهدف التعليمي: $goal
- استخدم مكان الأحداث: $setting بشكل مناسب ومبدع
- اجعل موضوع $topic محور القصة الأساسي

🔥 المطلوب:
قصة مكتملة ومتماسكة تبدأ وتنتهي بطريقة مرضية، مع التركيز على الدرس المستفاد والقيمة التربوية.

لا تكتب أي شيء غير القصة فقط.
''';

    final body = jsonEncode({
      "model": "meta-llama/llama-3.1-70b-instruct",
      "messages": [
        {"role": "system", "content": systemPrompt},
        {"role": "user", "content": userPrompt}
      ],
      "max_tokens": 1200,
      "temperature": 0.7,
      "top_p": 0.9,
      "presence_penalty": 0.2,
      "frequency_penalty": 0.2,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final content = data['choices'][0]['message']['content'];
      final cleanedStory = _cleanAndFormatArabicText(content).trim();
      return cleanedStory;
    } else {
      throw Exception('فشل في توليد القصة: ${response.statusCode} - ${response.body}');
    }
  }

  String _cleanAndFormatArabicText(String input) {
    // Remove any unwanted characters and keep only Arabic text and punctuation
    final arabicPattern = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\s\.,!?؟،؛:"()«»\-\n]');
    final cleanedChars = input.runes
        .where((rune) => arabicPattern.hasMatch(String.fromCharCode(rune)))
        .map((rune) => String.fromCharCode(rune));

    String result = cleanedChars.join();

    // Clean up extra spaces and format properly
    result = result
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\n\s*\n'), '\n\n')
        .trim();

    return result;
  }
}