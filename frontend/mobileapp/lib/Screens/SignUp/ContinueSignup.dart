import 'package:flutter/material.dart';
import 'package:mobileapp/Screens/ParentScreen/ParentMain.dart';
import 'package:mobileapp/Screens/widgets/MaleFemale.dart';
import 'package:mobileapp/Screens/SignUp/ProgressBar.dart';
import 'package:mobileapp/Screens/widgets/SignupInputField.dart';
import 'package:mobileapp/Screens/widgets/successSnackBar.dart';
import 'package:mobileapp/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Services/signup_service.dart';
import '../../models/learner.dart';
import '../../models/parent.dart';
import '../widgets/date.dart';

class Continuesignup extends StatefulWidget {

  final Parent? parent;

  const Continuesignup({super.key, this.parent});

  @override
  State<Continuesignup> createState() => _ContinuesignupState();
}
class _ContinuesignupState extends State<Continuesignup> {

  final List<int> containers = [];
  final Map<int, GlobalKey<FormState>> formKeys = {};
  final Map<int, TextEditingController> nameControllers = {};
  final Map<int, TextEditingController> usernameControllers = {};
  final Map<int, TextEditingController> nationalityControllers = {};
  final Map<int, TextEditingController> passwordControllers = {};
  final Map<int, TextEditingController> confirmPasswordControllers = {};
  final Map<int, TextEditingController> birthdateControllers = {};
  final Map<int, String> selectedGenders = {}; // Map to store selected gender per child

  // String selectedGender = '';

  late Parent? parent = widget.parent;

  @override
  void initState() {
    super.initState();
    _addContainer();
  }

  void _addContainer() {
    setState(() {
      int id = containers.isEmpty ? 1 : containers.last + 1;
      containers.add(id);
      formKeys[id] = GlobalKey<FormState>();

      nameControllers[id] = TextEditingController();
      usernameControllers[id] = TextEditingController();
      nationalityControllers[id] = TextEditingController();
      passwordControllers[id] = TextEditingController();
      confirmPasswordControllers[id] = TextEditingController();
      birthdateControllers[id] = TextEditingController();
      selectedGenders[id] = ''; // Initialize gender

    });
  }

  void _removeContainer(int id) {
    setState(() {
      containers.remove(id);
      formKeys.remove(id);
      nameControllers.remove(id);
      usernameControllers.remove(id);
      nationalityControllers.remove(id);
      passwordControllers.remove(id);
      confirmPasswordControllers.remove(id);
      birthdateControllers.remove(id);
      selectedGenders.remove(id);
    });
  }


  void _updateGender(int id, String gender) {
    setState(() {
      selectedGenders[id] = gender;
    });
  }

  bool _validateAllForms() {
    bool isValid = true;
    setState(() {
      for (var key in formKeys.values) {
        if (!(key.currentState?.validate() ?? false)) {
          isValid = false;
        }
      }
    });
    return isValid;
  }


  void signup() async {
    if (!_validateAllForms()) {
      print('Some fields are missing');
      return;
    }

    // Check if parent object is null before using it
    if (parent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Parent data is missing. Please try again.")),
      );
      return;
    }

    // Signup Parent
    Parent? parentNew = await SignupService.signupParent(
      parent!.name,
      parent!.email,
      parent!.password ?? "",
      // Use a default value instead of !
      parent!.phoneNumber,
      parent!.nationality,
      parent!.birthdate,
      parent!.gender,
    );

    if (parentNew == null || parentNew.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup failed. Please try again.")),
      );
      return;
    }
    // print("parent id ${parentNew.id}");
    // Use a for loop instead of forEach to properly await
    for (var key in nameControllers.keys) {
      // Ensure controllers and gender are not null before using !
      if (nameControllers[key] == null ||
          usernameControllers[key] == null ||
          passwordControllers[key] == null ||
          nationalityControllers[key] == null ||
          birthdateControllers[key] == null ||
          selectedGenders[key] == null) {
        continue; // Skip if any field is null
      }

      selectedGenders[key] = (selectedGenders[key] == S
          .of(context)
          .genderMale) ? 'male' : 'female';

      await SignupService.signupChild(
        parentNew.id!,
        // Now it's safe to use !
        nameControllers[key]!.text,
        usernameControllers[key]!.text,
        passwordControllers[key]!.text,
        nationalityControllers[key]!.text,
        birthdateControllers[key]!.text,
        selectedGenders[key]!,
        "child",
      );
    }

    // Show success message after all signups complete
    ScaffoldMessenger.of(context).showSnackBar(
      successSnackBar("Signup successful!"),
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingSeen', true);

    // Delay navigation by 3 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/parentHome',
            (route) => false, // Removes all previous routes
        arguments: parentNew, // Passing the parent object
      );
    });
  }





  Widget _buildContainer(BuildContext context, int id) {
    return Form(
      key: formKeys[id],
      child: Container(
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
            Image.asset('assets/images/child2.png'),
            Signupinputfield(
              S.of(context).signupinputfieldname,
              S.of(context).signuptitlename,
              255, 255, 255, 0.1,
              255, 255, 255, 1,
              false,
              true,
              nameControllers[id]!,
                  (value) => value!.isEmpty ? 'Name is required' : null,
            ),
            Signupinputfield(
              S.of(context).signupinputfieldusername,
              S.of(context).signuptitleusername,
              255, 255, 255, 0.1,
              255, 255, 255, 1,
              false,
              true,
              usernameControllers[id]!,
                  (value) => value!.isEmpty ? 'Username is required' : null,
            ),
            Signupinputfield(
              S.of(context).signupinputfieldnationality,
              S.of(context).signuptitlenationality,
              255, 255, 255, 0.1,
              255, 255, 255, 1,
              false,
              true,
              nationalityControllers[id]!,
                  (value) => value!.isEmpty ? 'Nationality is required' : null,
            ),
            Signupinputfield(
              S.of(context).signupinputfieldpassword,
              S.of(context).signuptitlepassword,
              255, 255, 255, 0.1,
              255, 255, 255, 1,
              false, // Password field
              true,
              passwordControllers[id]!,
                  (value) => value!.isEmpty ? 'Password is required' : null,
            ),
            Signupinputfield(
              S.of(context).signupinputfieldpassword,
              S.of(context).signuptitleconfirmpassword,
              255, 255, 255, 0.1,
              255, 255, 255, 1,
              false, // Password field
              true,
              confirmPasswordControllers[id]!,
                  (value) {
                if (value!.isEmpty) {
                  return 'Confirm password is required';
                }
                if (value != passwordControllers[id]!.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            DateTimePicker(
              controller: birthdateControllers[id]!,
              quardian: false,
            ),
            Malefemale(
              onGenderSelected: (gender) => _updateGender(id, gender),
              flag: false,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).continuesignuptitle,
          style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Row(
                  textDirection: TextDirection.ltr,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Progressbar(40, 40, 238, 190, 198, true, true),
                    Progressbar(100, 16, 238, 190, 198, false, false),
                    Progressbar(40, 40, 217, 217, 217, true, false),
                  ],
                ),
                Column(
                  children:
                  containers.map((id) => _buildContainer(context, id)).toList(),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 100,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      signup();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(238, 190, 198, 1),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      S.of(context).createaccountbutton,
                      style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
