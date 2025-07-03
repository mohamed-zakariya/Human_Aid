import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/generated/l10n.dart';

class DateTimePicker extends FormField<String> {
  DateTimePicker({
    Key? key,
    required TextEditingController controller,
    required bool quardian,
    FormFieldValidator<String>? validator,
    String? hintText,
    String? labelText,
  }) : super(
    key: key,
    validator: validator,
    initialValue: controller.text,
    builder: (FormFieldState<String> field) {
      final isGuardian = quardian;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: field.hasError
                    ? Colors.red
                    : Colors.grey[300]!,
                width: field.hasError ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  await _selectDate(field.context, controller, isGuardian, field);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: const Color.fromRGBO(249, 178, 136, 1),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.text.isEmpty
                              ? (hintText ?? S.of(field.context).signupinputfieldbirthdate)
                              : _formatDisplayDate(controller.text),
                          style: TextStyle(
                            fontSize: 16,
                            color: controller.text.isEmpty
                                ? Colors.grey[500]
                                : Colors.black87,
                            fontWeight: controller.text.isEmpty
                                ? FontWeight.normal
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey[600],
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (field.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      field.errorText!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );

  static Future<void> _selectDate(
      BuildContext context,
      TextEditingController controller,
      bool isGuardian,
      FormFieldState<String> field,
      ) async {
    DateTime now = DateTime.now();
    DateTime maxDate = isGuardian
        ? now.subtract(const Duration(days: 15 * 365)) // 15+ years old for guardian
        : now.subtract(const Duration(days: 4 * 365));  // 4+ years old for child
    DateTime minDate = DateTime(1940); // More reasonable minimum date

    // Set initial date to a reasonable default if controller is empty
    DateTime initialDate = maxDate;
    if (controller.text.isNotEmpty) {
      try {
        DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(controller.text);
        if (parsedDate.isBefore(maxDate) && parsedDate.isAfter(minDate)) {
          initialDate = parsedDate;
        }
      } catch (e) {
        // If parsing fails, use maxDate as initial
        initialDate = maxDate;
      }
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: maxDate,
      helpText: isGuardian
          ? 'Select Guardian Birthdate'
          : 'Select Child Birthdate',
      cancelText: S.of(context).cancel ?? 'Cancel',
      confirmText: S.of(context).ok ?? 'OK',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color.fromRGBO(249, 178, 136, 1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = DateFormat('yyyy-MM-dd', 'en').format(picked);
      controller.text = formatted;
      field.didChange(formatted);
    }
  }

  static String _formatDisplayDate(String dateString) {
    try {
      DateTime date = DateFormat('yyyy-MM-dd').parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }
}

// Extension to add validation helper methods
extension DateTimePickerValidation on String {
  bool get isValidAge {
    try {
      DateTime birthDate = DateFormat('yyyy-MM-dd').parse(this);
      DateTime now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age >= 4; // Minimum age requirement
    } catch (e) {
      return false;
    }
  }

  bool get isValidGuardianAge {
    try {
      DateTime birthDate = DateFormat('yyyy-MM-dd').parse(this);
      DateTime now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age >= 15; // Minimum guardian age requirement
    } catch (e) {
      return false;
    }
  }
}