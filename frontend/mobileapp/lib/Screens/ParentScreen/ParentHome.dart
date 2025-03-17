  import 'package:flutter/material.dart';
  import 'package:mobileapp/Screens/ParentScreen/LearnerDetails.dart';
import 'package:mobileapp/Screens/ParentScreen/ProgressDetails.dart';
import 'package:mobileapp/global/fns.dart';
  import 'package:mobileapp/models/parent.dart';

  class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key, required this.parent});

    final Parent parent;

    @override
    State<HomeScreen> createState() => _HomeScreenState();
  }

  Parent? parent;

  class _HomeScreenState extends State<HomeScreen> {

    @override
    void initState() {
      // TODO: implement initState
      super.initState();
      parent = widget.parent;
    }

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introductory Section
            _buildIntroSection(),

            const SizedBox(height: 20),

            // Title
            const Text(
              "Categories",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 15),

            // Organized Grid Layout
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85, // Adjusted to fit button
                ),
                itemCount: categoryItems.length,
                itemBuilder: (context, index) {
                  return _buildGridItem(
                    context,
                    categoryItems[index]
                    ,
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildIntroSection() {
      return SizedBox(
        width: double.infinity, // Takes full width of the screen
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage("assets/images/guardianhome.png"),
              fit: BoxFit.cover,
              opacity: 0.5,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage("assets/images/boy.jpeg",),
              ),
              SizedBox(height: 15), // Fixed spacing issue
              Text(
                "Welcome Back, Mohamed!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Let's explore some insights today",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildGridItem(
        BuildContext context, Map<String, dynamic> item) {
      Color buttonColor = darkenColor(item['color'], 0.2); // Darken button color by 20%

      return Container(
        decoration: BoxDecoration(
          color: item['color'],
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              spreadRadius: 2,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(item['imagePath'], fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                createRouteParentHome(item['screen']),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(item['title']), // Button text is now the category title
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    }
  }

  // Function to darken a color
  Color darkenColor(Color color, double factor) {
    return Color.fromRGBO(
      (color.red * (1 - factor)).round(),
      (color.green * (1 - factor)).round(),
      (color.blue * (1 - factor)).round(),
      1,
    );
  }

  final List<Map<String, dynamic>> categoryItems = [
    {"title": "Tips", "imagePath": "assets/images/tips.png", "color": Colors.white, "screen": () => const TipsScreen()},
    {"title": "Learner Members", "imagePath": "assets/images/LearnerMembers.png", "color": Colors.deepOrangeAccent.shade100, "screen": () => LearnerDetails(parent: parent)},
    {"title": "Add Word", "imagePath": "assets/images/addWord.jpg", "color": const Color(0xFFBCEFEA), "screen": () => const AddWordScreen()},
    {"title": "Learner Progress", "imagePath": "assets/images/progress2.png", "color": const Color(0xFFE5DDD2), "screen": () => ProgressDetails(parent: parent)},
  ];


  // Dummy Screens for Each Category
  class TipsScreen extends StatelessWidget { const TipsScreen({super.key}); @override Widget build(BuildContext context) => _buildScreen(context, "Tips"); }
  class AddWordScreen extends StatelessWidget { const AddWordScreen({super.key}); @override Widget build(BuildContext context) => _buildScreen(context, "Add Word"); }

  Widget _buildScreen(BuildContext context, String title) {
    return Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text("Welcome to $title Page", style: const TextStyle(fontSize: 24))));
  }

