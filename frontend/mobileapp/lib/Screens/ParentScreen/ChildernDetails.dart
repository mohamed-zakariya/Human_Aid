import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/Services/parent_service.dart';
import 'package:mobileapp/classes/validators.dart';

import '../../Services/signup_service.dart';
import '../../generated/l10n.dart';
import '../../models/learner.dart';
import '../../models/parent.dart';
import '../widgets/MaleFemale.dart';
import '../widgets/SignupInputField.dart';
import '../widgets/date.dart';


class ChildrenDetails extends StatefulWidget {
  const ChildrenDetails({super.key, required this.parent});

  final Parent? parent;

  @override
  State<ChildrenDetails> createState() => _ChildrenDetailsState();
}

class _ChildrenDetailsState extends State<ChildrenDetails> {
  Parent? parent;
  List<Learner?>? children = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    parent = widget.parent;
    fetchChildren();
  }


  Future<void> fetchChildren() async {
    if (parent == null) {
      print("Parent is null");
      return;
    }
    try {
      List<Learner?>? data = await ParentService.getChildrenData(parent!.id);
      if (data == null){
        Navigator.pushReplacementNamed(context, "/intro");
      }
      setState(() {
        children = data ?? [];
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching children: $error");
      setState(() {
        isLoading = false;
      });
      Navigator.pushReplacementNamed(context, "/intro");
    }
  }

  String selectedGender = '';

  // Callback function to update gender
  void _updateGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
  }

  void showAddChildDialog() {
    final _formKey = GlobalKey<FormState>();
    TextEditingController nameController = TextEditingController();
    TextEditingController usernameController = TextEditingController();
    TextEditingController nationalityControllers = TextEditingController();
    TextEditingController passwordControllers = TextEditingController();
    TextEditingController confirmPasswordControllers = TextEditingController();
    TextEditingController birthdateControllers = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Learner"),
          content: SizedBox(
            // height: 250,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset('assets/images/girl.jpeg'),
                    Signupinputfield(
                      S.of(context).signupinputfieldname,
                      S.of(context).signuptitlename,
                      108, 99, 255, 0.1,
                      255, 255, 255, 1,
                      true,
                      false,
                      nameController,
                          Validators.validateName,
                    ),
                    Signupinputfield(
                      S.of(context).signupinputfieldusername,
                      S.of(context).signuptitleusername,
                      108, 99, 255, 0.1,
                      255, 255, 255, 1,
                      true,
                      false,
                      usernameController,
                          Validators.validateUsername,
                    ),
                    Signupinputfield(
                      S.of(context).signupinputfieldnationality,
                      S.of(context).signuptitlenationality,
                      108, 99, 255, 0.1,
                      255, 255, 255, 1,
                      true,
                      false,
                      nationalityControllers,
                          (value) => value!.isEmpty ? 'Nationality is required' : null,
                    ),
                    Signupinputfield(
                      S.of(context).signupinputfieldpassword,
                      S.of(context).signuptitlepassword,
                      108, 99, 255, 0.1,
                      255, 255, 255, 1,
                      true,
                      false,
                      passwordControllers,
                          Validators.validatePassword,
                    ),
                    Signupinputfield(
                      S.of(context).signupinputfieldpassword,
                      S.of(context).signuptitleconfirmpassword,
                      108, 99, 255, 0.1,
                      255, 255, 255, 1,
                      true,
                      false,
                      confirmPasswordControllers,
                          (value) {
                        if (value!.isEmpty) {
                          return 'Confirm password is required';
                        }
                        if (value != passwordControllers.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    DateTimePicker(
                      controller: birthdateControllers,
                      flag: true,
                    ),
                    Malefemale(
                      onGenderSelected: (gender) => _updateGender(gender),
                      flag: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String learnerName = nameController.text.trim();
                String username = usernameController.text.trim();

                if (!_formKey.currentState!.validate()) {
                  print("Form validation failed");
                  return;
                }
                else{
                  selectedGender = (selectedGender == S.of(context).genderMale)? 'male':'female';
                  setState(() async{
                    await SignupService.signupChild(
                      parent!.id!,
                      nameController.text,
                      usernameController.text,
                      passwordControllers.text,
                      nationalityControllers.text,
                      birthdateControllers.text,
                      selectedGender,
                      "child",
                    );
                    fetchChildren();
                    Navigator.pop(context);
                  });
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.blueAccent,
      Colors.greenAccent
    ];

    Color getRandomColor() {
      final Random random = Random();
      return colors[random.nextInt(colors.length)];
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      margin: const EdgeInsets.all(1),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Learner Members",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    alignment: WrapAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showAddChildDialog();
                        }, // showAddChildDialog
                        child: Column(
                          children: [
                            Container(
                              width: 85,
                              height: 85,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: Colors.white, width: 1.5),
                              ),
                              child: const Icon(Icons.add,
                                  color: Colors.white, size: 40),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Add",
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      if (children != null && children!.isNotEmpty)
                        ...children!.map(
                              (learner) {
                                // learner["progress"] ??
                            double progress =  55.0;
                            // learner["wordsLearned"] ??
                            int wordsLearned = 0;
                            // learner["sentencesCompleted"] ??
                            int sentencesCompleted = 0;
                            // learner["booksRead"] ??
                            int booksRead =  0;

                            return Card(
                              color: getRandomColor(),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: AssetImage(
                                            learner?.gender == 'male'
                                                ? "assets/images/boy.jpeg"
                                                : "assets/images/girl.jpeg",
                                          ),
                                          radius: 40,
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              showDeleteConfirmation(context, learner);
                                            }, // showDeleteConfirmation
                                            child: Container(
                                              decoration:
                                              const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red,
                                              ),
                                              child: const Icon(
                                                  Icons.remove,
                                                  color: Colors.white,
                                                  size: 18),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      learner?.name ?? "Unknown",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text("Grade 5 • Age 28",
                                        style:
                                        TextStyle(color: Colors.white)),

                                    // **Progress Bar**
                                    const SizedBox(height: 10),
                                    LinearProgressIndicator(
                                      value: progress/100,
                                      backgroundColor: Colors.grey[300],
                                      color: Colors.deepPurpleAccent,
                                      minHeight: 8,
                                    ),
                                    const SizedBox(height: 8),

                                    // **Stats**
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStatCard(
                                            "Words", wordsLearned),
                                        _buildStatCard(
                                            "Sentences", sentencesCompleted),
                                        _buildStatCard(
                                            "Books", booksRead),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ).toList(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count) {
    return Column(
      children: [
        Text(
          "$count",
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }

  /// Show confirmation dialog before deleting a child
  void showDeleteConfirmation(BuildContext context, learner) {
    TextEditingController passwordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Delete Learner"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Are you sure you want to delete this learner?"),
                  const SizedBox(height: 10),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          validator: Validators.validatePassword,
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Enter your password",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                          ),
                        ),
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      print("Form validation failed");
                      return;
                    }
                    bool childDeleted = await ParentService.deleteLearner(
                        parent!.id, passwordController.text, learner.username);

                    if (childDeleted) {
                      fetchChildren();
                      Navigator.pop(context);
                    } else {
                      setState(() {
                        errorMessage = (Intl.getCurrentLocale() == 'en')? "Password is incorrect!":"كلمة المرور غير صحيحة!";
                      });
                    }
                  },
                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }


  /// Function to delete a learner from the list
  void deleteChild(learner) {
    setState(() {
      children!.remove(learner);
    });
  }


}


