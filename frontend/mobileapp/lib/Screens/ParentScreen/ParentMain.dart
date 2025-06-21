import 'package:flutter/material.dart';
import 'package:mobileapp/Screens/ParentScreen/NavBarParent.dart';
import '../../generated/l10n.dart';
import '../../models/parent.dart';
import 'ParentHome.dart';

class ParentMain extends StatefulWidget {
  final Parent? parent;
  final Function(Locale) onLocaleChange;

  const ParentMain({super.key,required this.parent, required this.onLocaleChange});

  @override
  _ParentMainState createState() => _ParentMainState();
}

class _ParentMainState extends State<ParentMain> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Widget _selectedScreen;

  @override
  void initState() {
    super.initState();
    _selectedScreen = HomeScreen(parent: widget.parent!);
  }

  void _navigateTo(Widget screen) {
    setState(() {
      _selectedScreen = screen;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavBarParent(
        parent: widget.parent!,
        onSelectScreen: _navigateTo,
        onLocaleChange: widget.onLocaleChange,
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: Color(0xFF6C63FF),
                size: 20,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        title: Text(
          widget.parent != null
              ? S.of(context).dashboardTitle(widget.parent!.name)
              : S.of(context).dashboardTitle(""),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF6C63FF),
                size: 20,
              ),
              onPressed: () {
                // Handle notifications
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: _selectedScreen,
      ),
    );
  }
}