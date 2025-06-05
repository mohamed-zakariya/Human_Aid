import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/Screens/ParentScreen/learnerMembersTab/LearnerData.dart';
import 'package:mobileapp/Services/parent_service.dart';
import 'package:mobileapp/classes/validators.dart';
import 'package:mobileapp/global/fns.dart';
import 'package:mobileapp/models/overall_progress.dart';

import '../../../Services/signup_service.dart';
import '../../../generated/l10n.dart';
import '../../../models/learner.dart';
import '../../../models/parent.dart';
import '../../widgets/MaleFemale.dart';
import '../../widgets/SignupInputField.dart';
import '../../widgets/date.dart';

class LearnerDetails extends StatefulWidget {
  const LearnerDetails({super.key, this.parent});

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
    fetchLearners();
  }

  Future<void> fetchLearners() async {
    if (parent == null) {
      print("Parent is null");
      return;
    }
    try {
      List<Learner?>? data = await ParentService.getChildrenData(parent!.id);
      if (data == null) {
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

  Future<void> fetchProgressLearner(BuildContext context, Learner learner) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
        ),
      ),
    );

    try {
      OverallProgress? overallProgress = await ParentService.getLearnersProgress(parent!.id);




      UserExerciseProgress? userProgress;
      if (overallProgress != null) {
        userProgress = overallProgress.progress.cast<UserExerciseProgress?>().firstWhere(
              (progress) => progress?.userId == learner.id,
          orElse: () => null,
        );
      }

      Navigator.of(context, rootNavigator: true).pop();

      if (userProgress != null) {

        Navigator.of(context).push(createRouteLearnerData(learner, userProgress));
      } else {
        Navigator.of(context).push(createRouteLearnerData(learner));
      }
    } catch (error) {
      Navigator.of(context, rootNavigator: true).pop();
      print("Error fetching learner progress: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to load learner progress, please try again."),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  String selectedGender = '';

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
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  S.of(context).addNewLearner,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 400,
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
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
                                return S.of(context).confirmPasswordRequired;
                              }
                              if (value != passwordControllers.text) {
                                return S.of(context).passwordMismatch;
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
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Text(
                          S.of(context).cancel,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            print("Form validation failed");
                            return;
                          }
                          selectedGender = (selectedGender == S.of(context).genderMale) ? 'male' : 'female';
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
                          fetchLearners();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          S.of(context).add,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Text(
          S.of(context).dashboardTitle(parent!.name),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                S.of(context).learner_members,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Manage your learners' accounts",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "${children?.length ?? 0} Learners",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset(
                            "assets/images/teacher.png",
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Section
          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            )
                : children != null && children!.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.all(24),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7, // Adjusted for better fit
                ),
                itemCount: children!.length,
                itemBuilder: (context, index) {
                  final learner = children![index];
                  final colors = [
                    const Color(0xFF6366F1),
                    const Color(0xFF8B5CF6),
                    const Color(0xFF06B6D4),
                    const Color(0xFF10B981),
                    const Color(0xFFF59E0B),
                    const Color(0xFFEF4444),
                  ];
                  final color = colors[index % colors.length];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header with gradient
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color,
                                color.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: CircleAvatar(
                                    backgroundImage: AssetImage(
                                      learner?.gender == 'male'
                                          ? "assets/images/boy.jpeg"
                                          : "assets/images/girl.jpeg",
                                    ),
                                    radius: 30,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => showDeleteConfirmation(context, learner),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  formatLearnerName(learner?.name),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "Age ${calculateAge(learner!.birthdate)}",
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => fetchProgressLearner(context, learner),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: color,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          S.of(context).showMore,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.school,
                      size: 64,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "No learners found!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    S.of(context).clickToAddLearners,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddChildDialog,
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(Icons.add),
        label: const Text(
          "Add Learner",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void showDeleteConfirmation(BuildContext context, learner) {
    TextEditingController passwordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red[600],
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Delete Learner",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Are you sure you want to delete this learner? This action cannot be undone.",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
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
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF6366F1)),
                              ),
                            ),
                          ),
                          if (errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: Colors.red[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }
                              bool childDeleted = await ParentService.deleteLearner(
                                  parent!.id, passwordController.text, learner.username);

                              if (childDeleted) {
                                fetchLearners();
                                Navigator.pop(context);
                              } else {
                                setState(() {
                                  errorMessage = (Intl.getCurrentLocale() == 'en')
                                      ? "Password is incorrect!"
                                      : "كلمة المرور غير صحيحة!";
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Delete",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper function to format names (get first two names only)
  String formatLearnerName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return "Unknown";
    }

    List<String> nameParts = fullName.trim().split(RegExp(r'\s+'));

    if (nameParts.length == 1) {
      return nameParts[0];
    } else if (nameParts.length >= 2) {
      return "${nameParts[0]} ${nameParts[1]}";
    }

    return fullName.trim();
  }
}