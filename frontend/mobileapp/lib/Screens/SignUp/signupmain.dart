import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/Screens/widgets/MaleFemale.dart';
import 'package:mobileapp/Screens/SignUp/ProgressBar.dart';
import 'package:mobileapp/Screens/widgets/SignupEmailInputField.dart';
import 'package:mobileapp/Screens/widgets/SignupInputField.dart';
import 'package:mobileapp/Screens/SignUp/SignupPhoneNumberField.dart';
import 'package:mobileapp/Screens/widgets/successSnackBar.dart';
import 'package:mobileapp/Services/google_auth_parent_service.dart';
import 'package:mobileapp/classes/validators.dart';
import 'package:mobileapp/Services/signup_service.dart';
import 'package:mobileapp/generated/l10n.dart';
import 'package:mobileapp/models/parent.dart';

// Import your AuthParentService if needed:
// import 'package:mobileapp/Services/auth_parent_service.dart';

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
  String? confirmPasswordError; // Error message for password validation

  // Callback function to update gender
  void _updateGender(String gender) {
    setState(() {
      selectedGender = gender;
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
    super.dispose();
  }

  void signup() async {
    if (!_formKey.currentState!.validate()) {
      print("Form validation failed");
      return;
    }

    String name = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    String phoneNumber = phoneNumberController.text;
    String date = birthdateController.text;
    String gender = selectedGender;
    String nationality = nationalityController.text;

    // Convert displayed gender to 'male' or 'female'
    gender = (gender == S.of(context).genderMale) ? 'male' : 'female';

    print("Name: $name, Email: $email, Phone: $phoneNumber");

    // Parent? parent = await SignupService.signupParent(
    //     name, username, email, password, phoneNumber, nationality, date, gender
    // );
    Parent? parent = Parent(
      name: name,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      birthdate: date,
      nationality: nationality,
      gender: gender,
    );

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
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(108, 99, 255, 0.1),
        title: Text(
          S.of(context).title,
          style: TextStyle(
            fontSize: Intl.getCurrentLocale() == 'ar' ? 35 : 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Progressbar(35, 35, 217, 217, 217, true, false),
                Progressbar(100, 14, 217, 217, 217, false, false),
                Progressbar(35, 35, 217, 217, 217, true, false),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width - 100,
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Image.asset('assets/images/parent.png'),
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Signupinputfield(
                    S.of(context).signupinputfieldname,
                    S.of(context).signuptitlename,
                    108,
                    99,
                    255,
                    0.1,
                    0,
                    0,
                    0,
                    0.3,
                    true,
                    false,
                    nameController,
                    Validators.validateName,
                  ),
                  SignupInputFieldEmail(
                    S.of(context).signupinputfieldemail,
                    S.of(context).signuptitleemail,
                    108,
                    99,
                    255,
                    0.1,
                    0,
                    0,
                    0,
                    0.3,
                    true,
                    false,
                    emailController,
                    true,
                  ),
                  Signupphonenumberfield(
                    S.of(context).signuptitlephonenumber,
                    phoneNumberController,
                  ),
                  Signupinputfield(
                    S.of(context).signupinputfieldnationality,
                    S.of(context).signuptitlenationality,
                    108,
                    99,
                    255,
                    0.1,
                    0,
                    0,
                    0,
                    0.3,
                    true,
                    false,
                    nationalityController,
                    null,
                  ),
                  Signupinputfield(
                    S.of(context).signupinputfieldpassword,
                    S.of(context).signuptitlepassword,
                    108,
                    99,
                    255,
                    0.1,
                    0,
                    0,
                    0,
                    0.3,
                    true,
                    false,
                    passwordController,
                    Validators.validatePassword,
                  ),
                  Signupinputfield(
                    S.of(context).signupinputfieldpassword,
                    S.of(context).signuptitleconfirmpassword,
                    108,
                    99,
                    255,
                    0.1,
                    0,
                    0,
                    0,
                    0.3,
                    true,
                    false,
                    confirmPasswordController,
                    validateConfirmPassword,
                  ),
                  DateTimePicker(
                    controller: birthdateController,
                    flag: true,
                  ),
                  Malefemale(
                    onGenderSelected: _updateGender,
                    flag: true,
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 35),
              height: 50,
              width: MediaQuery.of(context).size.width - 150,
              child: ElevatedButton(
                onPressed: () {
                  print("Sign Up button clicked");
                  signup();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(168, 209, 209, 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  S.of(context).signupbutton,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // === REPLACED ROW OF SOCIAL LOGIN BUTTONS HERE ===
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () async {
                    final authService = AuthParentService();
                    // user is a Map<String, dynamic> from the backend if successful
                    final user = await authService.signInWithGoogle();

                    if (user != null) {
                      // Extract the 'parent' part of the response
                      final parentJson = user['parent'] as Map<String, dynamic>?;
                      if (parentJson != null) {
                        // Convert JSON to your Parent model
                        final parent = Parent.fromJson({
                          "id":          parentJson["_id"],
                          "name":        parentJson["name"],
                          "email":       parentJson["email"],
                          "phoneNumber": parentJson["phoneNumber"] ?? "",
                          "birthdate":   parentJson["birthdate"] ?? "",
                          "nationality": parentJson["nationality"] ?? "",
                          "gender":      parentJson["gender"] ?? "",
                        });

                        // Pass `parent` as arguments to the route
                        Navigator.pushReplacementNamed(
                          context,
                          '/parentHome',
                          arguments: parent,
                        );
                      }
                    }
                  },
                  icon: const FaIcon(FontAwesomeIcons.google),
                  color: Colors.red,
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {},
                  icon: const FaIcon(FontAwesomeIcons.facebook),
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {},
                  icon: const FaIcon(FontAwesomeIcons.apple),
                  color: Colors.black,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
