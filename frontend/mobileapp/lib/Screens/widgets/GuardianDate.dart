import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/generated/l10n.dart';

class GuardianDateTimePicker extends FormField<String> {
  GuardianDateTimePicker({
    Key? key,
    required TextEditingController controller,
    required bool quardian,
    FormFieldValidator<String>? validator,
  }) : super(
    key: key,
    validator: validator,
    initialValue: controller.text,
    builder: (FormFieldState<String> field) {
      final isGuardian = quardian;
      final flag = !isGuardian;

      return Container(
        margin: const EdgeInsets.fromLTRB(0, 16, 0, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Title to match other fields
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 4),
              child: Text(
                S.of(field.context).signuptitlebirthdate,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            // Enhanced Date Field Container
            _EnhancedDateField(
              controller: controller,
              field: field,
              isGuardian: isGuardian,
              flag: flag,
            ),

            // Error message styling
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

class _EnhancedDateField extends StatefulWidget {
  final TextEditingController controller;
  final FormFieldState<String> field;
  final bool isGuardian;
  final bool flag;

  const _EnhancedDateField({
    required this.controller,
    required this.field,
    required this.isGuardian,
    required this.flag,
  });

  @override
  State<_EnhancedDateField> createState() => _EnhancedDateFieldState();
}

class _EnhancedDateFieldState extends State<_EnhancedDateField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromRGBO(108, 99, 255, 0.08),
          boxShadow: [
            if (_isFocused)
              const BoxShadow(
                color: Color.fromRGBO(108, 99, 255, 0.15),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: TextField(
          controller: widget.controller,
          readOnly: true,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          onTap: () async {
            // Add focus effect when tapped
            setState(() {
              _isFocused = true;
            });

            DateTime now = DateTime.now();
            DateTime maxDate = widget.isGuardian
                ? now.subtract(const Duration(days: 15 * 365))
                : now.subtract(const Duration(days: 4 * 365));
            DateTime minDate = DateTime(1980);

            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: maxDate,
              firstDate: minDate,
              lastDate: maxDate,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: const Color.fromRGBO(108, 99, 255, 1),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black87,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            // Remove focus effect after date picker closes
            setState(() {
              _isFocused = false;
            });

            if (picked != null) {
              final formatted = DateFormat('yyyy-MM-dd', 'en').format(picked); // force Western digits
              widget.controller.text = formatted;
              widget.field.didChange(formatted);
            }

          },
          decoration: InputDecoration(
            hintText: S.of(context).signupinputfieldbirthdate ?? 'Select your birthdate',
            hintStyle: TextStyle(
              fontSize: 15,
              color: Colors.grey[500],
              fontWeight: FontWeight.w400,
            ),
            // Calendar prefix icon to match other fields
            prefixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: Color.fromRGBO(108, 99, 255, 1),
              size: 22,
            ),
            // Dropdown arrow suffix icon to indicate it's selectable
            suffixIcon: Icon(
              Icons.arrow_drop_down,
              color: Colors.grey[600],
              size: 24,
            ),
            filled: true,
            fillColor: Colors.transparent, // Container already has background
            contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.black.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromRGBO(108, 99, 255, 1),
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
          ),
        ),
      ),
    );
  }
}