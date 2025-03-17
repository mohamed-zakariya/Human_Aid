import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final Function(Locale) onLocaleChange;

  const NavBarParent({super.key, required this.parent, required this.onSelectScreen, required this.onLocaleChange});

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
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              _showLanguageDialog(context);
            },
          ),
          const Divider(),
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

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final bool isArabic = Intl.getCurrentLocale() == 'ar';

        return AlertDialog(
          title: const Text(
            "choose language", // Use localization if needed
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Intl.getCurrentLocale() == 'ar'?
              ListTile(
                leading: Image.asset('assets/arcades/flags/usa.png', width: 24),
                title: const Text("English"),
                onTap: () {
                  final currentLocale = Localizations.localeOf(context);
                  final newLocale =
                  currentLocale.languageCode == 'en' ? const Locale('ar') : const Locale('en');
                  widget.onLocaleChange(newLocale);
                  Navigator.pop(context); // Close dialog after selection
                },
              ):
              ListTile(
                leading: Image.asset('assets/arcades/flags/egypt.png', width: 24),
                title: const Text("العربية"),
                onTap: () {
                  final currentLocale = Localizations.localeOf(context);
                  final newLocale =
                  currentLocale.languageCode == 'en' ? const Locale('ar') : const Locale('en');
                  widget.onLocaleChange(newLocale);
                  Navigator.pop(context); // Close dialog after selection
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context).cancel), // Use localized "Cancel" text
            ),
          ],
        );
      },
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

