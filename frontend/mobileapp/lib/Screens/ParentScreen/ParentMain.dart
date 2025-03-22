import 'package:flutter/material.dart';
import 'package:mobileapp/Screens/ParentScreen/NavBarParent.dart';
import '../../generated/l10n.dart';
import '../../models/parent.dart';
import 'ParentHome.dart';

class ParentMain extends StatefulWidget {
  final Parent? parent;
  final Function(Locale) onLocaleChange;

  const ParentMain({super.key, this.parent, required this.onLocaleChange});

  @override
  _ParentMainState createState() => _ParentMainState();
}

class _ParentMainState extends State<ParentMain> {
  // List of Days
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Widget _selectedScreen; // Declare without initialization

  @override
  void initState() {
    super.initState();
    _selectedScreen = HomeScreen(parent: widget.parent!); // Initialize in initState()
  }

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
      key: _scaffoldKey,
      drawer: NavBarParent(
          parent: widget.parent!,
          onSelectScreen: _navigateTo,
          onLocaleChange: widget.onLocaleChange,
      ),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black87, // Match with the illustration background
        elevation: 0, // Removes shadow for a seamless look
        title: Text("${widget.parent!.name} ${S.of(context).dashboard_title}",style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white
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


