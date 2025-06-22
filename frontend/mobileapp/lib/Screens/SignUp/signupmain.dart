import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/Screens/widgets/MaleFemale.dart';
import 'package:mobileapp/Screens/SignUp/ProgressBar.dart';
import 'package:mobileapp/Screens/widgets/SignupEmailInputField.dart';
import 'package:mobileapp/Screens/widgets/SignupInputField.dart';
import 'package:mobileapp/Screens/SignUp/SignupPhoneNumberField.dart';
import 'package:mobileapp/Screens/widgets/successSnackBar.dart';
import 'package:mobileapp/classes/validators.dart';
import 'package:mobileapp/Services/signup_service.dart';
import 'package:mobileapp/generated/l10n.dart';
import 'package:mobileapp/models/parent.dart';

import '../../Services/check_exists.dart';
import '../widgets/GuardianDate.dart';
import '../widgets/GuardianSignupCountryDropdown.dart';
import '../widgets/date.dart';

class Signupmain extends StatefulWidget {
  const Signupmain({super.key});

  @override
  State<Signupmain> createState() => _SignupmainState();
}

class _SignupmainState extends State<Signupmain> {
  // Define controllers for the input fields
  final TextEditingController nameController = TextEditingController();
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
  bool _autoValidate = false;
  bool _isEmailValid = false;
  bool _isCheckingEmail = false; // Loading state for email validation
  String? _emailError; // Store email error message

  // Track if all fields are filled
  bool get _isFormValid {
    return nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        phoneNumberController.text.isNotEmpty &&
        nationalityController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        birthdateController.text.isNotEmpty &&
        selectedGender.isNotEmpty &&
        !_isCheckingEmail; // Disable button while checking email
  }

  @override
  void initState() {
    super.initState();
    // Add listeners to all controllers to update button state
    nameController.addListener(_updateButtonState);
    emailController.addListener(_updateButtonState);
    passwordController.addListener(_updateButtonState);
    phoneNumberController.addListener(_updateButtonState);
    nationalityController.addListener(_updateButtonState);
    confirmPasswordController.addListener(_updateButtonState);
    birthdateController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      // This will trigger a rebuild and update the button state
    });
  }

  // Enhanced email validation with existence check
  Future<String?> validateEmailWithExistence(String? value) async {
    // First, do basic email validation
    String? basicValidation = validateEmail(value);
    if (basicValidation != null) {
      return basicValidation;
    }

    // If basic validation passes, check if email exists
    setState(() {
      _isCheckingEmail = true;
      _emailError = null;
    });

    try {
      bool emailExists = await CheckExists.emailParentCheck(value!);

      setState(() {
        _isCheckingEmail = false;
      });

      if (emailExists) {
        String errorMessage = Intl.getCurrentLocale() == 'ar'
            ? 'هذا البريد الإلكتروني مستخدم بالفعل'
            : 'This email is already registered';

        setState(() {
          _emailError = errorMessage;
        });

        return errorMessage;
      }

      setState(() {
        _emailError = null;
      });

      return null;
    } catch (e) {
      setState(() {
        _isCheckingEmail = false;
        _emailError = Intl.getCurrentLocale() == 'ar'
            ? 'خطأ في التحقق من البريد الإلكتروني'
            : 'Error checking email';
      });

      return _emailError;
    }
  }

  // Basic email validation method
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return Intl.getCurrentLocale() == 'ar' ? 'يجب إدخال البريد الإلكتروني' : 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return Intl.getCurrentLocale() == 'ar' ? 'يرجى إدخال بريد إلكتروني صحيح' : 'Please enter a valid email';
    }
    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Callback function to update gender
  void _updateGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
  }

  // Callback function to update email validation status
  void _updateEmailValidation(bool isValid) {
    setState(() {
      _isEmailValid = isValid;
    });
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return Intl.getCurrentLocale() == 'ar'
          ? "يجب تأكيد كلمة المرور"
          : "Confirm password must be entered";
    } else if (value != passwordController.text) {
      return Intl.getCurrentLocale() == 'ar'
          ? "كلمتا المرور غير متطابقتين"
          : "Passwords do not match";
    }
    return null;
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the tree
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    birthdateController.dispose();
    phoneNumberController.dispose();
    nationalityController.dispose();
    super.dispose();
  }

  void signup() async {
    // Enable auto-validation after first submit attempt
    setState(() {
      _autoValidate = true;
    });

    // First validate email existence before form validation
    String? emailValidationResult = await validateEmailWithExistence(emailController.text.trim());
    if (emailValidationResult != null) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(emailValidationResult),
      //     backgroundColor: Colors.red,
      //     duration: const Duration(seconds: 3),
      //   ),
      // );
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
                ? "يرجى تصحيح الأخطاء في النموذج"
                : "Please correct the errors in the form",
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

    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    String phoneNumber = phoneNumberController.text.trim();
    String date = birthdateController.text;
    String gender = selectedGender;
    String nationality = nationalityController.text;

    gender = (gender == S.of(context).genderMale) ? 'male' : 'female';

    print("Name: $name, Email: $email, Phone: $phoneNumber");

    Parent? parent = Parent(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        birthdate: date,
        nationality: nationality,
        gender: gender);

    if (parent != null) {
      print("Parent Name: ${parent.name}");
      Navigator.pushNamed(context, '/signup2', arguments: parent);
    } else {
      print("Failed to create account: Parent is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          S.of(context).title,
          style: TextStyle(
            fontSize: Intl.getCurrentLocale() == 'ar' ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Enhanced Progress Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Progressbar(35, 35, 108, 99, 255, true, false),
                  Progressbar(100, 14, 217, 217, 217, false, false),
                  Progressbar(35, 35, 217, 217, 217, true, false)
                ],
              ),
            ),

            // Enhanced Image Container
            Container(
              width: MediaQuery.of(context).size.width - 80,
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Image.asset('assets/images/parent.png'),
            ),

            // Enhanced Form
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: _autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Signupinputfield(
                      S.of(context).signupinputfieldname,
                      S.of(context).signuptitlename,
                      108, 99, 255, 0.08,
                      0, 0, 0, 0.3,
                      true, false,
                      nameController,
                      Validators.validateName,
                    ),

                    // Enhanced Email Field with existence validation
                    _buildEnhancedEmailFieldWithValidation(),

                    Signupphonenumberfield(
                      S.of(context).signuptitlephonenumber,
                      phoneNumberController,
                    ),
                    Guardiansignupcountrydropdown(
                      S.of(context).signupinputfieldnationality,
                      S.of(context).signuptitlenationality,
                      nationalityController.text.isEmpty
                          ? null
                          : nationalityController.text,
                          (String? newValue) {
                        nationalityController.text = newValue ?? '';
                        _updateButtonState();
                      },
                          (value) {
                        if (value == null || value.isEmpty) {
                          return Intl.getCurrentLocale() == 'ar'
                              ? 'يرجى اختيار الجنسية'
                              : 'Please select a nationality';
                        }
                        return null;
                      },
                    ),
                    Signupinputfield(
                      S.of(context).signupinputfieldpassword,
                      S.of(context).signuptitlepassword,
                      108, 99, 255, 0.08,
                      0, 0, 0, 0.3,
                      true, false,
                      passwordController,
                      Validators.validatePassword,
                    ),
                    Signupinputfield(
                      S.of(context).signupinputfieldpassword,
                      S.of(context).signuptitleconfirmpassword,
                      108, 99, 255, 0.08,
                      0, 0, 0, 0.3,
                      true, false,
                      confirmPasswordController,
                      validateConfirmPassword,
                    ),
                    GuardianDateTimePicker(
                      controller: birthdateController,
                      quardian: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return S.of(context).birthdateValidation;
                        }
                        return null;
                      },
                    ),

                    // Enhanced Gender Selection with validation
                    _buildEnhancedGenderSelection(),
                  ],
                ),
              ),
            ),

            // Enhanced Continue Button
            Container(
              margin: const EdgeInsets.fromLTRB(20, 30, 20, 40),
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isFormValid ? signup : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid
                      ? const Color.fromRGBO(108, 99, 255, 1)
                      : Colors.grey[300],
                  foregroundColor: _isFormValid ? Colors.white : Colors.grey[600],
                  elevation: _isFormValid ? 3 : 0,
                  shadowColor: const Color.fromRGBO(108, 99, 255, 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[600],
                ),
                child: _isCheckingEmail
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      S.of(context).signupbutton,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _isFormValid ? Colors.white : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: _isFormValid ? Colors.white : Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced email field with real-time validation and loading indicator
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
              if (_emailError != null) {
                setState(() {
                  _emailError = null;
                });
              }
            },
            decoration: InputDecoration(
              hintText: S.of(context).signupinputfieldemail,
              prefixIcon: const Icon(Icons.email_outlined, color: Color.fromRGBO(108, 99, 255, 1)),
              suffixIcon: _isCheckingEmail
                  ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(108, 99, 255, 1)),
                  ),
                ),
              )
                  : null,
              filled: true,
              fillColor: const Color.fromRGBO(108, 99, 255, 0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: _emailError != null ? Colors.red : Colors.black.withOpacity(0.3)
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: _emailError != null ? Colors.red : Colors.black.withOpacity(0.3)
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: _emailError != null ? Colors.red : const Color.fromRGBO(108, 99, 255, 1),
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
          if (_emailError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12),
              child: Text(
                _emailError!,
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

  // Enhanced Gender Selection with validation
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
              color: const Color.fromRGBO(108, 99, 255, 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: selectedGender.isEmpty && _autoValidate
                      ? Colors.red
                      : Colors.black.withOpacity(0.3)
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