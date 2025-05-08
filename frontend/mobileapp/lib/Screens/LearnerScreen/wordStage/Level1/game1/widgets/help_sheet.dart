import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../../Services/tts_service.dart';

class HelpSheet extends StatelessWidget {
  HelpSheet({super.key});

  final TTSService flutterTts = TTSService();

  // Arabic instructions to be spoken
  final String instructions = '''
كيفية اللعب:
اسحب الحروف إلى الفراغات لتكوين الكلمة.
إذا كانت الكلمة صحيحة، سيتم عرض مرادفاتها.
اسحب المرادف الصحيح إلى المنطقة المخصصة.
انقر على زر التالي للانتقال إلى الكلمة التالية.
''';

  Future<void> _speakInstructions() async {
    await flutterTts.setLanguage("ar-SA"); // Arabic
    await flutterTts.speak(instructions);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "كيفية اللعب",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7F73FF),
            ),
          ),
          const SizedBox(height: 16),
          const ListTile(
            leading: Icon(Icons.drag_indicator, color: Color(0xFF7F73FF)),
            title: Text("اسحب الحروف إلى الفراغات لتكوين الكلمة"),
          ),
          const ListTile(
            leading: Icon(Icons.sync, color: Color(0xFF7F73FF)),
            title: Text("إذا كانت الكلمة صحيحة، سيتم عرض مرادفاتها"),
          ),
          const ListTile(
            leading: Icon(Icons.compare_arrows, color: Color(0xFF7F73FF)),
            title: Text("اسحب المرادف الصحيح إلى المنطقة المخصصة"),
          ),
          const ListTile(
            leading: Icon(Icons.arrow_forward, color: Color(0xFF7F73FF)),
            title: Text("انقر على زر التالي للانتقال إلى الكلمة التالية"),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _speakInstructions,
            icon: const Icon(Icons.volume_up),
            label: const Text("الاستماع إلى التعليمات", style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7F73FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final player = AudioPlayer();
              player.setSource(AssetSource('sounds/click.mp3'));
              player.resume();

              flutterTts.stop();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7F73FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text("فهمت!", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}