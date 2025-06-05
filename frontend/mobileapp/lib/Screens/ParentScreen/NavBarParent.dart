import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/Screens/ParentScreen/learnerMembersTab/LearnerDetails.dart';
import 'package:mobileapp/Screens/ParentScreen/ParentMain.dart';

import '../../Services/auth_service.dart';
import '../../generated/l10n.dart';
import '../../models/parent.dart';
import 'ParentHome.dart';
import 'LearnersProgress/ProgressDetails.dart';

class NavBarParent extends StatefulWidget {
  final Parent? parent;
  final Function(Widget) onSelectScreen;
  final Function(Locale) onLocaleChange;

  const NavBarParent({
    super.key,
    required this.parent,
    required this.onSelectScreen,
    required this.onLocaleChange,
  });

  @override
  State<NavBarParent> createState() => _NavBarParentState();
}

class _NavBarParentState extends State<NavBarParent>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Modern Header Section
            _buildModernHeader(),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                children: [
                  _buildNavItem(
                    icon: Icons.home_rounded,
                    title: S.of(context).ParentNavBarHome,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onSelectScreen(HomeScreen(parent: widget.parent!));
                    },
                    color: const Color(0xFF6C63FF),
                  ),

                  const SizedBox(height: 12),

                  _buildNavItem(
                    icon: Icons.people_rounded,
                    title: "Learner Members",
                    onTap: () {
                      Navigator.pop(context);
                      widget.onSelectScreen(LearnerDetails(parent: widget.parent));
                    },
                    color: const Color(0xFFFF6B9D),
                  ),

                  const SizedBox(height: 12),

                  _buildNavItem(
                    icon: Icons.trending_up_rounded,
                    title: "Learners Progress",
                    onTap: () {
                      Navigator.pop(context);
                      widget.onSelectScreen(ProgressDetails(parent: widget.parent));
                    },
                    color: const Color(0xFF4ECDC4),
                  ),

                  const SizedBox(height: 24),

                  // Subtle Divider
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    color: const Color(0xFFF0F0F0),
                  ),

                  const SizedBox(height: 24),

                  _buildNavItem(
                    icon: Icons.settings_rounded,
                    title: S.of(context).ParentNavBarSettings,
                    onTap: () {
                      Navigator.pop(context);
                      _showModernLanguageDialog(context);
                    },
                    color: const Color(0xFF95A5A6),
                  ),

                  const SizedBox(height: 12),

                  _buildNavItem(
                    icon: Icons.logout_rounded,
                    title: S.of(context).ParentNavBarLogout,
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutDialog(context);
                    },
                    color: const Color(0xFFFF6B6B),
                    isDestructive: true,
                  ),
                ],
              ),
            ),

            // Modern Footer
            _buildModernFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF0F0F0),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Modern Profile Picture
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF6C63FF),
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage('assets/images/child2.png'),
            ),
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            widget.parent!.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),

          const SizedBox(height: 4),

          // Email
          Text(
            widget.parent!.email,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? const Color(0xFFFF6B6B)
                          : const Color(0xFF2C3E50),
                    ),
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: const Color(0xFFBDC3C7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFF0F0F0),
            width: 1,
          ),
        ),
      ),
      child: const Text(
        "Learning App v2.0",
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFFBDC3C7),
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _showModernLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.language,
                        color: Color(0xFF6C63FF),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Choose Language",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Intl.getCurrentLocale() == 'ar'
                    ? _buildModernLanguageOption(
                  flag: 'assets/arcades/flags/usa.png',
                  language: 'English',
                  onTap: () => _changeLanguage(context),
                )
                    : _buildModernLanguageOption(
                  flag: 'assets/arcades/flags/egypt.png',
                  language: 'العربية',
                  onTap: () => _changeLanguage(context),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF8F9FA),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      S.of(context).cancel,
                      style: const TextStyle(
                        color: Color(0xFF6C757D),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernLanguageOption({
    required String flag,
    required String language,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE9ECEF),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  flag,
                  width: 32,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  language,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFFBDC3C7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _changeLanguage(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);
    final newLocale = currentLocale.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
    widget.onLocaleChange(newLocale);
    Navigator.pop(context);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFFF6B6B),
                    size: 32,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Logout Confirmation",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Are you sure you want to logout?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7F8C8D),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF8F9FA),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Color(0xFF6C757D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          AuthService.logoutParent(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Logout",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}