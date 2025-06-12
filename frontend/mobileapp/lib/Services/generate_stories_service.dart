// Enhanced GenerateStoriesService
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class GenerateStoriesService {
  final String openRouterApiKey = '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';
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

  final List<String> _creativeOpeners = [
    'في يوم جميل مشرق',
    'عندما أشرقت الشمس الذهبية',
    'في صباح مليء بالأمل',
    'حين غردت العصافير بفرح',
    'في زمن قديم جميل',
    'عندما كانت النجوم تلمع',
    'في مكان سحري بعيد',
    'حيث تنمو الأحلام الجميلة'
  ];

  final List<String> _wisdomEndings = [
    'وهكذا تعلم أن',
    'ومن ذلك اليوم فهم أن',
    'وأدرك في النهاية أن',
    'واكتشف أن السر في',
    'وعرف أن الحياة تعلمنا أن',
    'وفهم أن أجمل ما في الحياة هو'
  ];

  Future<String> generateArabicStory({
    required String topic,
    required String setting,
    required String goal,
    required String age,
    required String length,
    String? style,
    String? heroType,
    String? secondaryValues,
    String? timeOfDay,
    String? weather,
    String? mood,
    String? challenge,
    String? lesson,
    String? companion,
    String? storyTone,
    String? mainCharacterTrait,
    String? conflict,
    String? resolution,
    String? culturalElement,
  }) async {
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Bearer $openRouterApiKey',
    };

    // Generate creative character names
    final characterNames = _generateCharacterNames(heroType);
    final storyOpener = _getRandomOpener();
    final wisdomEnding = _getRandomWisdomEnding();

    // Build comprehensive story context
    final storyContext = _buildStoryContext(
      topic: topic,
      setting: setting,
      goal: goal,
      age: age,
      length: length,
      style: style,
      heroType: heroType,
      secondaryValues: secondaryValues,
      timeOfDay: timeOfDay,
      weather: weather,
      mood: mood,
      challenge: challenge,
      lesson: lesson,
      companion: companion,
      storyTone: storyTone,
      mainCharacterTrait: mainCharacterTrait,
      conflict: conflict,
      resolution: resolution,
      culturalElement: culturalElement,
      characterNames: characterNames,
      storyOpener: storyOpener,
      wisdomEnding: wisdomEnding,
    );

    final systemPrompt = _buildEnhancedSystemPrompt(age);
    final userPrompt = _buildDynamicUserPrompt(storyContext, length);

    final body = jsonEncode({
      "model": "meta-llama/llama-3.1-70b-instruct",
      "messages": [
        {"role": "system", "content": systemPrompt},
        {"role": "user", "content": userPrompt}
      ],
      "max_tokens": _getTokenLimit(length),
      "temperature": 0.8,
      "top_p": 0.9,
      "presence_penalty": 0.3,
      "frequency_penalty": 0.2,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final content = data['choices'][0]['message']['content'];
      final cleanedStory = _cleanAndFormatArabicText(content).trim();
      print(cleanedStory);
      return cleanedStory;
    } else {
      throw Exception('فشل في توليد القصة: ${response.statusCode} - ${response.body}');
    }
  }

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

  String _getRandomOpener() {
    return _creativeOpeners[_random.nextInt(_creativeOpeners.length)];
  }

  String _getRandomWisdomEnding() {
    return _wisdomEndings[_random.nextInt(_wisdomEndings.length)];
  }

  int _getTokenLimit(String length) {
    switch (length) {
      case 'قصة قصيرة': return 150;
      case 'قصة متوسطة': return 200;
      case 'قصة طويلة': return 250;
      default: return 150;
    }
  }


  Map<String, dynamic> _buildStoryContext({
    required String topic,
    required String setting,
    required String goal,
    required String age,
    required String length,
    String? style,
    String? heroType,
    String? secondaryValues,
    String? timeOfDay,
    String? weather,
    String? mood,
    String? challenge,
    String? lesson,
    String? companion,
    String? storyTone,
    String? mainCharacterTrait,
    String? conflict,
    String? resolution,
    String? culturalElement,
    required Map<String, String> characterNames,
    required String storyOpener,
    required String wisdomEnding,
  }) {
    return {
      'basic': {
        'topic': topic,
        'setting': setting,
        'goal': goal,
        'age': age,
        'length': length,
      },
      'style': {
        'narrative_style': style ?? 'واقعية',
        'tone': storyTone ?? 'مرح ومبهج',
        'mood': mood ?? 'سعيد',
      },
      'characters': {
        'hero_type': heroType ?? 'ولد',
        'main_trait': mainCharacterTrait ?? 'شجاع',
        'companion': companion ?? 'الأصدقاء',
        'names': characterNames,
      },
      'environment': {
        'time_of_day': timeOfDay ?? 'الصباح',
        'weather': weather ?? 'مشمس',
        'cultural_element': culturalElement,
      },
      'plot': {
        'challenge': challenge ?? 'حل مشكلة',
        'conflict': conflict ?? 'مشكلة تحتاج حل',
        'resolution': resolution ?? 'التعاون مع الآخرين',
      },
      'values': {
        'primary_lesson': lesson ?? 'أهمية الصدق',
        'secondary_values': secondaryValues,
      },
      'creative_elements': {
        'opener': storyOpener,
        'wisdom_ending': wisdomEnding,
      },
    };
  }

  String _buildEnhancedSystemPrompt(String age) {
    return '''
أنت كاتب قصص أطفال محترف ومبدع، متخصص في إنتاج قصص تعليمية رائعة باللغة العربية الفصحى. مهمتك إبداع قصص فريدة ومتنوعة تجمع بين المتعة والفائدة التربوية.

🌟 مبادئ الإبداع الأساسية:
- اخلق قصصاً متنوعة ومختلفة في كل مرة
- استخدم خيالاً واسعاً وأفكاراً مبتكرة
- اجعل كل قصة فريدة من نوعها
- امزج بين الواقع والخيال بطريقة جذابة

📚 متطلبات اللغة والأسلوب:
- العربية الفصحى البسيطة المناسبة لعمر $age سنوات
- جمل قصيرة وواضحة وسهلة الفهم
- مفردات بسيطة ومناسبة للأطفال
- حوار طبيعي وممتع
- تدفق سردي سلس ومشوق

🎭 عناصر القصة المطلوبة:
- شخصيات محببة وقريبة من الطفل
- أحداث مشوقة ومناسبة للعمر
- دروس أخلاقية وتربوية واضحة
- نهاية إيجابية ومُرضية
- عنصر المفاجأة أو الإثارة البسيطة

🌈 التنويع والإبداع:
- استخدم تقنيات سرد متنوعة
- اخلق مواقف مختلفة وغير متوقعة  
- اجعل كل قصة تحمل طابعاً مميزاً
- استخدم الحواس الخمس في الوصف
- اربط القصة بخبرات الطفل اليومية

🎯 القيم التربوية:
- ادمج القيم بطريقة طبيعية وغير مباشرة
- اجعل الطفل يستنتج الدرس بنفسه
- ركز على السلوكيات الإيجابية
- عزز الثقة بالنفس والشجاعة
- أظهر أهمية التعاون والمشاركة

⚡ مبادئ التشويق:
- ابدأ بطريقة جذابة تشد الانتباه
- اخلق لحظات تشويق مناسبة للعمر
- استخدم الحوار لإضافة الحيوية
- اجعل النهاية مفاجئة ومُرضية
- ضع تفاصيل حسية تجعل القصة حية

🚫 تجنب تماماً:
- التكرار في الأفكار أو الأحداث
- الكلمات المعقدة أو غير المفهومة
- المواضيع المخيفة أو المحزنة
- الوعظ المباشر أو التلقين
- الجمل الطويلة والمعقدة
''';
  }

  String _buildDynamicUserPrompt(Map<String, dynamic> context, String length) {
    final basic = context['basic'];
    final style = context['style'];
    final characters = context['characters'];
    final environment = context['environment'];
    final plot = context['plot'];
    final values = context['values'];
    final creative = context['creative_elements'];

    final wordLimit = {
      "قصة قصيرة": "70-90 كلمة",
      "قصة متوسطة": "120-140 كلمة",
      "قصة طويلة": "170-190 كلمة",
    }[length] ?? "120-140 كلمة";

    String charactersInfo = '';
    final names = characters['names'] as Map<String, String>;
    if (names.containsKey('main')) {
      charactersInfo += '▪ اسم الشخصية الرئيسية: ${names['main']}\n';
    }
    if (names.containsKey('friend')) {
      charactersInfo += '▪ اسم الصديق/المرافق: ${names['friend']}\n';
    }
    if (names.containsKey('third')) {
      charactersInfo += '▪ شخصية ثالثة: ${names['third']}\n';
    }

    return '''
اكتب قصة تعليمية مبدعة وفريدة باللغة العربية الفصحى بناءً على التفاصيل التالية:

🎯 المعلومات الأساسية:
▪ الموضوع الرئيسي: ${basic['topic']}
▪ مكان الأحداث: ${basic['setting']}
▪ الهدف التعليمي: ${basic['goal']}
▪ عمر الطفل المستهدف: ${basic['age']} سنة
▪ طول القصة: ${basic['length']} ($wordLimit)

🎨 الأسلوب والطابع:
▪ نوع السرد: ${style['narrative_style']}
▪ نبرة القصة: ${style['tone']}
▪ المزاج العام: ${style['mood']}

👥 الشخصيات:
▪ نوع البطل: ${characters['hero_type']}
▪ الصفة الرئيسية للبطل: ${characters['main_trait']}
▪ المرافقون: ${characters['companion']}
$charactersInfo

🌍 البيئة والجو:
▪ وقت الأحداث: ${environment['time_of_day']}
▪ حالة الطقس: ${environment['weather']}
${environment['cultural_element'] != null ? '▪ العنصر الثقافي: ${environment['cultural_element']}' : ''}

🎬 الأحداث والصراع:
▪ التحدي الرئيسي: ${plot['challenge']}
▪ نوع المشكلة: ${plot['conflict']}
▪ طريقة الحل: ${plot['resolution']}

📖 القيم والدروس:
▪ الدرس الأساسي: ${values['primary_lesson']}
${values['secondary_values'] != null ? '▪ قيم إضافية: ${values['secondary_values']}' : ''}

✨ عناصر إبداعية مقترحة:
▪ بداية القصة: "${creative['opener']}"
▪ نهاية حكيمة: "${creative['wisdom_ending']}"

🎪 متطلبات خاصة:
- اجعل القصة فريدة ومختلفة عن القصص التقليدية
- استخدم الأسماء المقترحة للشخصيات
- اربط جميع العناصر المذكورة بطريقة إبداعية
- ركز على التفاعل بين الشخصيات
- اجعل الحل نابعاً من ذكاء وإبداع الشخصيات
- ضع تفاصيل حسية تجعل القارئ يعيش القصة

🔥 المطلوب:
قصة مكتملة ومتماسكة تبدأ بداية جذابة وتنتهي نهاية مُرضية، مع دمج جميع العناصر المطلوبة بطريقة طبيعية وإبداعية.

📏 عدد الكلمات: $wordLimit بالضبط

⚠️ اكتب القصة فقط بدون أي تعليقات أو شروحات إضافية.
''';
  }

  String _cleanAndFormatArabicText(String input) {
    // Enhanced Arabic text cleaning with better formatting
    final arabicPattern = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\s\.,!?؟،؛:"()«»\-\n\r]');
    final cleanedChars = input.runes
        .where((rune) => arabicPattern.hasMatch(String.fromCharCode(rune)))
        .map((rune) => String.fromCharCode(rune));

    String result = cleanedChars.join();

    // Enhanced text formatting
    result = result
        .replaceAll(RegExp(r'\s+'), ' ')  // Remove extra spaces
        .replaceAll(RegExp(r'\n\s*\n+'), '\n\n')  // Clean up line breaks
        .replaceAll(RegExp(r'^\s+|\s+$'), '')  // Trim
        .replaceAll('،،', '،')  // Fix double commas
        .replaceAll('..', '.')  // Fix double periods
        .replaceAll('؟؟', '؟')  // Fix double question marks
        .replaceAll('!!', '!')  // Fix double exclamations
        .replaceAll(RegExp(r'\s+([،؛:.!؟])'), r'$1')  // Fix spacing before punctuation
        .replaceAll(RegExp(r'([،؛:.!؟])([أابتثجحخدذرزسشصضطظعغفقكلمنهويءآإؤئ])'), r'$1 $2');  // Fix spacing after punctuation

    // Better paragraph formatting - only create paragraphs for actual story breaks
    // Look for sentences that end with specific patterns that indicate new paragraphs
    result = result.replaceAllMapped(
      RegExp(r'([.!؟])\s*(?=وهكذا|ومن ذلك اليوم|وأدرك|واكتشف|وعرف|وفهم|في يوم|عندما|حين|في زمن)'),
          (match) => '${match.group(1)}\n\n',
    );

    // Also handle common story transition phrases
    result = result.replaceAll(RegExp(r'([.!؟])\s*(?=بعد ذلك|في اليوم التالي|وفجأة|ولكن|لكن|وعندما|وبعد)'), r'$1 ');

    return result.trim();
  }


}