import 'package:flutter/material.dart';
import 'package:mobileapp/Screens/ParentScreen/LearnerDetails.dart';
import 'package:mobileapp/Screens/ParentScreen/ParentMain.dart';

import '../../Services/auth_service.dart';
import '../../generated/l10n.dart';
import '../../models/parent.dart';
import 'ParentHome.dart';
import 'ProgressDetails.dart';

class NavBarParent extends StatefulWidget {

  final Parent? parent;
  final Function(Widget) onSelectScreen; // Callback function

  const NavBarParent({super.key, required this.parent, required this.onSelectScreen});

  @override
  State<NavBarParent> createState() => _NavBarParentState();
}

class _NavBarParentState extends State<NavBarParent> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 5,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(widget.parent!.name),
            accountEmail: Text(widget.parent!.email),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset('assets/images/child2.png'),
              ),
            ),
            decoration: const BoxDecoration(
              color: Colors.black87,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(S.of(context).ParentNavBarHome),
            onTap: () => widget.onSelectScreen(HomeScreen(parent: widget.parent!,)), // Update content
          ),
          const Divider(),
          // ListTile(
          //   leading: const Icon(Icons.people),
          //   title: const Text("Learners Progress"),
          //   onTap: () => widget.onSelectScreen(ProgressDetails(parent: widget.parent,)), // Change content
          // ),
          // const Divider(),
          // ListTile(
          //   leading: const Icon(Icons.people),
          //   title: const Text("Learners Members"),
          //   onTap: () => widget.onSelectScreen(LearnerDetails(parent: widget.parent,)), // Change content
          // ),
          // const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              AuthService.logoutParent(context);
            },
          )
        ],
      ),
    );
  }
}

// class ChildrenScreen extends StatelessWidget {
//   const ChildrenScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Center(child: Text("Children Screen"));
//   }
// }

