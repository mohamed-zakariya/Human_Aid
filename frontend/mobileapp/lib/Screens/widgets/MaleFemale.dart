import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobileapp/generated/l10n.dart';

class Malefemale extends StatefulWidget {
  final ValueChanged<String> onGenderSelected;
  final String initialGender;
  final bool flag;

  const Malefemale({
    super.key,
    required this.onGenderSelected,
    required this.flag,
    this.initialGender = '',
  });

  @override
  _MalefemaleState createState() => _MalefemaleState();
}

class _MalefemaleState extends State<Malefemale> {
  late String selectedGender;


  @override
  void initState() {
    super.initState();
    selectedGender = widget.initialGender;
  }

  void _onGenderSelected(String gender) {
    setState(() {
      selectedGender = gender;
    });
    widget.onGenderSelected(gender);
  }

  @override
  Widget build(BuildContext context) {
    String male = S.of(context).genderMale;
    String female = S.of(context).genderFemale;
    bool flag = widget.flag;


    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          child: Text(
            selectedGender.isEmpty
                ? S.of(context).genderSelect
                : selectedGender,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: flag? Colors.black:Colors.white),
          ),
        ),
        Container(
          width: 300,
          height: 80,
          margin: const EdgeInsets.only(bottom: 3),
          padding: const EdgeInsets.only(top: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _genderOption(male, FontAwesomeIcons.mars, Colors.blue),
              const SizedBox(width: 20),
              _genderOption(female, FontAwesomeIcons.venus, Colors.pink),
            ],
          ),
        ),
      ],
    );
  }

  Widget _genderOption(String gender, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _onGenderSelected(gender),
      child: Container(
        width: 70,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selectedGender == gender ? color.withOpacity(0.3) : Colors.grey.shade200,
        ),
        child: Center(
          child: FaIcon(
            icon,
            size: 50.0,
            color: selectedGender == gender ? color : color.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
