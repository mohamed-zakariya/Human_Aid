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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2D3436),
              Color(0xFF636E72),
            ],
          ),
        ),
        child: Column(
          children: [
            // Enhanced Header Section
            _buildEnhancedHeader(),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  _buildNavItem(
                    icon: Icons.home_rounded,
                    title: S.of(context).ParentNavBarHome,
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      widget.onSelectScreen(HomeScreen(parent: widget.parent!));
                    },
                    gradient: [
                      const Color(0xFF667eea),
                      const Color(0xFF764ba2)
                    ],
                  ),

                  const SizedBox(height: 8),

                  _buildNavItem(
                    icon: Icons.people_rounded,
                    title: "Learner Members",
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      widget.onSelectScreen(LearnerDetails(parent: widget.parent));
                    },
                    gradient: [
                      const Color(0xFFf093fb),
                      const Color(0xFFf5576c)
                    ],
                  ),

                  const SizedBox(height: 8),

                  _buildNavItem(
                    icon: Icons.trending_up_rounded,
                    title: "Learners Progress",
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      widget.onSelectScreen(ProgressDetails(parent: widget.parent));
                    },
                    gradient: [
                      const Color(0xFF4facfe),
                      const Color(0xFF00f2fe)
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Divider
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildNavItem(
                    icon: Icons.settings_rounded,
                    title: S.of(context).ParentNavBarSettings,
                    onTap: () {
                      Navigator.pop(context); // Close drawer first
                      _showEnhancedLanguageDialog(context);
                    },
                    gradient: [
                      const Color(0xFFa8edea),
                      const Color(0xFFfed6e3)
                    ],
                  ),

                  const SizedBox(height: 8),

                  _buildNavItem(
                    icon: Icons.logout_rounded,
                    title: S.of(context).ParentNavBarLogout,
                    onTap: () {
                      Navigator.pop(context); // Close drawer first
                      _showLogoutDialog(context);
                    },
                    gradient: [
                      const Color(0xFFfd79a8),
                      const Color(0xFFfdcb6e)
                    ],
                    isDestructive: true,
                  ),
                ],
              ),
            ),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Profile Picture with animated border
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667eea),
                  const Color(0xFF764ba2),
                ],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/images/child2.png'),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Name
          Text(
            widget.parent!.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          // Email
          Text(
            widget.parent!.email,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
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
    required List<Color> gradient,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  gradient[0].withOpacity(0.1),
                  gradient[1].withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: gradient[0].withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? Colors.red[300]
                          : Colors.white,
                    ),
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
          Text(
            "Learning App v2.0",
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showEnhancedLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.language,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Choose Language",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Intl.getCurrentLocale() == 'ar'
                    ? _buildLanguageOption(
                  flag: 'assets/arcades/flags/usa.png',
                  language: 'English',
                  onTap: () => _changeLanguage(context),
                )
                    : _buildLanguageOption(
                  flag: 'assets/arcades/flags/egypt.png',
                  language: 'العربية',
                  onTap: () => _changeLanguage(context),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          S.of(context).cancel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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

  Widget _buildLanguageOption({
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
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
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
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white.withOpacity(0.7),
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
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFfd79a8),
                  Color(0xFFfdcb6e),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Logout Confirmation",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Are you sure you want to logout?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white,
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
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFfd79a8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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