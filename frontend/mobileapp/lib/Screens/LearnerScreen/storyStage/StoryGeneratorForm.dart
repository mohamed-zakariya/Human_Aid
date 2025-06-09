import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StoryGeneratorForm extends StatefulWidget {
  @override
  _StoryGeneratorFormState createState() => _StoryGeneratorFormState();
}

class _StoryGeneratorFormState extends State<StoryGeneratorForm> {
  String? age, topic, setting, length, goal;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  List<String> ages = ['4', '5', '6', '7', '8'];
  List<String> topics = ['الأمان', 'الصداقة', 'النظافة', 'الأمانة'];
  List<String> settings = ['المدرسة', 'المنزل', 'الحديقة'];
  List<String> lengths = ['قصة قصيرة', 'قصة متوسطة', 'قصة طويلة'];
  List<String> goals = ['تعليم الأخلاق', 'تعزيز القراءة', 'بناء المفردات'];

  String? generatedStory;

  Future<void> generateStoryWithGemini() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final prompt = '''
اكتب قصة تعليمية ممتعة باللغة العربية للأطفال بعمر $age سنوات.
الموضوع: $topic.
الإعداد: $setting.
الطول المطلوب: $length.
الهدف من القصة: $goal.
اجعل القصة شيقة ومناسبة لعمر الطفل.
''';

      setState(() {
        isLoading = true;
        generatedStory = null;
      });

      try {
        final response = await http.post(
          Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyCThoYGq757yTHNBQIhQIfFhwOmj4VlPVE'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "contents": [
              {
                "parts": [
                  {"text": prompt}
                ]
              }
            ]
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final storyText = data["candidates"][0]["content"]["parts"][0]["text"];
          setState(() {
            generatedStory = storyText;
          });
        } else {
          setState(() {
            generatedStory = "فشل في توليد القصة. تحقق من صلاحية المفتاح أو حاول لاحقًا.";
          });
        }
      } catch (e) {
        setState(() {
          generatedStory = "حدث خطأ أثناء الاتصال بخادم Gemini.";
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget dropdownField({
    required String label,
    required List<String> options,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: value,
      items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'اختر $label' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("توليد قصة تعليمية")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              dropdownField(label: 'العمر', options: ages, value: age, onChanged: (val) => setState(() => age = val)),
              dropdownField(label: 'الموضوع', options: topics, value: topic, onChanged: (val) => setState(() => topic = val)),
              dropdownField(label: 'الإعداد', options: settings, value: setting, onChanged: (val) => setState(() => setting = val)),
              dropdownField(label: 'الطول', options: lengths, value: length, onChanged: (val) => setState(() => length = val)),
              dropdownField(label: 'الهدف', options: goals, value: goal, onChanged: (val) => setState(() => goal = val)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : generateStoryWithGemini,
                child: isLoading ? CircularProgressIndicator() : Text("توليد القصة"),
              ),
              const SizedBox(height: 20),
              if (generatedStory != null)
                Text("📖 القصة الناتجة:", style: TextStyle(fontWeight: FontWeight.bold)),
              if (generatedStory != null)
                Text(generatedStory!, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
