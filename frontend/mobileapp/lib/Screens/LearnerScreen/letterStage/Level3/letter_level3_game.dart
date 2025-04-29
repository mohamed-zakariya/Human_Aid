import 'package:flutter/material.dart';
import 'dart:math';

class LetterLevel3Game extends StatefulWidget {
  const LetterLevel3Game({super.key});

  @override
  State<LetterLevel3Game> createState() => _LetterLevel3GameState();
}

class _LetterLevel3GameState extends State<LetterLevel3Game> {
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
          foregroundColor: Colors.white,
          title: const Text(
            '✏️ المستوى الثالث',
            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF6C63FF),
          centerTitle: true,
          elevation: 10,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
        ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Big Letter
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: Text(
                currentLetter,
                style: const TextStyle(
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C63FF),
                ),
              ),
            ),
            // Draggables
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: draggableForms.map((form) => buildDraggable(form)).toList(),
            ),
            const SizedBox(height: 20),
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
        child: buildDraggableLetter(form, isDragging: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: buildDraggableLetter(form),
      ),
      child: buildDraggableLetter(form),
    );
  }

  Widget buildDraggableLetter(String form, {bool isDragging = false}) {
    return Container(
      width: 80,
      height: 80,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDragging ? Colors.blueAccent.withOpacity(0.5) : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        form,
        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black87),
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
          height: 100,
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: candidateData.isNotEmpty ? Colors.blueAccent : Colors.grey.shade300,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                '$label:',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  droppedForms[label] ?? '',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
