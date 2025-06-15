// screens/story_input_screen.dart
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:mobileapp/global/fns.dart';
import 'package:mobileapp/models/learner.dart';

import 'StoryResultScreen.dart';

class StoryInputScreen extends StatefulWidget {
  @override
  _StoryInputScreenState createState() => _StoryInputScreenState();
}

class _StoryInputScreenState extends State<StoryInputScreen> {
  final _formKey = GlobalKey<FormState>();

  String? topic, setting, length, goal, style, heroType, secondaryValues;

  // final List<String> ages = ['4', '5', '6', '7', '8'];
  late int age = 0;
  final List<String> topics = [
    'الصداقة',
    'الشجاعة',
    'التعاون',
    'الرحمة',
    'الاحترام',
    'حب الطبيعة'
  ];

  final List<String> settings = [
    'المدرسة',
    'الغابة',
    'الفضاء',
    'القلعة',
    'عالم تحت الماء',
    'المزرعة',
    'المكتبة'
  ];

  final List<String> lengths = ['قصة قصيرة', 'قصة متوسطة', 'قصة طويلة'];

  final List<String> goals = [
    'تعليم الأخلاق',
    'تنمية الخيال',
    'تحفيز التفكير النقدي',
    'تعلم مهارات التواصل',
    'تعزيز الثقة بالنفس',
    'تعلم العمل ضمن فريق',
    'تعلم الوعي العاطفي'
  ];

  final List<String> styles = ['واقعية', 'خيالية', 'مغامرة', 'عاطفية'];
  final List<String> heroTypes = ['ولد', 'بنت', 'مجموعة'];


  Widget _buildStyledDropdown({
    required String label,
    required List<String> options,
    required String? value,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF64B5F6), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                value: value,
                hint: Text('اختر $label', style: TextStyle(color: Colors.grey[600])),
                items: options.map((option) => DropdownMenuItem(
                  value: option,
                  child: Text(option, style: TextStyle(fontSize: 14)),
                )).toList(),
                onChanged: onChanged,
                validator: (value) => value == null ? 'يرجى اختيار $label' : null,
                dropdownColor: Colors.white,
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionalSection() {

    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF81C784), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                "اختيارات إضافية",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildOptionalDropdown(
            label: 'الأسلوب المفضل',
            options: styles,
            value: style,
            onChanged: (val) => setState(() => style = val),
            icon: Icons.palette,
          ),
          SizedBox(height: 12),
          _buildOptionalDropdown(
            label: 'بطل القصة',
            options: heroTypes,
            value: heroType,
            onChanged: (val) => setState(() => heroType = val),
            icon: Icons.person,
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'قيم إضافية (مثل: الصبر، التعاون)',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.add_circle_outline, color: Colors.green),
              ),
              onSaved: (val) => secondaryValues = val,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionalDropdown({
    required String label,
    required List<String> options,
    required String? value,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.green),
        ),
        value: value,
        items: options.map((option) => DropdownMenuItem(
          value: option,
          child: Text(option),
        )).toList(),
        onChanged: onChanged,
        dropdownColor: Colors.white,
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();


      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoryResultScreen(
            age: age.toString(),
            topic: topic!,
            setting: setting!,
            length: length!,
            goal: goal!,
            style: style,
            heroType: heroType,
            secondaryValues: secondaryValues,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    print(args['gameName']);
    Learner learner = args['learner'];
    age = calculateAge(learner.birthdate);


    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          args['gameName'],
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF6366F1),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.auto_stories, size: 48, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      "أنشئ قصة تعليمية مخصصة",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      "اختر الخيارات المناسبة لإنشاء قصة رائعة",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Required Fields
              _buildStyledDropdown(
                label: 'الموضوع',
                options: topics,
                value: topic,
                onChanged: (val) => setState(() => topic = val),
                icon: Icons.topic,
              ),
              _buildStyledDropdown(
                label: 'المكان',
                options: settings,
                value: setting,
                onChanged: (val) => setState(() => setting = val),
                icon: Icons.location_on,
              ),
              _buildStyledDropdown(
                label: 'طول القصة',
                options: lengths,
                value: length,
                onChanged: (val) => setState(() => length = val),
                icon: Icons.text_fields,
              ),
              _buildStyledDropdown(
                label: 'الهدف التعليمي',
                options: goals,
                value: goal,
                onChanged: (val) => setState(() => goal = val),
                icon: Icons.school,
              ),

              // Optional Section
              _buildOptionalSection(),

              // Generate Button
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_fix_high, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        "توليد القصة",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}