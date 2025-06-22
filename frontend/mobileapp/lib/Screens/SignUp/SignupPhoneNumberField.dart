import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:mobileapp/generated/l10n.dart';
import 'package:mobileapp/global/fns.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class Signupphonenumberfield extends StatelessWidget {

  final TextEditingController controller;

  const Signupphonenumberfield(
  this.title,
  this.controller,
  {super.key});

    final String title;

  @override
  Widget build(BuildContext context) {
    return  Container(
      margin: const EdgeInsets.fromLTRB(0, 30, 0, 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
            fontSize: 18
          ),),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 55,
            margin: const EdgeInsets.fromLTRB(0, 3, 0, 3),
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromRGBO(108, 99, 255, 0.1),
              ),
              child: IntlPhoneField(
                controller: controller,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.left,
                textAlignVertical: const TextAlignVertical(y: 0),
                dropdownTextStyle: const TextStyle(
                  fontSize: 18,
                ),
                style: const TextStyle(
                  fontSize: 18,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none, // No border
                  // contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 0), // Remove internal padding
                ),
                initialCountryCode: 'EG',
                languageCode: isArabic() ? 'ar' : 'en',
                pickerDialogStyle: PickerDialogStyle(
                  searchFieldInputDecoration: InputDecoration(
                    hintText: S.of(context).phonenumbersearch, // Custom search hint text
                  ),
                ),
                onChanged: (phone) {
                  print(phone.completeNumber);
                },
              )
          ),
        ],
      ),
    );
  }
}