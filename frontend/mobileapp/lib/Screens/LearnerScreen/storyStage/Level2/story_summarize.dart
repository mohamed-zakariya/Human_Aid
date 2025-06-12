import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../generated/l10n.dart';

class ArabicStorySummarizeWidget extends StatefulWidget {
  const ArabicStorySummarizeWidget({Key? key}) : super(key: key);

  @override
  State<ArabicStorySummarizeWidget> createState() => _ArabicStorySummarizeWidgetState();
}

class _ArabicStorySummarizeWidgetState extends State<ArabicStorySummarizeWidget> {
  final TextEditingController _summaryController = TextEditingController();
  bool _isLoading = false;
  String? _feedbackMessage;
  Color? _feedbackColor;
  int _currentStoryIndex = 0;

  // Arabic stories embedded in the widget
  final List<String> _stories = [
    '''كان هناك صبي صغير يُدعى أحمد يحب القراءة كثيراً. كان يقضي ساعات طويلة في المكتبة يقرأ الكتب المختلفة. في يوم من الأيام، وجد كتاباً قديماً مليئاً بالحكايات الشعبية. فتح الكتاب وبدأ في القراءة، وإذا بالشخصيات تنبض بالحياة أمام عينيه. تعلم أحمد من هذه التجربة أن للقراءة سحراً عظيماً يمكنه أن ينقلنا إلى عوالم مختلفة. منذ ذلك اليوم، أصبح أحمد أكثر شغفاً بالقراءة وقرر أن يصبح كاتباً في المستقبل.''',

    '''في قرية صغيرة، عاشت فتاة تُدعى فاطمة مع جدتها الحكيمة. كانت الجدة تعرف أسرار الطبخ التقليدي والوصفات القديمة. كل يوم، كانت فاطمة تراقب جدتها وهي تحضر الطعام بحب وعناية. تعلمت فاطمة أن الطبخ ليس مجرد خلط المكونات، بل هو فن يحتاج إلى صبر وإتقان. عندما كبرت فاطمة، افتتحت مطعماً صغيراً وأصبحت مشهورة بأطباقها التراثية الشهية التي تذكر الجميع بطعم البيت.''',

    '''كان سالم صبياً يخاف من الظلام كثيراً. في كل ليلة، كان يرفض النوم بدون إضاءة الغرفة بالكامل. لاحظ والد سالم هذا الخوف وقرر مساعدته. أخذه في رحلة تخييم تحت النجوم وعلمه كيف يرى جمال الليل والنجوم المتلألئة. تدريجياً، تعلم سالم أن الظلام ليس مخيفاً، بل هو وقت السكينة والهدوء. أصبح سالم يحب النظر إلى النجوم كل ليلة قبل النوم، وتغلب على خوفه من الظلام نهائياً.'''
  ];

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  // AI Model Request Implementation
  Future<Map<String, dynamic>> _checkSummaryWithAI(String userSummary, String originalStory) async {
    try {
      // Replace with your actual AI API endpoint
      const String apiUrl = 'https://your-ai-api-endpoint.com/check-summary';
      const String apiKey = 'your-api-key-here'; // Replace with your API key

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'original_story': originalStory,
          'user_summary': userSummary,
          'language': 'arabic',
          'task': 'summary_evaluation'
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to connect to AI service: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback: Simple local validation for demo purposes
      return _performLocalValidation(userSummary, originalStory);
    }
  }

  // Simple local validation as fallback
  Map<String, dynamic> _performLocalValidation(String userSummary, String originalStory) {
    // Basic validation logic
    if (userSummary.length < 20) {
      return {
        'is_valid': false,
        'score': 30,
        'feedback': 'الملخص قصير جداً. حاول إضافة المزيد من التفاصيل المهمة.',
        'suggestions': ['أضف الشخصيات الرئيسية', 'اذكر الأحداث المهمة', 'أضف النتيجة أو الدرس المستفاد']
      };
    }

    if (userSummary.length > 200) {
      return {
        'is_valid': false,
        'score': 60,
        'feedback': 'الملخص طويل جداً. حاول التركيز على النقاط الأساسية فقط.',
        'suggestions': ['اختصر الأحداث الثانوية', 'ركز على الفكرة الرئيسية', 'احذف التفاصيل غير المهمة']
      };
    }

    // Check for key elements (basic keyword matching)
    List<String> keyWords = [];
    if (_currentStoryIndex == 0) {
      keyWords = ['أحمد', 'قراءة', 'كتاب', 'مكتبة'];
    } else if (_currentStoryIndex == 1) {
      keyWords = ['فاطمة', 'جدة', 'طبخ', 'مطعم'];
    } else {
      keyWords = ['سالم', 'ظلام', 'نجوم', 'خوف'];
    }

    int foundKeywords = keyWords.where((word) => userSummary.contains(word)).length;
    double score = (foundKeywords / keyWords.length) * 100;

    if (score >= 75) {
      return {
        'is_valid': true,
        'score': score.round(),
        'feedback': 'ممتاز! ملخص جيد يغطي النقاط الأساسية للقصة.',
        'suggestions': []
      };
    } else if (score >= 50) {
      return {
        'is_valid': true,
        'score': score.round(),
        'feedback': 'جيد! لكن يمكن تحسين الملخص بإضافة المزيد من التفاصيل المهمة.',
        'suggestions': ['أضف المزيد من الأحداث الرئيسية', 'اذكر النتيجة أو الدرس المستفاد']
      };
    } else {
      return {
        'is_valid': false,
        'score': score.round(),
        'feedback': 'الملخص يحتاج إلى تحسين. لم يغطِ النقاط الأساسية للقصة.',
        'suggestions': ['اقرأ القصة مرة أخرى', 'ركز على الشخصيات الرئيسية', 'اذكر الأحداث المهمة']
      };
    }
  }

  void _checkSummary() async {
    if (_summaryController.text.trim().isEmpty) {
      setState(() {
        _feedbackMessage = 'يرجى كتابة ملخص للقصة';
        _feedbackColor = Colors.orange;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _feedbackMessage = null;
    });

    try {
      final result = await _checkSummaryWithAI(
          _summaryController.text.trim(),
          _stories[_currentStoryIndex]
      );

      setState(() {
        _isLoading = false;
        if (result['is_valid'] == true) {
          _feedbackMessage = '${result['feedback']} (النتيجة: ${result['score']}%)';
          _feedbackColor = result['score'] >= 75 ? Colors.green : Colors.blue;
        } else {
          _feedbackMessage = '${result['feedback']} (النتيجة: ${result['score']}%)';
          _feedbackColor = Colors.orange;
        }
      });

      // Show suggestions if available
      if (result['suggestions'] != null && result['suggestions'].isNotEmpty) {
        _showSuggestionsDialog(result['suggestions']);
      }

    } catch (e) {
      setState(() {
        _feedbackMessage = 'حدث خطأ أثناء فحص الملخص: ${e.toString()}';
        _feedbackColor = Colors.red;
        _isLoading = false;
      });
    }
  }

  void _showSuggestionsDialog(List<dynamic> suggestions) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            S.of(context).improvementSuggestions,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: suggestions.map<Widget>((suggestion) =>
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          suggestion.toString(),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                )
            ).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(S.of(context).ok),
            ),
          ],
        );
      },
    );
  }

  void _nextStory() {
    setState(() {
      _currentStoryIndex = (_currentStoryIndex + 1) % _stories.length;
      _summaryController.clear();
      _feedbackMessage = null;
    });
  }

  void _previousStory() {
    setState(() {
      _currentStoryIndex = _currentStoryIndex > 0 ? _currentStoryIndex - 1 : _stories.length - 1;
      _summaryController.clear();
      _feedbackMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          args['gameName'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF7B68EE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _summaryController.clear();
                _feedbackMessage = null;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Story Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _previousStory,
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                  label: Text(S.of(context).previous),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Text(
                  S.of(context).storyCounter(_currentStoryIndex + 1, _stories.length),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _nextStory,
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  label: Text(S.of(context).next),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Story Display Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9C88FF), Color(0xFF7B68EE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.book_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          S.of(context).story,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _stories[_currentStoryIndex],
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Color(0xFF2D3748),
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Summary Input Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4FD1C7).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: Color(0xFF4FD1C7),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          S.of(context).writeSummaryHere,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _summaryController,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: S.of(context).summaryHint,
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(15),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Feedback Message
            if (_feedbackMessage != null)
              Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: _feedbackColor?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _feedbackColor ?? Colors.grey,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _feedbackColor == Colors.green
                          ? Icons.check_circle_outline
                          : _feedbackColor == Colors.blue
                          ? Icons.thumb_up_outlined
                          : _feedbackColor == Colors.red
                          ? Icons.error_outline
                          : Icons.info_outline,
                      color: _feedbackColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _feedbackMessage!,
                        style: TextStyle(
                          color: _feedbackColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              ),

            // Check Summary Button
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _checkSummary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FD1C7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                ),
                child: _isLoading
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      S.of(context).checking,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline),
                    const SizedBox(width: 10),
                    Text(
                      S.of(context).checkSummary,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}