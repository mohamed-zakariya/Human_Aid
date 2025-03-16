import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/Screens/ParentScreen/LearnerData.dart';
import 'package:mobileapp/Services/parent_service.dart';
import 'package:mobileapp/classes/validators.dart';
import 'package:mobileapp/global/fns.dart';

import '../../Services/signup_service.dart';
import '../../generated/l10n.dart';
import '../../models/learner.dart';
import '../../models/parent.dart';
import '../widgets/MaleFemale.dart';
import '../widgets/SignupInputField.dart';
import '../widgets/date.dart';


class LearnerDetails extends StatefulWidget {
  const LearnerDetails({super.key, required this.parent});

  final Parent? parent;

  @override
  State<LearnerDetails> createState() => _LearnerDetailsState();
}

class _LearnerDetailsState extends State<LearnerDetails> {
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
                      quardian: false,
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

    Color getColorForIndex(int index) {
      return colors[index % colors.length];
    }


    return Scaffold(
      appBar: AppBar(
      foregroundColor: Colors.white,
      backgroundColor: Colors.black87, // Match with the illustration background
      elevation: 0, // Removes shadow for a seamless look
      title: Text("${widget.parent!.name} Dashboard",style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white
      ),),
      centerTitle: true,
    ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // const Text(
            //   "Learner Members",
            //   style: TextStyle(
            //     fontSize: 20,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.black,
            //   ),
            // ),
            // const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      alignment: WrapAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Colors.black87, Colors.black54], // Gradient effect
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(4, 4), // Adds shadow effect
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Adds space inside
                          width: MediaQuery.of(context).size.width,
                          height: 180, // Adjusted for better proportions
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center, // Center alignment
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Evenly space elements
                            children: [
                              const Expanded(
                                child: Text(
                                  "Learner Members",
                                  style: const TextStyle(
                                    color: Colors.white, // Changed to white for contrast
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15), // Rounded image corners
                                child: Image.asset(
                                  "assets/images/teacher.png",
                                  width: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (children != null && children!.isNotEmpty)
                          ...children!.map(
                                (learner) {

                              return Card(
                                color: getColorForIndex(children!.indexOf(learner)),
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
                                      Text("Age ${calculateAge(learner!.birthdate)}",
                                          style:
                                          const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.of(context).push(createRouteLearnerData(learner));
                                          // Add your logic to show more details
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black54, // Button color
                                          foregroundColor: Colors.white, // Text and icon color
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12), // Rounded corners
                                          ),
                                          elevation: 3, // Shadow effect
                                        ),
                                        icon: const Icon(Icons.arrow_right, size: 20), // Info icon
                                        label: const Text(
                                          "Show more",
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      )

                                    ],
                                  ),
                                ),
                              );
                            },
                          ).toList()
                        else
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.person_add, size: 60, color: Colors.grey),
                                SizedBox(height: 10),
                                Text(
                                  "No learners found!",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Click the + button to add learners.",
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                      ],
                    ),

                  ],
                ),

              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: (){
                  showAddChildDialog();
                },
                backgroundColor: Colors.redAccent,
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
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



