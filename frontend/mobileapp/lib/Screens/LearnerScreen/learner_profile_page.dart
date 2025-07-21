import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../generated/l10n.dart';
import '../../models/learner.dart';
import '../../Services/learner_profile_service.dart';

class LearnerProfilePage extends StatefulWidget {
  final String? learnerId;
  final Learner? learner;

  const LearnerProfilePage({
    Key? key,
    this.learnerId,
    this.learner,
  }) : super(key: key);

  @override
  State<LearnerProfilePage> createState() => _LearnerProfilePageState();
}

class _LearnerProfilePageState extends State<LearnerProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  Learner? _combinedLearner;
  bool _isLoadingMissingData = false;
  String? _errorMessage;

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
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fetchLearnerProfile();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchLearnerProfile() async {
    if (widget.learnerId == null) {
      setState(() {
        _errorMessage = S.of(context).learnerIdRequired;
      });
      return;
    }

    setState(() {
      _isLoadingMissingData = true;
      _errorMessage = null;
    });

    try {
      final learner = await LearnerProfileService.fetchLearnerProfile(widget.learnerId!);
      if (mounted) {
        setState(() {
          _combinedLearner = learner;
          _isLoadingMissingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingMissingData = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingMissingData) {
      return _buildLoadingState();
    }
    if (_errorMessage != null) {
      return _buildErrorState(_errorMessage!, _fetchLearnerProfile);
    }
    if (_combinedLearner != null) {
      return _buildProfileContent(_combinedLearner!);
    }
    return _buildEmptyState();
  }

  Widget _buildProfileContent(Learner learner) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF4834D4),
              Color(0xFF3742FA),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(learner),
                const SizedBox(height: 20),
                _buildProfileCard(learner),
                const SizedBox(height: 20),
                _buildStatsCard(learner),
                const SizedBox(height: 20),
                _buildPersonalInfoCard(learner),
                const SizedBox(height: 30),
                if (_errorMessage != null) _buildErrorBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber,
            color: Colors.red[700],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${S.of(context).profileDataLoadError}: $_errorMessage',
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Learner learner) {
    final flagEmoji = LearnerProfileService.getFlagEmoji(learner.nationality);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile Image with Animation
              Hero(
                tag: 'profile_image_${learner.id}',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: Image.asset(
                              learner.gender == 'male'
                                  ? 'assets/images/child2.png'
                                  : 'assets/images/child1.png',
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 110,
                                  height: 110,
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      // Flag badge
                      if (learner.nationality != null)
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              flagEmoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Name
              Text(
                learner.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // Username
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  '@${learner.username}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(Learner learner) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
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
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF6C63FF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  S.of(context).profileInformation,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              icon: Icons.email_outlined,
              label: S.of(context).email,
              value: learner.email ?? S.of(context).notProvided,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.cake_outlined,
              label: S.of(context).age,
              value: learner.birthdate != null ? _calculateAge(learner.birthdate!) : S.of(context).notProvided,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.wc_outlined,
              label: S.of(context).gender,
              value: learner.gender?.capitalizeFirst() ?? S.of(context).notProvided,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(Learner learner) {
    final achievement = LearnerProfileService.getAchievementLevel(context, learner.totalTimeSpent);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(achievement['color']),
              Color(achievement['color']).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.analytics_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  S.of(context).learningJourney,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.access_time,
                    title: S.of(context).totalTime,
                    value: learner.totalTimeSpent != null 
                        ? _formatTime(learner.totalTimeSpent!)
                        : '0m',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.military_tech,
                    title: S.of(context).achievement,
                    value: '${achievement['icon']} ${achievement['title']}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(Learner learner) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
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
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  S.of(context).personalDetails,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              icon: Icons.public,
              label: S.of(context).nationality,
              value: learner.nationality != null 
                  ? '${LearnerProfileService.getFlagEmoji(learner.nationality)} ${learner.nationality!.capitalizeFirst()}'
                  : S.of(context).notProvided,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: S.of(context).birthDate,
              value: learner.birthdate != null ? _formatDate(learner.birthdate!) : S.of(context).notProvided,
            ),
            if (learner.parentName != null) ...[
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.family_restroom,
                label: S.of(context).parentName,
                value: learner.parentName!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
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
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF4834D4),
              Color(0xFF3742FA),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                S.of(context).loadingProfile,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback? retry) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF4834D4),
              Color(0xFF3742FA),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                S.of(context).failedToLoadProfile,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (retry != null)
                ElevatedButton(
                  onPressed: retry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(S.of(context).retry),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF4834D4),
              Color(0xFF3742FA),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_off_outlined,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                S.of(context).profileNotFound,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateAge(String birthdate) {
    try {
      final birthDate = DateTime.parse(birthdate);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return S.of(context).yearsOld(age);
    } catch (e) {
      return S.of(context).unknown;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatTime(int totalMinutes) {
    if (totalMinutes < 60) {
      return S.of(context).minutesFormat(totalMinutes);
    } else {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return S.of(context).hoursMinutesFormat(hours, minutes);
    }
  }
}

extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}