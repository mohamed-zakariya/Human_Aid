import 'package:flutter/material.dart';

class LearnerProgressDetailsPage extends StatelessWidget {
  final String learnerName;
  final String username;
  final List<Map<String, String>> correctWords;
  final List<Map<String, String>> incorrectWords;

  const LearnerProgressDetailsPage({
    super.key,
    required this.learnerName,
    required this.username,
    required this.correctWords,
    required this.incorrectWords,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: Text("$learnerName's Progress"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // ✅ Enables scrolling if content is too long
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Correct Words",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 8),
              correctWords.isNotEmpty
                  ? ListView.builder( // ✅ Efficient and scrollable
                shrinkWrap: true, // ✅ Prevents infinite height issue
                physics: const NeverScrollableScrollPhysics(), // ✅ Keeps scrolling only on parent
                itemCount: correctWords.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(correctWords[index]["spoken_word"] ?? ""),
                  );
                },
              )
                  : const Text("No correct words recorded", style: TextStyle(color: Colors.grey)),

              const SizedBox(height: 20),

              const Text(
                "Incorrect Words",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 8),
              incorrectWords.isNotEmpty
                  ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: incorrectWords.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.cancel, color: Colors.red),
                    title: Text(incorrectWords[index]["spoken_word"] ?? ""),
                  );
                },
              )
                  : const Text("No incorrect words recorded", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
