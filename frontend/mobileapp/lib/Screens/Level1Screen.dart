import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Services/hand_api_service.dart';

class Level1Screen extends StatefulWidget {
  @override
  _Level1ScreenState createState() => _Level1ScreenState();
}

class _Level1ScreenState extends State<Level1Screen> {
  final List<String> targetWords = ["ملعقة", "شوكة", "كتاب", "قلم", "كوب", "طبق"];
  String? randomTarget;
  String? predictedObject;
  File? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    pickRandomWord();
  }

  void pickRandomWord() {
    randomTarget = targetWords[Random().nextInt(targetWords.length)];
  }

  String reverseArabic(String input) {
    return input.split('').reversed.join();
  }

  String normalizeArabic(String input) {
    return input
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('\u200F', '')
        .replaceAll('\u200E', '')
        .trim();
  }

  bool normalizeAndCompare(String a, String b) {
    return normalizeArabic(a) == normalizeArabic(b);
  }

  String fixArabicPresentationForms(String input) {
    final replacements = {
      // Alef
      'ﺍ': 'ا', 'ﺎ': 'ا',

      // Beh
      'ﺏ': 'ب', 'ﺑ': 'ب', 'ﺒ': 'ب', 'ﺓ': 'ة',

      // Teh
      'ﺕ': 'ت', 'ﺗ': 'ت', 'ﺘ': 'ت',

      // Theh
      'ﺙ': 'ث', 'ﺛ': 'ث', 'ﺜ': 'ث',

      // Jeem
      'ﺝ': 'ج', 'ﺟ': 'ج', 'ﺠ': 'ج',

      // Hah
      'ﺡ': 'ح', 'ﺣ': 'ح', 'ﺤ': 'ح',

      // Khah
      'ﺥ': 'خ', 'ﺧ': 'خ', 'ﺨ': 'خ',

      // Dal
      'ﺩ': 'د',

      // Thal
      'ﺫ': 'ذ',

      // Reh
      'ﺭ': 'ر',

      // Zain
      'ﺯ': 'ز',

      // Seen
      'ﺱ': 'س', 'ﺳ': 'س', 'ﺴ': 'س',

      // Sheen
      'ﺵ': 'ش', 'ﺷ': 'ش', 'ﺸ': 'ش',

      // Sad
      'ﺹ': 'ص', 'ﺻ': 'ص', 'ﺼ': 'ص',

      // Dad
      'ﺽ': 'ض', 'ﺿ': 'ض', 'ﻀ': 'ض',

      // Tah
      'ﻁ': 'ط', 'ﻃ': 'ط', 'ﻂ': 'ط',

      // Zah
      'ﻅ': 'ظ', 'ﻇ': 'ظ', 'ﻈ': 'ظ',

      // Ain
      'ﻉ': 'ع', 'ﻋ': 'ع', 'ﻌ': 'ع',

      // Ghain
      'ﻍ': 'غ', 'ﻏ': 'غ', 'ﻐ': 'غ',

      // Feh
      'ﻑ': 'ف', 'ﻓ': 'ف', 'ﻔ': 'ف',

      // Qaf
      'ﻕ': 'ق', 'ﻗ': 'ق', 'ﻖ': 'ق',

      // Kaf
      'ﻙ': 'ك', 'ﻛ': 'ك', 'ﻜ': 'ك',

      // Lam
      'ﻝ': 'ل', 'ﻟ': 'ل', 'ﻠ': 'ل',

      // Meem
      'ﻡ': 'م', 'ﻣ': 'م', 'ﻤ': 'م',

      // Noon
      'ﻥ': 'ن', 'ﻧ': 'ن', 'ﻦ': 'ن',

      // Heh
      'ﻩ': 'ه', 'ﻫ': 'ه', 'ﻬ': 'ه',

      // Waw
      'ﻭ': 'و',

      // Yeh
      'ﻱ': 'ي', 'ﻳ': 'ي', 'ﻴ': 'ي', 'ﻯ': 'ى',

      // Hamza
      'ﺀ': 'ء', 'ﺃ': 'أ', 'ﺇ': 'إ', 'ﺆ': 'ؤ', 'ﺌ': 'ئ', 'ﺂ': 'آ',

      // Teh Marbuta
      'ﺓ': 'ة',
    };

    return input.split('').map((char) => replacements[char] ?? char).join();
  }

  Future<void> pickImageAndSend() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
        isLoading = true;
        predictedObject = null;
      });

      final apiService = HandApiService();
      final responseText = await apiService.uploadImage(selectedImage!);

      setState(() {
        isLoading = false;
      });

      try {
        final decoded = json.decode(responseText!);
        final rawObject = decoded['object']?.toString().trim();
        final reversedObject = reverseArabic(rawObject ?? '');
        final normalizedObject = fixArabicPresentationForms(reversedObject);

        print('🔍 predicted: ${normalizedObject.runes.toList()}');
        print('🎯 target   : ${randomTarget!.runes.toList()}');

        setState(() {
          predictedObject = normalizedObject;
        });
      } catch (e) {
        setState(() {
          predictedObject = '❌ خطأ في قراءة النتيجة';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = predictedObject != null &&
        randomTarget != null &&
        normalizeAndCompare(predictedObject!, randomTarget!);

    return Scaffold(
      appBar: AppBar(title: Text("المستوى الأول - التعرف على الكائن")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "الكلمة العشوائية: $randomTarget",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: pickImageAndSend,
              child: Text("📸 اختر صورة"),
            ),
            if (isLoading) ...[
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
            if (selectedImage != null) ...[
              SizedBox(height: 20),
              Image.file(selectedImage!, height: 200),
            ],
            if (predictedObject != null) ...[
              SizedBox(height: 20),
              Text(
                "📊 النتيجة: $predictedObject",
                style: TextStyle(fontSize: 20),
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 10),
              Text(
                isCorrect ? "✅ إجابة صحيحة!" : "❌ حاول مرة أخرى",
                style: TextStyle(
                  color: isCorrect ? Colors.green : Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}
