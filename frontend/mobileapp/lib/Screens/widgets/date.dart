import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/generated/l10n.dart';

class DateTimePicker extends FormField<String> {
  DateTimePicker({
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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 300,
            margin: const EdgeInsets.fromLTRB(0, 30, 0, 3),
            decoration: BoxDecoration(
              color: flag
                  ? const Color.fromRGBO(108, 99, 255, 0.1)
                  : const Color.fromRGBO(255, 255, 255, 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              style: TextStyle(
                color: !flag
                    ? Colors.black
                    : const Color.fromRGBO(255, 255, 255, 1),
              ),
              controller: controller,
              readOnly: true,
              onTap: () async {
                DateTime now = DateTime.now();
                DateTime maxDate = isGuardian
                    ? now.subtract(const Duration(days: 15 * 365))
                    : now.subtract(const Duration(days: 4 * 365));
                DateTime minDate = DateTime(1980);

                DateTime? picked = await showDatePicker(
                  context: field.context,
                  initialDate: maxDate,
                  firstDate: minDate,
                  lastDate: maxDate,
                );

                if (picked != null) {
                  final formatted = DateFormat('yyyy-MM-dd').format(picked);
                  controller.text = formatted;
                  field.didChange(formatted);
                }
              },
              decoration: InputDecoration(
                labelText: S.of(field.context).signuptitlebirthdate,
                filled: true,
                fillColor: Colors.transparent,
                prefixIcon:
                Icon(Icons.calendar_today, color: Colors.grey[750]),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: flag
                        ? const Color.fromRGBO(108, 99, 255, 1)
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
          if (field.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 8),
              child: Text(
                field.errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            )
        ],
      );
    },
  );
}
