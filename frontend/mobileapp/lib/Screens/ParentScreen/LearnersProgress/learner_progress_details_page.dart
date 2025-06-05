import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/dailyAttempts/learner_daily_attempts.dart';

class LearnerProgressDetailsPage extends StatefulWidget {
  final String learnerName;
  final String username;
  final List<Word> correctWords;
  final List<Word> incorrectWords;
  final List<Letter> correctLetters;
  final List<Letter> incorrectLetters;
  final List<Sentence> correctSentences;
  final List<Sentence> incorrectSentences;
  final List<Map<String, dynamic>> gameAttempts;

  const LearnerProgressDetailsPage({
    required this.learnerName,
    required this.username,
    required this.correctWords,
    required this.incorrectWords,
    required this.correctLetters,
    required this.incorrectLetters,
    required this.correctSentences,
    required this.incorrectSentences,
    required this.gameAttempts,
    super.key,
  });

  @override
  State<LearnerProgressDetailsPage> createState() => _LearnerProgressDetailsPageState();
}

class _LearnerProgressDetailsPageState extends State<LearnerProgressDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    print(widget.correctLetters);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCorrect = widget.correctWords.length + widget.correctLetters.length;
    final totalIncorrect = widget.incorrectWords.length + widget.incorrectLetters.length;
    final total = totalCorrect + totalIncorrect;
    final accuracy = total > 0 ? (totalCorrect / total * 100).round() : 0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: Text(
          "${widget.learnerName}'s Progress",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: Column(
        children: [
          // Stats Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: Text(
                        widget.learnerName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.learnerName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "@${widget.username}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getAccuracyColor(accuracy).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "$accuracy% Accuracy",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getAccuracyColor(accuracy),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickStat("Total Attempts", total.toString(), Colors.blue),
                    ),
                    Expanded(
                      child: _buildQuickStat("Correct", totalCorrect.toString(), Colors.green),
                    ),
                    Expanded(
                      child: _buildQuickStat("Incorrect", totalIncorrect.toString(), Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Navigation
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: "Words"),
                Tab(text: "Letters"),
                Tab(text: "Sentences"),
                Tab(text: "Games"),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Words Tab
                _buildTabContent([
                  _buildSection("Correct Words", widget.correctWords, Colors.green, false, false),
                  _buildSection("Incorrect Words", widget.incorrectWords, Colors.red, false, true),
                ]),
                // Letters Tab
                _buildTabContent([
                  _buildSection("Correct Letters", widget.correctLetters, Colors.green, true, false),
                  _buildSection("Incorrect Letters", widget.incorrectLetters, Colors.red, true, true),
                ]),
                _buildTabContent([
                  _buildSection("Correct Sentences", widget.correctSentences, Colors.green, true, false),
                  _buildSection("Incorrect Sentences", widget.incorrectSentences, Colors.red, true, true),
                ]),
                _buildGameAttemptsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccuracyColor(int accuracy) {
    if (accuracy >= 80) return Colors.green;
    if (accuracy >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSection(String title, List<dynamic> items, Color color, bool isLetter, bool showCorrect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(
                showCorrect ? Icons.cancel : Icons.check_circle,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  items.length.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  "No ${title.toLowerCase()} recorded",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        else
          _buildItemsList(items, isLetter, showCorrect),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildItemsList(List<dynamic> items, bool isLetter, bool showCorrect) {
    return Column(
      children: items.map((item) {
        String? spoken = isLetter ? item.spokenLetter ?? "" : item.spokenWord ?? "";
        String? correct = isLetter ? item.correctLetter : item.correctWord;
        spoken = (spoken == "") ? correct : spoken;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: showCorrect
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    showCorrect ? Icons.close : Icons.check,
                    color: showCorrect ? Colors.red : Colors.green,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: showCorrect
                      ? Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            spoken!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      if (correct != null && correct != spoken) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.arrow_forward, color: Colors.grey[400], size: 16),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              correct,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ]
                    ],
                  )
                      : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      correct!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGameAttemptsSection() {
    if (widget.gameAttempts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videogame_asset_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                "No game attempts recorded",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.gameAttempts.length,
      itemBuilder: (context, index) {
        final attempt = widget.gameAttempts[index];
        final title = attempt['gameName'] ?? 'Game';
        final score = attempt['score']?.toString() ?? '-';
        final timestamp = attempt['timestamp'] != null
            ? DateTime.tryParse(attempt['timestamp'])?.toLocal().toString().split('.')[0]
            : 'Unknown time';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.videogame_asset, color: Colors.blue[400]),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Score: $score"),
                    Text("Played on: $timestamp", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
