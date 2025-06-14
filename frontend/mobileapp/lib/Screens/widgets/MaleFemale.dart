import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobileapp/generated/l10n.dart';

class Malefemale extends FormField<String> {
  Malefemale({
    Key? key,
    required ValueChanged<String> onGenderSelected,
    required bool flag,
    String initialGender = '',
    FormFieldValidator<String>? validator,
  }) : super(
    key: key,
    initialValue: initialGender,
    validator: validator,
    builder: (FormFieldState<String> field) {
      final selectedGender = field.value ?? '';
      final male = S.of(field.context).genderMale;
      final female = S.of(field.context).genderFemale;
      final flagColor = flag ? Colors.black : Colors.white;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            selectedGender.isEmpty
                ? S.of(field.context).genderSelect
                : selectedGender,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: flagColor,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _genderOption(
                context: field.context,
                gender: male,
                selected: selectedGender == male,
                icon: FontAwesomeIcons.mars,
                color: Colors.blue,
                onTap: () {
                  field.didChange(male);
                  onGenderSelected(male);
                },
              ),
              const SizedBox(width: 20),
              _genderOption(
                context: field.context,
                gender: female,
                selected: selectedGender == female,
                icon: FontAwesomeIcons.venus,
                color: Colors.pink,
                onTap: () {
                  field.didChange(female);
                  onGenderSelected(female);
                },
              ),
            ],
          ),
          if (field.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0),
              child: Text(
                field.errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      );
    },
  );

  static Widget _genderOption({
    required BuildContext context,
    required String gender,
    required bool selected,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected ? color.withOpacity(0.3) : Colors.grey.shade200,
        ),
        child: Center(
          child: FaIcon(
            icon,
            size: 50,
            color: selected ? color : color.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
