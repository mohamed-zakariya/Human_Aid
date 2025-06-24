import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobileapp/Services/auth_service.dart';
import 'package:mobileapp/Services/google_auth_parent_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Services/notification_service.dart';
import '../../generated/l10n.dart';
import '../../models/parent.dart';
import '../widgets/language_toggle_icon.dart';

class LoginScreenGaurdian extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  const LoginScreenGaurdian({super.key, required this.onLocaleChange});

  @override
  State<LoginScreenGaurdian> createState() => _LoginScreenGaurdianState();
}

class _LoginScreenGaurdianState extends State<LoginScreenGaurdian>
    with TickerProviderStateMixin {
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

    // Add listeners to text controllers for real-time validation
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {});
  }

  bool get _isFormValid {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _isValidEmail(_emailController.text);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void handleLogin() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
  });

  try {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    Parent? parent = await AuthService.loginParent(email, password);
    if (parent != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingSeen', true);
      
      // Save user data to SharedPreferences
      await prefs.setString('userId', parent.id ?? '');
      await prefs.setString('role', 'parent');
      
      // Initialize notification service with the logged-in user
      await NotificationService.init();
      
      Navigator.pushReplacementNamed(
          context,
          '/parentHome',
          arguments: parent);
    } else {
      _showErrorSnackBar("Invalid email or password. Please try again.");
    }
  } catch (e) {
    _showErrorSnackBar("Login failed. Please check your connection and try again.");
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  void _handleGoogleLogin() async {
  setState(() {
    _isGoogleLoading = true;
  });

  try {
    final authService = AuthParentService();
    final user = await authService.signInWithGoogle();

    if (user != null) {
      final parentJson = user['parent'] as Map<String, dynamic>?;
      if (parentJson != null) {
        final parent = Parent.fromJson({
          "id": parentJson["_id"],
          "name": parentJson["name"],
          "email": parentJson["email"],
          "phoneNumber": parentJson["phoneNumber"] ?? "",
          "birthdate": parentJson["birthdate"] ?? "",
          "nationality": parentJson["nationality"] ?? "",
          "gender": parentJson["gender"] ?? "",
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('onboardingSeen', true);
        
        // Save user data to SharedPreferences
        await prefs.setString('userId', parent.id ?? '');
        await prefs.setString('role', 'parent');
        
        // Initialize notification service with the logged-in user
        await NotificationService.init();
        
        Navigator.pushReplacementNamed(
          context,
          '/parentHome',
          arguments: parent,
        );
      }
    } else {
      _showErrorSnackBar("Google sign-in failed. Please try again.");
    }
  } catch (e) {
    _showErrorSnackBar("Google sign-in failed. Please try again.");
  } finally {
    setState(() {
      _isGoogleLoading = false;
    });
  }
}

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;
    final isSmallScreen = screenHeight < 700;
    final isVerySmallScreen = screenHeight < 600;
    final isTinyScreen = screenHeight < 550;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // Add this to prevent resize when keyboard appears
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF334155), size: 20),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: LanguageToggleIcon(onLocaleChange: widget.onLocaleChange),
          ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  // Add SingleChildScrollView to handle overflow
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                  ),
                  child: ConstrainedBox(
                    // Ensure minimum height for proper layout
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Top section with image and titles - adaptive sizing
                            // Hide image when keyboard is open to save space
                            if (!isKeyboardOpen || !isTinyScreen) ...[
                              SizedBox(height: isKeyboardOpen ? 10 : 20),
                              // Hero Image with highly responsive sizing
                              Hero(
                                tag: 'login_image',
                                child: Container(
                                  padding: EdgeInsets.all(
                                      isKeyboardOpen
                                          ? 4
                                          : (isTinyScreen ? 6 : (isSmallScreen ? 8 : 12))
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF6366F1).withOpacity(0.1),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.asset(
                                      'assets/images/image7.png',
                                      width: screenWidth * (
                                          isKeyboardOpen
                                              ? 0.25
                                              : (isTinyScreen ? 0.35 : (isSmallScreen ? 0.4 : 0.45))
                                      ),
                                      height: isKeyboardOpen
                                          ? 40
                                          : (isTinyScreen ? 50 : (isVerySmallScreen ? 60 : (isSmallScreen ? 70 : 80))),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            SizedBox(height: isKeyboardOpen ? 8 : (isTinyScreen ? 8 : (isSmallScreen ? 12 : 16))),

                            // Welcome Title - smaller when keyboard is open
                            Text(
                              S.of(context).loginTitle,
                              style: TextStyle(
                                fontSize: isKeyboardOpen
                                    ? 18
                                    : (isTinyScreen ? 20 : (isVerySmallScreen ? 22 : (isSmallScreen ? 24 : 26))),
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: isKeyboardOpen ? 2 : (isTinyScreen ? 4 : 6)),

                            Text(
                              S.of(context).loginSubtitle,
                              style: TextStyle(
                                fontSize: isKeyboardOpen
                                    ? 12
                                    : (isTinyScreen ? 13 : (isSmallScreen ? 14 : 15)),
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: isKeyboardOpen ? 12 : (isTinyScreen ? 8 : 12)),

                            // Email Field
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!_isValidEmail(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: S.of(context).emailHint,
                                  hintStyle: TextStyle(
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                    fontSize: isKeyboardOpen ? 13 : (isTinyScreen ? 13 : 14),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: Container(
                                    margin: EdgeInsets.all(isKeyboardOpen ? 8 : (isTinyScreen ? 10 : 12)),
                                    padding: EdgeInsets.all(isKeyboardOpen ? 6 : (isTinyScreen ? 6 : 8)),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6366F1).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.email_outlined,
                                      color: const Color(0xFF6366F1),
                                      size: isKeyboardOpen ? 16 : (isTinyScreen ? 16 : 18),
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: Colors.grey.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF6366F1),
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 1,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: isKeyboardOpen ? 10 : (isTinyScreen ? 12 : (isSmallScreen ? 14 : 16)),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: isKeyboardOpen ? 4 : (isTinyScreen ? 6 : 8)),

                            // Password Field
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _isFormValid ? handleLogin() : null,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: S.of(context).passwordHint,
                                  hintStyle: TextStyle(
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                    fontSize: isKeyboardOpen ? 13 : (isTinyScreen ? 13 : 14),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: Container(
                                    margin: EdgeInsets.all(isKeyboardOpen ? 8 : (isTinyScreen ? 10 : 12)),
                                    padding: EdgeInsets.all(isKeyboardOpen ? 6 : (isTinyScreen ? 6 : 8)),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6366F1).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.lock_outline,
                                      color: const Color(0xFF6366F1),
                                      size: isKeyboardOpen ? 16 : (isTinyScreen ? 16 : 18),
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.grey[600],
                                      size: isKeyboardOpen ? 18 : (isTinyScreen ? 18 : 20),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: Colors.grey.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF6366F1),
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 1,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: isKeyboardOpen ? 10 : (isTinyScreen ? 12 : (isSmallScreen ? 14 : 16)),
                                  ),
                                ),
                              ),
                            ),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/forgot-password');
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: isKeyboardOpen ? 2 : (isTinyScreen ? 2 : 4)
                                  ),
                                ),
                                child: Text(
                                  S.of(context).forgotPassword,
                                  style: TextStyle(
                                    color: const Color(0xFF6366F1),
                                    fontWeight: FontWeight.w600,
                                    fontSize: isKeyboardOpen ? 11 : (isTinyScreen ? 11 : (isSmallScreen ? 12 : 13)),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: isKeyboardOpen ? 4 : 8),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: isKeyboardOpen ? 42 : (isTinyScreen ? 44 : (isSmallScreen ? 46 : 48)),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                child: ElevatedButton(
                                  onPressed: _isFormValid && !_isLoading ? handleLogin : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isFormValid
                                        ? const Color(0xFF6366F1)
                                        : Colors.grey[300],
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey[300],
                                    disabledForegroundColor: Colors.grey[500],
                                    elevation: _isFormValid ? 6 : 0,
                                    shadowColor: const Color(0xFF6366F1).withOpacity(0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                    height: isKeyboardOpen ? 16 : (isTinyScreen ? 16 : 18),
                                    width: isKeyboardOpen ? 16 : (isTinyScreen ? 16 : 18),
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                      : Text(
                                    S.of(context).loginButton,
                                    style: TextStyle(
                                      fontSize: isKeyboardOpen ? 14 : (isTinyScreen ? 14 : (isSmallScreen ? 15 : 16)),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: isKeyboardOpen ? 6 : (isTinyScreen ? 8 : 10)),

                            // OR Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.grey[300]!,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    S.of(context).orContinueWith,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                      fontSize: isKeyboardOpen ? 11 : (isTinyScreen ? 11 : (isSmallScreen ? 12 : 13)),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.grey[300]!,
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: isKeyboardOpen ? 6 : (isTinyScreen ? 8 : 10)),

                            // Google Login Button
                            SizedBox(
                              width: double.infinity,
                              height: isKeyboardOpen ? 42 : (isTinyScreen ? 44 : (isSmallScreen ? 46 : 48)),
                              child: OutlinedButton.icon(
                                onPressed: _isGoogleLoading ? null : _handleGoogleLogin,
                                icon: _isGoogleLoading
                                    ? SizedBox(
                                  height: isKeyboardOpen ? 16 : (isTinyScreen ? 16 : 18),
                                  width: isKeyboardOpen ? 16 : (isTinyScreen ? 16 : 18),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                                  ),
                                )
                                    : FaIcon(
                                  FontAwesomeIcons.google,
                                  color: Colors.red,
                                  size: isKeyboardOpen ? 16 : (isTinyScreen ? 16 : 18),
                                ),
                                label: Text(
                                  _isGoogleLoading ? 'Signing in...' : 'Continue with Google',
                                  style: TextStyle(
                                    fontSize: isKeyboardOpen ? 13 : (isTinyScreen ? 13 : (isSmallScreen ? 14 : 15)),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ),

                            // Flexible spacer that adapts to available space
                            SizedBox(height: isKeyboardOpen ? 8 : 16),

                            // Footer Text with enhanced styling
                            Padding(
                              padding: EdgeInsets.only(bottom: isKeyboardOpen ? 8 : 12),
                              child: RichText(
                                text: TextSpan(
                                  text: '${S.of(context).noAccount} ',
                                  style: TextStyle(
                                    color: const Color(0xFF6B7280),
                                    fontSize: isKeyboardOpen ? 12 : (isTinyScreen ? 12 : (isSmallScreen ? 13 : 14)),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: S.of(context).createAccountGaurdian,
                                      style: TextStyle(
                                        color: const Color(0xFF6366F1),
                                        fontSize: isKeyboardOpen ? 12 : (isTinyScreen ? 12 : (isSmallScreen ? 13 : 14)),
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: const Color(0xFF6366F1),
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.pushNamed(context, '/signup1');
                                        },
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}