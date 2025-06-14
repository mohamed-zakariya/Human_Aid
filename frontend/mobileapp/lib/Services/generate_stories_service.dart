// Enhanced GenerateStoriesService with Complete Story Generation
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class GenerateStoriesService {
  // List of API keys for fallback functionality
  final List<String> _apiKeys = [
    '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',
    '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',
    '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',
    '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',
    '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'
  ];

  int _currentApiKeyIndex = 0;
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

  /// Get the current API key
  String get _currentApiKey => _apiKeys[_currentApiKeyIndex];

  /// Switch to the next API key
  bool _switchToNextApiKey() {
    if (_currentApiKeyIndex < _apiKeys.length - 1) {
      _currentApiKeyIndex++;
      print('Switching to API key #${_currentApiKeyIndex + 1}');
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
      "temperature": 0.7,
      "top_p": 0.9,
      "presence_penalty": 0.2,
      "frequency_penalty": 0.1,
      "stop": ["\n\n\n", "---", "***", "القصة التالية", "قصة أخرى"], // Add stop sequences
    });

    // Try each API key until one works or all fail
    for (int attempt = 0; attempt < _apiKeys.length; attempt++) {
      try {
        final headers = {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_currentApiKey',
        };

        print('Attempting request with API key #${_currentApiKeyIndex + 1}');
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final content = data['choices'][0]['message']['content'];
          final cleanedStory = _cleanAndFormatArabicText(content).trim();

          // Validate that story is complete
          final validatedStory = _validateAndCompleteStory(cleanedStory, length);

          print('Story generated successfully with API key #${_currentApiKeyIndex + 1}');
          print(validatedStory);
          return validatedStory;
        } else {
          print('API key #${_currentApiKeyIndex + 1} failed with status: ${response.statusCode}');
          print('Response: ${response.body}');

          // Check if it's an API key related error
          if (_isApiKeyError(response.statusCode, response.body)) {
            if (!_switchToNextApiKey()) {
              // No more API keys to try
              _resetApiKeyIndex(); // Reset for next time
              throw Exception('جميع مفاتيح API فشلت. آخر خطأ: ${response.statusCode} - ${response.body}');
            }
            // Continue to next iteration to try the next API key
            continue;
          } else {
            // Non-API key error, throw immediately
            _resetApiKeyIndex(); // Reset for next time
            throw Exception('فشل في توليد القصة: ${response.statusCode} - ${response.body}');
          }
        }
      } catch (e) {
        print('Error with API key #${_currentApiKeyIndex + 1}: $e');

        // If it's the last API key, throw the error
        if (_currentApiKeyIndex == _apiKeys.length - 1) {
          _resetApiKeyIndex(); // Reset for next time
          throw Exception('فشل في توليد القصة بعد تجربة جميع مفاتيح API: $e');
        }

        // Try next API key
        _switchToNextApiKey();
      }
    }

    // This should never be reached, but just in case
    _resetApiKeyIndex();
    throw Exception('فشل في توليد القصة: لم يتم العثور على مفتاح API صالح');
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

  // Fixed token limits to ensure complete stories
  int _getTokenLimit(String length) {
    switch (length) {
      case 'قصة قصيرة': return 140; // Reduced from 150
      case 'قصة متوسطة': return 160; // Reduced from 200
      case 'قصة طويلة': return 180; // Reduced from 250
      default: return 140;
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
أنت كاتب قصص أطفال محترف ومبدع، متخصص في إنتاج قصص تعليمية مكتملة باللغة العربية الفصحى. مهمتك إبداع قصص قصيرة ومتماسكة تجمع بين المتعة والفائدة التربوية.

🌟 مبادئ الإبداع الأساسية:
- اكتب قصصاً مكتملة من البداية للنهاية
- كل قصة يجب أن تنتهي بخاتمة واضحة ومرضية
- استخدم جملاً قصيرة وبسيطة
- اجعل كل قصة مستقلة وغير مترابطة مع قصص أخرى

📚 متطلبات اللغة والأسلوب:
- العربية الفصحى البسيطة المناسبة لعمر $age سنوات
- جمل قصيرة جداً (3-7 كلمات لكل جملة)
- مفردات بسيطة ومناسبة للأطفال
- تدفق سردي سلس ومشوق

🎯 القيم التربوية:
- ادمج القيم بطريقة طبيعية وغير مباشرة
- اجعل الطفل يستنتج الدرس بنفسه
- ركز على السلوكيات الإيجابية

⚡ مبادئ التشويق:
- ابدأ بطريقة جذابة تشد الانتباه
- اجعل النهاية مفاجئة ومُرضية ومكتملة
- تأكد من انتهاء القصة بشكل طبيعي

🚫 تجنب تماماً:
- ترك القصة بدون نهاية
- الجمل الطويلة والمعقدة
- القصص المفتوحة أو غير المكتملة
- استخدام عبارات مثل "يتبع" أو "في الجزء التالي
- مهما كانت القصة طويلة او متوسطة او قصيرة عدم تركها بدون نهاية و عدم اظهار حروف غير مكتملة"

⭐ الأهم من كل شيء:
- اكتب قصة مكتملة لها بداية ووسط ونهاية واضحة
- تأكد من أن القصة تنتهي بحل المشكلة والدرس المستفاد
- لا تترك أي خيوط مفتوحة في القصة
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

    // Reduced word limits for shorter, complete stories
    final wordLimit = {
      "قصة قصيرة": "40-75 كلمة",
      "قصة متوسطة": "75-105 كلمة",
      "قصة طويلة": "106-130 كلمة",
    }[length] ?? "75-105 كلمة";

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
اكتب قصة تعليمية مكتملة وقصيرة باللغة العربية الفصحى بناءً على التفاصيل التالية:

🎯 المعلومات الأساسية:
▪ الموضوع الرئيسي: ${basic['topic']}
▪ مكان الأحداث: ${basic['setting']}
▪ الهدف التعليمي: ${basic['goal']}
▪ عمر الطفل المستهدف: ${basic['age']} سنة
▪ طول القصة: ${basic['length']} ($wordLimit)

👥 الشخصيات:
▪ نوع البطل: ${characters['hero_type']}
$charactersInfo

🎬 الأحداث والصراع:
▪ التحدي الرئيسي: ${plot['challenge']}
▪ طريقة الحل: ${plot['resolution']}

📖 القيم والدروس:
▪ الدرس الأساسي: ${values['primary_lesson']}

✨ عناصر إبداعية مقترحة:
▪ بداية القصة: "${creative['opener']}"
▪ نهاية حكيمة: "${creative['wisdom_ending']}"

🔥 المطلوب:
قصة مكتملة تماماً من البداية للنهاية تتضمن:
1. مقدمة سريعة للشخصية والمشكلة
2. تطور الأحداث وحل المشكلة
3. نهاية واضحة مع الدرس المستفاد

📏 عدد الكلمات: $wordLimit بالضبط

⚠️ مهم جداً:
- اكتب القصة فقط بدون أي تعليقات
- تأكد من أن القصة مكتملة ولها نهاية واضحة
- لا تترك القصة معلقة أو بدون خاتمة
- استعمل جملاً قصيرة وبسيطة فقط
''';
  }

  // Enhanced story validation and completion
  String _validateAndCompleteStory(String story, String length) {
    String validatedStory = story;

    // Check if story ends abruptly or incomplete
    final lastSentence = validatedStory.split('.').last.trim();

    // Check for incomplete endings
    final incompletePatterns = [
      RegExp(r'وأدرك\s*$'),
      RegExp(r'وعرف\s*$'),
      RegExp(r'وفهم\s*$'),
      RegExp(r'وتعلم\s*$'),
      RegExp(r'أن\s*$'),
      RegExp(r'في\s*$'),
      RegExp(r'من\s*$'),
      RegExp(r'هو\s*$'),
    ];

    bool isIncomplete = incompletePatterns.any((pattern) =>
        pattern.hasMatch(validatedStory.trim()));

    // If story is incomplete, add a simple ending
    if (isIncomplete || !validatedStory.trim().endsWith('.')) {
      if (!validatedStory.endsWith('.')) {
        // Find the last complete sentence
        final sentences = validatedStory.split('.');
        if (sentences.length > 1) {
          validatedStory = sentences.sublist(0, sentences.length - 1).join('.') + '.';
        }
      }

      // Add a simple moral ending if needed
      if (validatedStory.split(' ').length < _getMinWordCount(length)) {
        validatedStory += ' وهكذا تعلم أهمية الصدق والعمل الجاد.';
      }
    }

    return validatedStory;
  }

  int _getMinWordCount(String length) {
    switch (length) {
      case 'قصة قصيرة': return 50;
      case 'قصة متوسطة': return 80;
      case 'قصة طويلة': return 110;
      default: return 80;
    }
  }

  // Improved Arabic text cleaning function
  String _cleanAndFormatArabicText(String input) {
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