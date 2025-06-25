import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/parent_service.dart';
import '../../generated/l10n.dart';
import '../../models/parent.dart';

class ProfileParent extends StatefulWidget {
  const ProfileParent({super.key});

  @override
  State<ProfileParent> createState() => _ProfileParentState();
}

class _ProfileParentState extends State<ProfileParent> with TickerProviderStateMixin {
  Parent? parentData;
  bool isLoading = true;
  String? error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _loadParentProfile();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadParentProfile() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Get parent ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? parentId = prefs.getString('userId');

      if (parentId != null) {
        final parent = await ParentService.getParentProfile(parentId);
        setState(() {
          parentData = parent;
          isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          error = "Parent ID not found";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Failed to load profile: $e";
        isLoading = false;
      });
    }
  }

  String _getAvatarImage(String gender) {
    return gender.toLowerCase() == 'male'
        ? 'assets/images/child2.png'
        : 'assets/images/child1.png';
  }

  String _getFlagEmoji(String nationality) {
    // Map of countries to their flag emojis
    final Map<String, String> countryFlags = {
      'egypt': '🇪🇬',
      'united states': '🇺🇸',
      'usa': '🇺🇸',
      'united kingdom': '🇬🇧',
      'uk': '🇬🇧',
      'canada': '🇨🇦',
      'france': '🇫🇷',
      'germany': '🇩🇪',
      'italy': '🇮🇹',
      'spain': '🇪🇸',
      'japan': '🇯🇵',
      'china': '🇨🇳',
      'india': '🇮🇳',
      'brazil': '🇧🇷',
      'australia': '🇦🇺',
      'south africa': '🇿🇦',
      'mexico': '🇲🇽',
      'russia': '🇷🇺',
      'saudi arabia': '🇸🇦',
      'uae': '🇦🇪',
      'turkey': '🇹🇷',
      'greece': '🇬🇷',
      'netherlands': '🇳🇱',
      'sweden': '🇸🇪',
      'norway': '🇳🇴',
      'denmark': '🇩🇰',
      'finland': '🇫🇮',
      'poland': '🇵🇱',
      'portugal': '🇵🇹',
      'argentina': '🇦🇷',
      'chile': '🇨🇱',
      'colombia': '🇨🇴',
      'peru': '🇵🇪',
      'venezuela': '🇻🇪',
      'south korea': '🇰🇷',
      'thailand': '🇹🇭',
      'vietnam': '🇻🇳',
      'philippines': '🇵🇭',
      'indonesia': '🇮🇩',
      'malaysia': '🇲🇾',
      'singapore': '🇸🇬',
    };

    return countryFlags[nationality.toLowerCase()] ?? '🌍';
  }

  String _formatBirthdate(String birthdate) {
    try {
      final timestamp = int.parse(birthdate);
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return birthdate;
    }
  }

  String _getAge(String birthdate) {
    try {
      final timestamp = int.parse(birthdate);
      final birthDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final age = now.year - birthDate.year;
      return age.toString();
    } catch (e) {
      return "N/A";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4ECDC4),
              Color(0xFFF5F7FA),
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
            strokeWidth: 3,
          ),
        )
            : error != null
            ? Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  S.of(context).errorTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadParentProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    S.of(context).retry,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        )
            : parentData != null
            ? FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Top spacing to account for existing header
                  const SizedBox(height: 40),

                  // Profile Header Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar with decorative elements
                        Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF4ECDC4).withOpacity(0.2),
                                    const Color(0xFF4ECDC4),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 120,
                              height: 120,
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  _getAvatarImage(parentData!.gender),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: const Color(0xFF4ECDC4).withOpacity(0.1),
                                      child: Icon(
                                        Icons.person,
                                        size: 60,
                                        color: const Color(0xFF4ECDC4),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Online status indicator
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Name with greeting
                        Text(
                          '${S.of(context).hello}, ${parentData!.name}! 👋',                         style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Email with icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                parentData!.email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Personal Information Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4ECDC4).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                color: Color(0xFF4ECDC4),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              S.of(context).personalInfo,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // Phone Number
                        _buildInfoRow(
                          icon: Icons.phone_outlined,
                          label: S.of(context).phoneNumber,
                          value: parentData!.phoneNumber,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 20),

                        // Nationality with Flag
                        _buildInfoRowWithFlag(
                          icon: Icons.public,
                          label: S.of(context).nationality,
                          value: parentData!.nationality,
                          flag: _getFlagEmoji(parentData!.nationality),
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 20),

                        // Gender
                        _buildInfoRow(
                          icon: parentData!.gender.toLowerCase() == 'male'
                              ? Icons.male
                              : Icons.female,
                          label: S.of(context).gender,
                          value: parentData!.gender.toUpperCase(),
                          color: parentData!.gender.toLowerCase() == 'male'
                              ? Colors.blue
                              : Colors.pink,
                        ),
                        const SizedBox(height: 20),

                        // Birthdate
                        _buildInfoRow(
                          icon: Icons.cake_outlined,
                          label: S.of(context).birthday,
                          value: _formatBirthdate(parentData!.birthdate),
                          color: Colors.purple,
                        ),
                        const SizedBox(height: 20),

                        // Age
                        _buildInfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: S.of(context).age,
                          value: '${_getAge(parentData!.birthdate)} years old',
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        )
            : const Center(
          child: Text(
            'No profile data available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithFlag({
    required IconData icon,
    required String label,
    required String value,
    required String flag,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      flag,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}