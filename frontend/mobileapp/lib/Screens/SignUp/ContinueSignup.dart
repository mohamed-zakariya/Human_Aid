import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mobileapp/Screens/ParentScreen/ParentMain.dart';
import 'package:mobileapp/Screens/widgets/MaleFemale.dart';
import 'package:mobileapp/Screens/SignUp/ProgressBar.dart';
import 'package:mobileapp/Screens/widgets/SignupInputField.dart';
import 'package:mobileapp/Screens/widgets/successSnackBar.dart';
import 'package:mobileapp/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Services/signup_service.dart';
import '../../Services/check_exists.dart';
import '../../models/learner.dart';
import '../../models/parent.dart';
import '../widgets/ChildSignupCountryDropdown.dart';
import '../widgets/GuardianDate.dart';
import '../widgets/GuardianSignupCountryDropdown.dart';
import '../widgets/SignupCountryDropdown.dart';
import '../widgets/date.dart';

class Continuesignup extends StatefulWidget {
  final Parent? parent;

  const Continuesignup({super.key, this.parent});

  @override
  State<Continuesignup> createState() => _ContinuesignupState();
}

class _ContinuesignupState extends State<Continuesignup> {

  final ScrollController _scrollController = ScrollController();


  final List<int> containers = [];
  final Map<int, GlobalKey<FormState>> formKeys = {};
  final Map<int, TextEditingController> nameControllers = {};
  final Map<int, TextEditingController> usernameControllers = {};
  final Map<int, TextEditingController> nationalityControllers = {};
  final Map<int, TextEditingController> passwordControllers = {};
  final Map<int, TextEditingController> confirmPasswordControllers = {};
  final Map<int, TextEditingController> birthdateControllers = {};
  final Map<int, String> selectedGenders = {};

  // Enhanced validation state management
  final Map<int, bool> autoValidateStates = {};
  final Map<int, bool> isCheckingUsername = {};
  final Map<int, String?> usernameErrors = {};
  bool _isSubmitting = false;

  late Parent? parent = widget.parent;

  final Map<int, GlobalKey> containerKeys = {};


  @override
  void initState() {
    super.initState();
    _addContainer();
  }

  void _addContainer() {
    int id = containers.isEmpty ? 1 : containers.last + 1;

    setState(() {
      containers.add(id);
      formKeys[id] = GlobalKey<FormState>();
      containerKeys[id] = GlobalKey(); // Add container key

      nameControllers[id] = TextEditingController();
      usernameControllers[id] = TextEditingController();
      nationalityControllers[id] = TextEditingController();
      passwordControllers[id] = TextEditingController();
      confirmPasswordControllers[id] = TextEditingController();
      birthdateControllers[id] = TextEditingController();
      selectedGenders[id] = '';

      // Initialize validation states
      autoValidateStates[id] = false;
      isCheckingUsername[id] = false;
      usernameErrors[id] = null;

      // Add listeners to update button state
      nameControllers[id]!.addListener(_updateButtonState);
      usernameControllers[id]!.addListener(() {
        _updateButtonState();
        // Clear username error when user starts typing
        if (usernameErrors[id] != null) {
          setState(() {
            usernameErrors[id] = null;
          });
        }
      });
      nationalityControllers[id]!.addListener(_updateButtonState);
      passwordControllers[id]!.addListener(_updateButtonState);
      confirmPasswordControllers[id]!.addListener(_updateButtonState);
      birthdateControllers[id]!.addListener(_updateButtonState);
    });

    // Scroll to the newly added container after a brief delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToContainer(id);
    });
  }


  void _removeContainer(int id) {
    if (containers.length <= 1) return;

    setState(() {
      // Dispose controllers
      nameControllers[id]?.dispose();
      usernameControllers[id]?.dispose();
      nationalityControllers[id]?.dispose();
      passwordControllers[id]?.dispose();
      confirmPasswordControllers[id]?.dispose();
      birthdateControllers[id]?.dispose();

      // Remove from maps
      containers.remove(id);
      formKeys.remove(id);
      containerKeys.remove(id); // Remove container key
      nameControllers.remove(id);
      usernameControllers.remove(id);
      nationalityControllers.remove(id);
      passwordControllers.remove(id);
      confirmPasswordControllers.remove(id);
      birthdateControllers.remove(id);
      selectedGenders.remove(id);
      autoValidateStates.remove(id);
      isCheckingUsername.remove(id);
      usernameErrors.remove(id);
    });

    // Scroll to the last container after removal
    if (containers.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToContainer(containers.last);
      });
    }

  }


  // Add smooth scrolling method
  void _scrollToContainer(int containerId) {
    final RenderBox? renderBox = containerKeys[containerId]?.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final scrollPosition = _scrollController.position.pixels + position.dy - 200; // Offset for better positioning

      _scrollController.animateTo(
        scrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _updateButtonState() {
    setState(() {
      // This will trigger a rebuild and update the button state
    });
  }

  void _updateGender(int id, String gender) {
    setState(() {
      selectedGenders[id] = gender;
    });
  }

  // Check if all forms are filled
  bool get _areAllFormsFilled {
    if (_isSubmitting) return false;

    for (int id in containers) {
      if (nameControllers[id]?.text.isEmpty ?? true) return false;
      if (usernameControllers[id]?.text.isEmpty ?? true) return false;
      if (nationalityControllers[id]?.text.isEmpty ?? true) return false;
      if (passwordControllers[id]?.text.isEmpty ?? true) return false;
      if (confirmPasswordControllers[id]?.text.isEmpty ?? true) return false;
      if (birthdateControllers[id]?.text.isEmpty ?? true) return false;
      if (selectedGenders[id]?.isEmpty ?? true) return false;
      if (isCheckingUsername[id] ?? false) return false;
    }
    return true;
  }

  // Enhanced username validation with existence check
  Future<String?> validateUsernameWithExistence(int id, String? value) async {
    // Basic username validation
    if (value == null || value.isEmpty) {
      return Intl.getCurrentLocale() == 'ar'
          ? 'يجب إدخال اسم المستخدم'
          : 'Username is required';
    }

    if (value.length < 3) {
      return Intl.getCurrentLocale() == 'ar'
          ? 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل'
          : 'Username must be at least 3 characters';
    }

    // Check if username exists
    setState(() {
      isCheckingUsername[id] = true;
      usernameErrors[id] = null;
    });

    try {
      bool usernameExists = await CheckExists.usernameLearnerCheck(value);

      setState(() {
        isCheckingUsername[id] = false;
      });

      if (usernameExists) {
        String errorMessage = Intl.getCurrentLocale() == 'ar'
            ? 'اسم المستخدم مستخدم بالفعل'
            : 'This username is already taken';

        setState(() {
          usernameErrors[id] = errorMessage;
        });

        return errorMessage;
      }

      setState(() {
        usernameErrors[id] = null;
      });

      return null;
    } catch (e) {
      setState(() {
        isCheckingUsername[id] = false;
        usernameErrors[id] = Intl.getCurrentLocale() == 'ar'
            ? 'خطأ في التحقق من اسم المستخدم'
            : 'Error checking username';
      });

      return usernameErrors[id];
    }
  }

  // Basic username validation for form validation
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return Intl.getCurrentLocale() == 'ar'
          ? 'يجب إدخال اسم المستخدم'
          : 'Username is required';
    }

    if (value.length < 3) {
      return Intl.getCurrentLocale() == 'ar'
          ? 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل'
          : 'Username must be at least 3 characters';
    }

    return null;
  }

  String? validateConfirmPassword(int id, String? value) {
    if (value == null || value.isEmpty) {
      return Intl.getCurrentLocale() == 'ar'
          ? "يجب تأكيد كلمة المرور"
          : "Confirm password is required";
    } else if (value != passwordControllers[id]?.text) {
      return Intl.getCurrentLocale() == 'ar'
          ? "كلمتا المرور غير متطابقتين"
          : "Passwords do not match";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return Intl.getCurrentLocale() == 'ar'
          ? 'يجب إدخال كلمة المرور'
          : 'Password is required';
    }
    if (value.length < 6) {
      return Intl.getCurrentLocale() == 'ar'
          ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
          : 'Password must be at least 6 characters';
    }
    return null;
  }

  bool _validateAllForms() {
    bool isValid = true;

    // Enable auto-validation for all forms
    setState(() {
      for (int id in containers) {
        autoValidateStates[id] = true;
      }
    });

    // Validate each form
    for (var key in formKeys.values) {
      if (!(key.currentState?.validate() ?? false)) {
        isValid = false;
      }
    }

    // Validate gender selection for each container
    for (int id in containers) {
      if (selectedGenders[id]?.isEmpty ?? true) {
        isValid = false;
      }
    }

    return isValid;
  }

  void signup() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // First validate all usernames existence
      for (int id in containers) {
        String? usernameValidationResult = await validateUsernameWithExistence(
            id, usernameControllers[id]?.text.trim());
        if (usernameValidationResult != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(usernameValidationResult),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
          setState(() {
            _isSubmitting = false;
          });
          return;
        }
      }

      // Validate all forms
      if (!_validateAllForms()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Intl.getCurrentLocale() == 'ar'
                  ? "يرجى تصحيح الأخطاء في النماذج"
                  : "Please correct the errors in the forms",
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Check if parent object is null
      if (parent == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                Intl.getCurrentLocale() == 'ar'
                    ? "بيانات الوالد مفقودة. يرجى المحاولة مرة أخرى."
                    : "Parent data is missing. Please try again."
            ),
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Signup Parent
      Parent? parentNew = await SignupService.signupParent(
        parent!.name,
        parent!.email,
        parent!.password ?? "",
        parent!.phoneNumber,
        parent!.nationality,
        parent!.birthdate,
        parent!.gender,
      );

      if (parentNew == null || parentNew.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                Intl.getCurrentLocale() == 'ar'
                    ? "فشل في التسجيل. يرجى المحاولة مرة أخرى."
                    : "Signup failed. Please try again."
            ),
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Signup children
      for (var key in nameControllers.keys) {
        if (nameControllers[key] == null ||
            usernameControllers[key] == null ||
            passwordControllers[key] == null ||
            nationalityControllers[key] == null ||
            birthdateControllers[key] == null ||
            selectedGenders[key] == null) {
          continue;
        }

        String gender = (selectedGenders[key] == S.of(context).genderMale)
            ? 'male'
            : 'female';

        await SignupService.signupChild(
          parentNew.id!,
          nameControllers[key]!.text,
          usernameControllers[key]!.text,
          passwordControllers[key]!.text,
          nationalityControllers[key]!.text,
          birthdateControllers[key]!.text,
          gender,
          "child",
        );
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        successSnackBar(
            Intl.getCurrentLocale() == 'ar'
                ? "تم التسجيل بنجاح!"
                : "Signup successful!"
        ),
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingSeen', true);

      // Navigate after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/parentHome',
                (route) => false,
            arguments: parentNew,
          );
        }
      });

    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Add this line

    // Dispose all controllers
    for (var controller in nameControllers.values) {
      controller.dispose();
    }
    for (var controller in usernameControllers.values) {
      controller.dispose();
    }
    for (var controller in nationalityControllers.values) {
      controller.dispose();
    }
    for (var controller in passwordControllers.values) {
      controller.dispose();
    }
    for (var controller in confirmPasswordControllers.values) {
      controller.dispose();
    }
    for (var controller in birthdateControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildEnhancedUsernameField(int id) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).signuptitleusername,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: usernameControllers[id]!,
            validator: validateUsername,
            decoration: InputDecoration(
              hintText: S.of(context).signupinputfieldusername,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              prefixIcon: const Icon(Icons.tag_faces_outlined, color: Color.fromRGBO(108, 99, 255, 1)),
              suffixIcon: (isCheckingUsername[id] ?? false)
                  ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
                  : null,
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: usernameErrors[id] != null
                      ? Colors.red
                      : Colors.white.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: usernameErrors[id] != null
                      ? Colors.red
                      : Colors.white.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: usernameErrors[id] != null
                      ? Colors.red
                      : Colors.white,
                  width: 2,
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
              errorStyle: const TextStyle(color: Colors.red),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          // Show username error message
          if (usernameErrors[id] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12),
              child: Text(
                usernameErrors[id]!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContainer(BuildContext context, int id) {
    return Form(
      key: formKeys[id],
      autovalidateMode: (autoValidateStates[id] ?? false)
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Container(
        key: containerKeys[id], // Add this line
        width: MediaQuery.of(context).size.width - 50,
        margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: const Color.fromRGBO(30, 27, 27, 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Add/Remove buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.green),
                      onPressed: _addContainer,
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.red),
                      onPressed: containers.length > 1
                          ? () => _removeContainer(id)
                          : null,
                    ),
                  ],
                ),
              ],
            ),

            // Image.asset('assets/images/child2.png'),

            // Name field
            Signupinputfield(
              S.of(context).signupinputfieldname,
              S.of(context).signuptitlename,
              255, 255, 255, 0.1,
              255, 255, 255, 1,
              false,
              true,
              nameControllers[id]!,
                  (value) => value!.isEmpty ?
              (Intl.getCurrentLocale() == 'ar' ? 'الاسم مطلوب' : 'Name is required') : null,
            ),

            // Enhanced username field
            _buildEnhancedUsernameField(id),

            // Nationality dropdown
            Childsignupcountrydropdown(
              S.of(context).signupinputfieldnationality,
              S.of(context).signuptitlenationality,
              255, 255, 255, 0.1,
              0, 0, 0, 1,
              false,
              true,
              nationalityControllers[id]!.text.isNotEmpty
                  ? nationalityControllers[id]!.text
                  : null,
                  (newValue) {
                setState(() {
                  nationalityControllers[id]!.text = newValue ?? '';
                });
              },
                  (value) => value == null || value.isEmpty ?
              (Intl.getCurrentLocale() == 'ar' ? 'الجنسية مطلوبة' : 'Nationality is required') : null,
            ),

            // Password field
            Signupinputfield(
              S.of(context).signupinputfieldpassword,
              S.of(context).signuptitlepassword,
              255, 255, 255, 0.1,
              255, 255, 255, 1,
              false,
              true,
              passwordControllers[id]!,
              validatePassword,
            ),

            // Confirm password field
            Signupinputfield(
              S.of(context).signupinputfieldpassword,
              S.of(context).signuptitleconfirmpassword,
              255, 255, 255, 0.1,
              255, 255, 255, 1,
              false,
              true,
              confirmPasswordControllers[id]!,
                  (value) => validateConfirmPassword(id, value),
            ),

            // Birthdate picker
            GuardianDateTimePicker(
              controller: birthdateControllers[id]!,
              quardian: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return S.of(context).birthdateValidation;
                }
                return null;
              },
            ),

            // Enhanced gender selection
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Intl.getCurrentLocale() == 'ar' ? 'اختر الجنس' : 'Select Gender',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (selectedGenders[id]?.isEmpty ?? true) && (autoValidateStates[id] ?? false)
                            ? Colors.red
                            : Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Malefemale(
                          onGenderSelected: (gender) {
                            setState(() {
                              selectedGenders[id] = gender;
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
                        if ((selectedGenders[id]?.isEmpty ?? true) && (autoValidateStates[id] ?? false))
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                Intl.getCurrentLocale() == 'ar'
                                    ? 'يرجى اختيار الجنس'
                                    : 'Please select gender',
                                style: const TextStyle(
                                  color: Colors.red,
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
            ),
          ],
        ),
      ),
    );
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
          S.of(context).continuesignuptitle,
          style: TextStyle(
            fontSize: Intl.getCurrentLocale() == 'ar' ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        child: Center(
          child: SingleChildScrollView(
            controller: _scrollController, // Add this line
            child: Column(
              children: [
                // Enhanced Progress Bar
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Progressbar(40, 40, 108, 99, 255, true, true),
                      Progressbar(100, 16, 108, 99, 255, false, false),
                      Progressbar(40, 40, 108, 99, 255, true, false),
                    ],
                  ),
                ),

                // Container forms
                Column(
                  children: containers.map((id) => _buildContainer(context, id)).toList(),
                ),

                // Enhanced Create Account Button
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 30, 20, 40),
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _areAllFormsFilled ? signup : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _areAllFormsFilled
                          ? const Color.fromRGBO(108, 99, 255, 1)
                          : Colors.grey[300],
                      foregroundColor: _areAllFormsFilled ? Colors.white : Colors.grey[600],
                      elevation: _areAllFormsFilled ? 3 : 0,
                      shadowColor: const Color.fromRGBO(108, 99, 255, 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[600],
                    ),
                    child: _isSubmitting
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
                          S.of(context).createaccountbutton,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _areAllFormsFilled ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: _areAllFormsFilled ? Colors.white : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}