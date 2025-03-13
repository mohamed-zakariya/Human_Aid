import 'package:flutter/material.dart';
import 'package:mobileapp/Screens/ParentScreen/ProgressDetails.dart';
import 'package:mobileapp/Screens/ParentScreen/NavBarParent.dart';
import '../../models/parent.dart';
import 'ChildCard.dart';

class Parenthome extends StatefulWidget {
  final Parent? parent;

  const Parenthome({super.key, this.parent});

  @override
  _ParenthomeState createState() => _ParenthomeState();
}

class _ParenthomeState extends State<Parenthome> {
  // List of Days
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Widget _selectedScreen = const HomeScreen(); // Default screen

  void _navigateTo(Widget screen) {
    setState(() {
      _selectedScreen = screen;
    });
    Navigator.pop(context); // Close the drawer smoothly
  }

  @override
  Widget build(BuildContext context) {

    final double screenHeight = MediaQuery.of(context).size.height;


    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      drawer: NavBarParent(
          parent: widget.parent!,
          onSelectScreen: _navigateTo,
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Match with the illustration background
        elevation: 0, // Removes shadow for a seamless look
        title: Text("${widget.parent!.name} Dashboard",style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),),
        centerTitle: true,
      ),
      body: Column(
          children: [
            // Top Half: Illustration & Background
            Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)
                  )
              ),
            ),

            // Bottom Half: Calendar + Event Cards
            Expanded(
                child: _selectedScreen,
            )
          ]
      )
    );
  }
}


