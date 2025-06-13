import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/Screens/widgets/MaleFemale.dart';
import 'package:mobileapp/Screens/widgets/SignupInputField.dart';
import 'package:mobileapp/Screens/SignUp/SignupPhoneNumberField.dart';
import 'package:mobileapp/Screens/widgets/SignupUsernameInputField.dart';
import 'package:mobileapp/classes/validators.dart';
import 'package:mobileapp/generated/l10n.dart';
import 'package:mobileapp/models/learner.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../Services/signup_service.dart';
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
  String? confirmPasswordError; // Error message for password validation


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

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the tree
    nameController.dispose();
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
    String username = usernameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String date = birthdateController.text;
    String gender = selectedGender;
    String nationality = nationalityController.text;

    gender = (gender == S.of(context).genderMale)? 'male':'female';


    // print("Submitting signup request...");
    print("Name: $name, Username: $username");


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
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/Learner-Home',
              (route) => false, // Removes all previous routes
          arguments: learner, // Passing the parent object
        );
      });

    } else {
      print("Failed to create account: Learner is null");
    }
  }




  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromRGBO(249, 178, 136, 1),
          title: Text(S.of(context).title, style: TextStyle(
            fontSize: Intl.getCurrentLocale() == 'ar'? 35:25,
            fontWeight: FontWeight.bold,
          ),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            const Center(
              child: CircleAvatar(
                radius: 80, // Half of 200 to make it circular
                backgroundImage: AssetImage('assets/images/girl.jpeg',),
              ),
            )
            ,
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Signupinputfield(S.of(context).signupinputfieldname, S.of(context).signuptitlename, 108, 99, 255, 0.1, 0, 0, 0, 0.3, true, false, nameController, Validators.validateName),
                  SignupInputFieldUsername(S.of(context).signupinputfieldusername, S.of(context).signuptitleusername, 108, 99, 255, 0.1, 0, 0, 0, 0.3, true, false, usernameController),
                  SignupInputFieldEmail(S.of(context).signupinputfieldemail, S.of(context).signuptitleemail, 108, 99, 255, 0.1, 0, 0, 0, 0.3, true, false, emailController, false),
                  // Signupphonenumberfield(S.of(context).signuptitlephonenumber, phoneNumberController),
                  Signupinputfield(S.of(context).signupinputfieldnationality, S.of(context).signuptitlenationality, 108, 99, 255, 0.1, 0, 0, 0, 0.3, true, false, nationalityController, null,),
                  Signupinputfield(S.of(context).signupinputfieldpassword, S.of(context).signuptitlepassword, 108, 99, 255, 0.1, 0, 0, 0, 0.3, true, false, passwordController, Validators.validatePassword,),
                  Signupinputfield(S.of(context).signupinputfieldpassword, S.of(context).signuptitleconfirmpassword, 108, 99, 255, 0.1, 0, 0, 0, 0.3, true, false, confirmPasswordController, validateConfirmPassword,),
                  DateTimePicker(controller: birthdateController, quardian: false,),
                  Malefemale(onGenderSelected: _updateGender, flag: true,),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 35),
              height: 50,
              width: MediaQuery.of(context).size.width - 150,
              child: ElevatedButton(
                onPressed: () {
                  // Add your functionality here
                  print("Sign Up button clicked");
                  signup();

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(249, 178, 136, 1),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  S.of(context).createaccountbutton,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}