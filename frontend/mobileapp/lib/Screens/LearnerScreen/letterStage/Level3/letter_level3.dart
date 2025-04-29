import 'package:flutter/material.dart';
import 'dart:math';

class LetterLevel3 extends StatefulWidget {
  const LetterLevel3({super.key});

  @override
  State<LetterLevel3> createState() => _LetterLevel3State();
}

class _LetterLevel3State extends State<LetterLevel3> {
  final Map<String, List<String>> letterForms = {
    'ا': ['ا', 'ا', 'ـا', 'ـا'],
    'ب': ['ب', 'بـ', 'ـبـ', 'ـب'],
    'ت': ['ت', 'تـ', 'ـتـ', 'ـت'],
    'ث': ['ث', 'ثـ', 'ـثـ', 'ـث'],
    'ج': ['ج', 'جـ', 'ـجـ', 'ـج'],
    'ح': ['ح', 'حـ', 'ـحـ', 'ـح'],
    'خ': ['خ', 'خـ', 'ـخـ', 'ـخ'],
    'د': ['د', 'د', 'ـد', 'ـد'],
    'ذ': ['ذ', 'ذ', 'ـذ', 'ـذ'],
    'ر': ['ر', 'ر', 'ـر', 'ـر'],
    'ز': ['ز', 'ز', 'ـز', 'ـز'],
    'س': ['س', 'سـ', 'ـسـ', 'ـس'],
    'ش': ['ش', 'شـ', 'ـشـ', 'ـش'],
    'ص': ['ص', 'صـ', 'ـصـ', 'ـص'],
    'ض': ['ض', 'ضـ', 'ـضـ', 'ـض'],
    'ط': ['ط', 'طـ', 'ـطـ', 'ـط'],
    'ظ': ['ظ', 'ظـ', 'ـظـ', 'ـظ'],
    'ع': ['ع', 'عـ', 'ـعـ', 'ـع'],
    'غ': ['غ', 'غـ', 'ـغـ', 'ـغ'],
    'ف': ['ف', 'فـ', 'ـفـ', 'ـف'],
    'ق': ['ق', 'قـ', 'ـقـ', 'ـق'],
    'ك': ['ك', 'كـ', 'ـكـ', 'ـك'],
    'ل': ['ل', 'لـ', 'ـلـ', 'ـل'],
    'م': ['م', 'مـ', 'ـمـ', 'ـم'],
    'ن': ['ن', 'نـ', 'ـنـ', 'ـن'],
    'ه': ['ه', 'هـ', 'ـهـ', 'ـه'],
    'و': ['و', 'و', 'ـو', 'ـو'],
    'ي': ['ي', 'يـ', 'ـيـ', 'ـي'],
  };

  final List<String> arabicLetters = [
    'ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د',
    'ذ', 'ر', 'ز', 'س', 'ش', 'ص', 'ض', 'ط',
    'ظ', 'ع', 'غ', 'ف', 'ق', 'ك', 'ل', 'م',
    'ن', 'ه', 'و', 'ي'
  ];

  late String currentLetter;
  late List<String> draggableForms;
  Map<String, String?> droppedForms = {
    'منفصل': null,
    'متصل': null,
    'نهائي': null,
  };

  @override
  void initState() {
    super.initState();
    _loadNewLetter();
  }

  void _loadNewLetter() {
    final random = Random();
    final selected = arabicLetters[random.nextInt(arabicLetters.length)];
    final forms = letterForms[selected]!;

    setState(() {
      currentLetter = selected;
      draggableForms = [forms[0], forms[2], forms[3]]; // منفصل, متصل, نهائي
      draggableForms.shuffle(); // Randomize the draggable items
      droppedForms = {
        'منفصل': null,
        'متصل': null,
        'نهائي': null,
      };
    });
  }

  void _checkResult() {
    final forms = letterForms[currentLetter]!;

    if (droppedForms['منفصل'] == forms[0] &&
        droppedForms['متصل'] == forms[2] &&
        droppedForms['نهائي'] == forms[3]) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أحسنت! 🎉', style: TextStyle(fontSize: 24)),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(seconds: 2), _loadNewLetter);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حاول مرة أخرى ❌', style: TextStyle(fontSize: 20)),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المستوى الثالث', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6C63FF),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Big Letter
            Text(
              currentLetter,
              style: const TextStyle(fontSize: 90, fontWeight: FontWeight.bold, color: Color(0xFF6C63FF)),
            ),
            const SizedBox(height: 30),
            // Draggables
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: draggableForms.map((form) => buildDraggable(form)).toList(),
            ),
            const SizedBox(height: 40),
            // Drop Targets
            Expanded(
              child: Column(
                children: [
                  buildDropTarget('منفصل'),
                  const SizedBox(height: 20),
                  buildDropTarget('متصل'),
                  const SizedBox(height: 20),
                  buildDropTarget('نهائي'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _checkResult,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text('تحقق', style: TextStyle(fontSize: 24, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDraggable(String form) {
    return Draggable<String>(
      data: form,
      feedback: Material(
        color: Colors.transparent,
        child: Text(
          form,
          style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
      ),
      childWhenDragging: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        child: const Text(''),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          form,
          style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildDropTarget(String label) {
    return DragTarget<String>(
      onAccept: (data) {
        setState(() {
          droppedForms[label] = data;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: 80,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(
              color: candidateData.isNotEmpty ? Colors.blue : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            '${label}: ${droppedForms[label] ?? ''}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
