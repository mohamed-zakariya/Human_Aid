import 'package:flutter/material.dart';
import 'package:mobileapp/models/learner.dart';

class LearnerRewards extends StatelessWidget {
  const LearnerRewards({super.key, required this.learner});

  final Learner? learner;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // _buildTargetPracticeCard(),
          const SizedBox(height: 20),
          _buildListItem(
            title: "Conversation",
            subtitle: "Listen and improve your verbal skills",
            imagePath: "assets/arcades/charaters/joker-dc.png",
            points: 24,
            progress: 100,
            color: Colors.green
          ),
          _buildListItem(
            title: "Your collections",
            subtitle: "Review and correct your mistakes",
            imagePath: "assets/arcades/charaters/batman.png",
            points: 20,
            progress: 100,
            color: Colors.blue
          ),
          _buildListItem(
            title: "Words",
            subtitle: "Expand your vocabulary by listening",
            imagePath: "assets/arcades/charaters/knight-helmet.png",
            points: 12,
            progress: 100,
            color: Colors.redAccent
          ),
          _buildListItem(
              title: "Words",
              subtitle: "Expand your vocabulary by listening",
              imagePath: "assets/arcades/charaters/flash-head.png",
              points: 12,
              progress: 20,
              color: Colors.purple
          ),
          _buildListItem(
              title: "Words",
              subtitle: "Expand your vocabulary by listening",
              imagePath: "assets/arcades/charaters/captain-america.png",
              points: 12,
              progress: 30,
              color: Colors.orange
          ),
          _buildListItem(
              title: "Words",
              subtitle: "Expand your vocabulary by listening",
              imagePath: "assets/arcades/charaters/deadpool.png",
              points: 12,
              progress: 10,
              color: Colors.brown
          ),
          _buildListItem(
              title: "Words",
              subtitle: "Expand your vocabulary by listening",
              imagePath: "assets/arcades/charaters/knight-helmet.png",
              points: 12,
              progress: 0,
              color: Colors.redAccent
          ),
          _buildListItem(
              title: "Words",
              subtitle: "Expand your vocabulary by listening",
              imagePath: "assets/arcades/charaters/knight-helmet.png",
              points: 12,
              progress: 0,
              color: Colors.redAccent
          ),
        ],
      ),
    );
  }

  Widget _buildTargetPracticeCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.green, Colors.yellow]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Target Practice",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            "Tackle weak areas with this customized session.",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {},
            child: const Text("UNLOCK"),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required String title,
    required String subtitle,
    required String imagePath,
    required int points,
    required int progress,
    required Color color
  }) {
    bool isCompleted = progress == 100;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(subtitle, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "+$points",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ColorFiltered(
                    colorFilter: isCompleted
                        ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                        : ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
                    child: Image.asset(
                      imagePath,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey.shade300,
              color: color,
              minHeight: 6,
              borderRadius: BorderRadius.circular(5),
            ),
          ],
        ),
      ),
    );
  }
}