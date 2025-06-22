import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/Screens/widgets/MaleFemale.dart';
import 'package:mobileapp/Screens/widgets/SignupInputField.dart';
import 'package:mobileapp/Screens/SignUp/SignupPhoneNumberField.dart';
import 'package:mobileapp/Screens/widgets/SignupUsernameInputField.dart';
import 'package:mobileapp/Services/check_exists.dart';
import 'package:mobileapp/classes/validators.dart';
import 'package:mobileapp/generated/l10n.dart';
import 'package:mobileapp/models/learner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/signup_service.dart';
import '../widgets/SignupCountryDropdown.dart';
import '../widgets/SignupEmailInputField.dart';
import '../widgets/date.dart';
import '../widgets/successSnackBar.dart';

class Signupadult extends StatefulWidget {
  const Signupadult({super.key});

  @override
  State<Signupadult> createState() => _SignupadultState();
}

class _SignupadultState extends State<Signupadult> {
  // Define controllers for the input fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Variable to store selected gender
  String selectedGender = '';
  String? confirmPasswordError;
  bool _isLoading = false;
  bool _autoValidate = false;

  // Remove real-time validation states - only keep for submit validation
  bool _isCheckingUsername = false;
  bool _isCheckingEmail = false;
  String? _usernameAsyncError;
  String? _emailAsyncError;

  // Track if all fields are filled - Simplified validation logic
  bool get _isFormValid {
    return nameController.text.isNotEmpty &&
        usernameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        birthdateController.text.isNotEmpty &&
        nationalityController.text.isNotEmpty &&
        selectedGender.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    // Add listeners to all controllers to update button state only
    nameController.addListener(_updateButtonState);
    usernameController.addListener(_updateButtonState);
    emailController.addListener(_updateButtonState);
    passwordController.addListener(_updateButtonState);
    confirmPasswordController.addListener(_updateButtonState);
    birthdateController.addListener(_updateButtonState);
    nationalityController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      // This will trigger a rebuild and update the button state
    });
  }

  // Check username availability - only called on submit
  Future<String?> validateUsernameWithExistence(String username) async {
    if (username.length < 3) {
      return Intl.getCurrentLocale() == 'ar'
          ? 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل'
          : 'Username must be at least 3 characters';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return Intl.getCurrentLocale() == 'ar'
          ? 'اسم المستخدم يجب أن يحتوي على أحرف وأرقام فقط'
          : 'Username can only contain letters, numbers, and underscores';
    }

    setState(() {
      _isCheckingUsername = true;
      _usernameAsyncError = null;
    });

    try {
      bool exists = await CheckExists.usernameLearnerCheck(username);

      setState(() {
        _isCheckingUsername = false;
      });

      if (exists) {
        String errorMessage = Intl.getCurrentLocale() == 'ar'
            ? 'اسم المستخدم مستخدم بالفعل'
            : 'Username is already taken';

        setState(() {
          _usernameAsyncError = errorMessage;
        });

        return errorMessage;
      }

      setState(() {
        _usernameAsyncError = null;
      });

      return null;
    } catch (e) {
      setState(() {
        _isCheckingUsername = false;
        _usernameAsyncError = Intl.getCurrentLocale() == 'ar'
            ? 'خطأ في التحقق من اسم المستخدم'
            : 'Error checking username';
      });

      return _usernameAsyncError;
    }
  }

  // Check email availability - only called on submit
  Future<String?> validateEmailWithExistence(String email) async {
    // First, do basic email validation
    if (email.isEmpty) {
      return Intl.getCurrentLocale() == 'ar' ? 'يجب إدخال البريد الإلكتروني' : 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return Intl.getCurrentLocale() == 'ar' ? 'البريد الإلكتروني غير صحيح' : 'Please enter a valid email';
    }

    setState(() {
      _isCheckingEmail = true;
      _emailAsyncError = null;
    });

    try {
      bool exists = await CheckExists.emailLearnerCheck(email);

      setState(() {
        _isCheckingEmail = false;
      });

      if (exists) {
        String errorMessage = Intl.getCurrentLocale() == 'ar'
            ? 'البريد الإلكتروني مستخدم بالفعل'
            : 'Email is already in use';

        setState(() {
          _emailAsyncError = errorMessage;
        });

        return errorMessage;
      }

      setState(() {
        _emailAsyncError = null;
      });

      return null;
    } catch (e) {
      setState(() {
        _isCheckingEmail = false;
        _emailAsyncError = Intl.getCurrentLocale() == 'ar'
            ? 'خطأ في التحقق من البريد الإلكتروني'
            : 'Error checking email';
      });

      return _emailAsyncError;
    }
  }

  // Callback function to update gender
  void _updateGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return Intl.getCurrentLocale() == 'ar'? "يجب تأكيد كلمة المرور":"Confirm password must be entered";
    } else if (value != passwordController.text) {
      return Intl.getCurrentLocale() == 'ar'?  "كلمتا المرور غير متطابقتين":"Passwords do not match";
    }
    return null;
  }

  // Basic username validation - no async checking
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return Intl.getCurrentLocale() == 'ar' ? 'يجب إدخال اسم المستخدم' : 'Username is required';
    }
    if (value.length < 3) {
      return Intl.getCurrentLocale() == 'ar' ? 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل' : 'Username must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return Intl.getCurrentLocale() == 'ar' ? 'اسم المستخدم يجب أن يحتوي على أحرف وأرقام فقط' : 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  // Basic email validation - no async checking
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return Intl.getCurrentLocale() == 'ar' ? 'يجب إدخال البريد الإلكتروني' : 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return Intl.getCurrentLocale() == 'ar' ? 'البريد الإلكتروني غير صحيح' : 'Please enter a valid email';
    }
    return null;
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the tree
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneNumberController.dispose();
    nationalityController.dispose();
    confirmPasswordController.dispose();
    birthdateController.dispose();
    super.dispose();
  }

  void signup() async {
    // Enable auto-validation after first submit attempt
    setState(() {
      _autoValidate = true;
    });

    // First validate username and email existence before form validation
    String? usernameValidationResult = await validateUsernameWithExistence(usernameController.text.trim());
    if (usernameValidationResult != null) {
      // Error is now shown below the field, no snackbar needed
      return;
    }

    String? emailValidationResult = await validateEmailWithExistence(emailController.text.trim());
    if (emailValidationResult != null) {
      // Error is now shown below the field, no snackbar needed
      return;
    }

    // Validate the form
    if (!_formKey.currentState!.validate()) {
      print("Form validation failed");

      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              Intl.getCurrentLocale() == 'ar'
                  ? 'يرجى تصحيح الأخطاء في النموذج'
                  : 'Please correct the errors in the form'
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Validate gender selection manually since it's not a TextFormField
    if (selectedGender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              Intl.getCurrentLocale() == 'ar'
                  ? 'يرجى اختيار الجنس'
                  : 'Please select gender'
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String name = nameController.text.trim();
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;
    String date = birthdateController.text;
    String gender = selectedGender;
    String nationality = nationalityController.text;

    gender = (gender == S.of(context).genderMale)? 'male':'female';

    print("Name: $name, Username: $username, Email: $email");

    try {
      Learner? learner = await SignupService.signupAdult(
          name, username, email, password, nationality, date, gender, "adult"
      );

      if (learner != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          successSnackBar("Signup successful!"),
        );

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('onboardingSeen', true);

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/Learner-Home', arguments: learner);
        });
      } else {
        print("Failed to create account: Learner is null");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                Intl.getCurrentLocale() == 'ar'
                    ? 'فشل في إنشاء الحساب. يرجى المحاولة مرة أخرى'
                    : 'Failed to create account. Please try again.'
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error during signup: $e");
      String errorMessage;

      // Handle specific error messages
      if (e.toString().contains('email')) {
        errorMessage = Intl.getCurrentLocale() == 'ar'
            ? 'البريد الإلكتروني مستخدم بالفعل'
            : 'Email is already in use';
      } else if (e.toString().contains('username')) {
        errorMessage = Intl.getCurrentLocale() == 'ar'
            ? 'اسم المستخدم مستخدم بالفعل'
            : 'Username is already taken';
      } else {
        errorMessage = Intl.getCurrentLocale() == 'ar'
            ? 'حدث خطأ. يرجى المحاولة مرة أخرى'
            : 'An error occurred. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(249, 178, 136, 1),
        elevation: 0,
        title: Text(
          S.of(context).title,
          style: TextStyle(
            fontSize: Intl.getCurrentLocale() == 'ar'? 35:25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header section with gradient background
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(249, 178, 136, 1),
                    Color.fromRGBO(249, 178, 136, 0.1),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Profile Image with enhanced styling
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundImage: AssetImage('assets/images/girl.jpeg'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // Form section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                autovalidateMode: _autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Enhanced input fields with improved styling
                    _buildEnhancedInputField(
                      controller: nameController,
                      label: S.of(context).signuptitlename,
                      hint: S.of(context).signupinputfieldname,
                      icon: Icons.person_outline,
                      validator: Validators.validateName,
                    ),

                    _buildEnhancedUsernameField(),

                    _buildEnhancedEmailFieldWithValidation(),

                    // Enhanced Country Dropdown
                    _buildEnhancedCountryDropdown(),

                    _buildEnhancedInputField(
                      controller: passwordController,
                      label: S.of(context).signuptitlepassword,
                      hint: S.of(context).signupinputfieldpassword,
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: Validators.validatePassword,
                    ),

                    _buildEnhancedInputField(
                      controller: confirmPasswordController,
                      label: S.of(context).signuptitleconfirmpassword,
                      hint: S.of(context).signupinputfieldpassword,
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: validateConfirmPassword,
                    ),

                    // Enhanced Date Picker
                    _buildEnhancedDatePicker(),

                    // Enhanced Gender Selection
                    _buildEnhancedGenderSelection(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Enhanced Create Account Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: _isFormValid && !_isLoading
                      ? const LinearGradient(
                    colors: [
                      Color.fromRGBO(249, 178, 136, 1),
                      Color.fromRGBO(255, 140, 82, 1),
                    ],
                  )
                      : null,
                  color: _isFormValid && !_isLoading ? null : Colors.grey[400],
                  boxShadow: _isFormValid && !_isLoading
                      ? [
                    const BoxShadow(
                      color: const Color.fromRGBO(249, 178, 136, 0.4),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: !_isLoading ? signup : null,
                    child: Center(
                      child: (_isLoading || _isCheckingUsername || _isCheckingEmail)
                          ? const SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        S.of(context).createaccountbutton,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _isFormValid ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isLoading = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: const Color.fromRGBO(249, 178, 136, 1)),
              suffixIcon: isLoading
                  ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromRGBO(249, 178, 136, 1),
                    ),
                  ),
                ),
              )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color.fromRGBO(249, 178, 136, 1), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedUsernameField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).signuptitleusername,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: usernameController,
            validator: validateUsername,
            onChanged: (value) {
              // Clear previous error when user starts typing
              if (_usernameAsyncError != null) {
                setState(() {
                  _usernameAsyncError = null;
                });
              }
            },
            decoration: InputDecoration(
              hintText: S.of(context).signupinputfieldusername,
              prefixIcon: const Icon(Icons.alternate_email, color: Color.fromRGBO(249, 178, 136, 1)),
              suffixIcon: _isCheckingUsername
                  ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromRGBO(249, 178, 136, 1),
                    ),
                  ),
                ),
              )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: _usernameAsyncError != null ? Colors.red : Colors.grey[300]!
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: _usernameAsyncError != null ? Colors.red : Colors.grey[300]!
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: _usernameAsyncError != null ? Colors.red : const Color.fromRGBO(249, 178, 136, 1),
                    width: 2
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          // Show username error message
          if (_usernameAsyncError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12),
              child: Text(
                _usernameAsyncError!,
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

  Widget _buildEnhancedEmailFieldWithValidation() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).signuptitleemail,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: validateEmail, // Only basic validation for form validation
            onChanged: (value) {
              // Clear previous error when user starts typing
              if (_emailAsyncError != null) {
                setState(() {
                  _emailAsyncError = null;
                });
              }
            },
            decoration: InputDecoration(
              hintText: S.of(context).signupinputfieldemail,
              prefixIcon: const Icon(Icons.email_outlined, color: Color.fromRGBO(249, 178, 136, 1)),
              suffixIcon: _isCheckingEmail
                  ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(249, 178, 136, 1)),
                  ),
                ),
              )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: _emailAsyncError != null ? Colors.red : Colors.grey[300]!
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: _emailAsyncError != null ? Colors.red : Colors.grey[300]!
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: _emailAsyncError != null ? Colors.red : const Color.fromRGBO(249, 178, 136, 1),
                    width: 2
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          // Show email error message
          if (_emailAsyncError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12),
              child: Text(
                _emailAsyncError!,
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


  Widget _buildEnhancedCountryDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).signuptitlenationality,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SignupCountryDropdown(
              value: nationalityController.text.isEmpty ? null : nationalityController.text,
              onChanged: (String? newValue) {
                setState(() {
                  nationalityController.text = newValue ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return Intl.getCurrentLocale() == 'ar'
                      ? 'يرجى اختيار الجنسية'
                      : 'Please select a nationality';
                }
                return null;
              },
              hintText: S.of(context).signupinputfieldnationality,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDatePicker() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).signuptitlebirthdate,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DateTimePicker(
              controller: birthdateController,
              quardian: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return S.of(context).birthdateValidation;
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedGenderSelection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Intl.getCurrentLocale() == 'ar' ? 'اختر الجنس' : 'Select Gender',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: selectedGender.isEmpty && _autoValidate
                      ? Colors.red
                      : Colors.grey[300]!
              ),
            ),
            child: Column(
              children: [
                Malefemale(
                  onGenderSelected: (gender) {
                    setState(() {
                      selectedGender = gender;
                    });
                  },
                  flag: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).genderValidationError;
                    }
                    return null;
                  },
                ),
                if (selectedGender.isEmpty && _autoValidate)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        Intl.getCurrentLocale() == 'ar'
                            ? 'يرجى اختيار الجنس'
                            : 'Please select gender',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}