import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/Services/auth_service.dart';

import '../../generated/l10n.dart';
import '../../global/fns.dart';
import '../../models/learner.dart';
import '../widgets/language_toggle_icon.dart';

class NavBarLearner extends StatelessWidget {
  const NavBarLearner({super.key, this.learner, required this.onLocaleChange});

  final Learner? learner;
  final Function(Locale) onLocaleChange;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey[900],
            ),
            accountName: Text(learner!.name),
            accountEmail: Text(learner!.username),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset(
                  'assets/images/child2.png',
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(S.of(context).ParentNavBarHome),
            onTap: () {
              Navigator.pushReplacementNamed(
                context,
                '/learnerHome',
                arguments: learner!,
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Children"),
            onTap: () {},
          ),
          const Divider(),
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
          ),
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
                  onLocaleChange(newLocale);
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
                  onLocaleChange(newLocale);
                  Navigator.pop(context); // Close dialog after selection
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("S.of(context).Cancel"), // Use localized "Cancel" text
            ),
          ],
        );
      },
    );
  }
}
