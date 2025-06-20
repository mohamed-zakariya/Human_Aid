import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../widgets/language_toggle_icon.dart';

class IntroScreen extends StatelessWidget {
  final Function(Locale) onLocaleChange;

  const IntroScreen({super.key, required this.onLocaleChange});

  @override
  Widget build(BuildContext context) {
    final isRTL = Localizations.localeOf(context).languageCode == 'ar';
    final textAlign = isRTL ? TextAlign.right : TextAlign.left;
    final crossAxisAlignment = isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE3F2FD),
              Color(0xFFF3E5F5),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced App Bar
              _buildAppBar(context),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40.0 : 20.0,
                      vertical: 1.0,
                    ),
                    child: Column(
                      children: [
                        // Enhanced Title
                        _buildTitle(context, textAlign, isTablet),

                        SizedBox(height: screenHeight * 0.02),

                        // Registration Options
                        if (isTablet)
                          _buildTabletLayout(context, crossAxisAlignment, textAlign, screenHeight)
                        else
                          _buildMobileLayout(context, crossAxisAlignment, textAlign, screenHeight),

                        SizedBox(height: screenHeight * 0.02),

                        // Enhanced Buttons
                        _buildActionButtons(context, isTablet),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App Logo or Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              S.of(context).welcome,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E3440),
              ),
            ),
          ),

          // Enhanced Language Toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: LanguageToggleIcon(onLocaleChange: onLocaleChange),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, TextAlign textAlign, bool isTablet) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Text(
            S.of(context).introTitle,
            style: TextStyle(
              fontSize: isTablet ? 32 : 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E3440),
              letterSpacing: 0.5,
            ),
            textAlign: textAlign,
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            width: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, CrossAxisAlignment crossAxisAlignment,
      TextAlign textAlign, double screenHeight) {
    return Column(
      children: [
        _buildEnhancedRegistrationOption(
          context: context,
          image: 'assets/images/guardian.png',
          title: S.of(context).guardianTitle,
          description: S.of(context).guardianDescription,
          maxHeight: screenHeight * 0.28,
          crossAxisAlignment: crossAxisAlignment,
          textAlign: textAlign,
          gradientColors: const [Color(0xFFFFE0E6), Color(0xFFFFB3C1)],
          iconColor: const Color(0xFFE91E63),
        ),
        SizedBox(height: screenHeight * 0.03),
        _buildEnhancedRegistrationOption(
          context: context,
          image: 'assets/images/user.png',
          title: S.of(context).userTitle,
          description: S.of(context).userDescription,
          maxHeight: screenHeight * 0.28,
          crossAxisAlignment: crossAxisAlignment,
          textAlign: textAlign,
          gradientColors: const [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
          iconColor: const Color(0xFF009688),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, CrossAxisAlignment crossAxisAlignment,
      TextAlign textAlign, double screenHeight) {
    return Row(
      children: [
        Expanded(
          child: _buildEnhancedRegistrationOption(
            context: context,
            image: 'assets/images/guardian.png',
            title: S.of(context).guardianTitle,
            description: S.of(context).guardianDescription,
            maxHeight: screenHeight * 0.35,
            crossAxisAlignment: crossAxisAlignment,
            textAlign: textAlign,
            gradientColors: const [Color(0xFFFFE0E6), Color(0xFFFFB3C1)],
            iconColor: const Color(0xFFE91E63),
            isTablet: true,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildEnhancedRegistrationOption(
            context: context,
            image: 'assets/images/user.png',
            title: S.of(context).userTitle,
            description: S.of(context).userDescription,
            maxHeight: screenHeight * 0.35,
            crossAxisAlignment: crossAxisAlignment,
            textAlign: textAlign,
            gradientColors: const [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
            iconColor: const Color(0xFF009688),
            isTablet: true,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isTablet) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: _buildEnhancedButton(
              context: context,
              text: S.of(context).guardianButton,
              onPressed: () => Navigator.pushNamed(context, '/login_gaurdian'),
              gradient: const LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
              ),
              icon: Icons.family_restroom,
              isTablet: isTablet,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildEnhancedButton(
              context: context,
              text: S.of(context).userButton,
              onPressed: () => Navigator.pushNamed(context, '/login_user'),
              gradient: const LinearGradient(
                colors: [Color(0xFF009688), Color(0xFF00695C)],
              ),
              icon: Icons.person,
              isTablet: isTablet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    required Gradient gradient,
    required IconData icon,
    required bool isTablet,
  }) {
    return Container(
      height: isTablet ? 56 : 50,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: isTablet ? 24 : 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedRegistrationOption({
    required BuildContext context,
    required String image,
    required String title,
    required String description,
    required double maxHeight,
    required CrossAxisAlignment crossAxisAlignment,
    required TextAlign textAlign,
    required List<Color> gradientColors,
    required Color iconColor,
    bool isTablet = false,
  }) {
    return Container(
      height: maxHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            gradientColors.first.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: isTablet ? -20 : -10,
              top: isTablet ? -20 : -10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: isTablet
                  ? _buildTabletOptionContent(image, title, description, crossAxisAlignment, textAlign, iconColor)
                  : _buildMobileOptionContent(image, title, description, crossAxisAlignment, textAlign, iconColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileOptionContent(String image, String title, String description,
      CrossAxisAlignment crossAxisAlignment, TextAlign textAlign, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Image section
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: iconColor,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Text section
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: crossAxisAlignment,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E3440),
                    letterSpacing: 0.3,
                  ),
                  textAlign: textAlign,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                    letterSpacing: 0.2,
                  ),
                  textAlign: textAlign,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletOptionContent(String image, String title, String description,
      CrossAxisAlignment crossAxisAlignment, TextAlign textAlign, Color iconColor) {
    return Column(
      children: [
        // Image section
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: iconColor,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Text section
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: crossAxisAlignment,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3440),
                    letterSpacing: 0.3,
                  ),
                  textAlign: textAlign,
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.4,
                      letterSpacing: 0.2,
                    ),
                    textAlign: textAlign,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}