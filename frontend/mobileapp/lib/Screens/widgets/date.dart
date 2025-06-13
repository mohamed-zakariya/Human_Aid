import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/generated/l10n.dart';

class DateTimePicker extends StatefulWidget {


  const DateTimePicker({required this.controller, required this.quardian, super.key});

  final TextEditingController controller;
  final bool quardian;


  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {


  @override
  void initState() {
    super.initState();
    // TODO: implement initState
  }

  @override
  Widget build(BuildContext context) {

    bool flag = !widget.quardian;

    return  Container(
      width: 300,
      margin: const EdgeInsets.fromLTRB(0, 30, 0, 3),
      decoration: BoxDecoration(
        color: flag? const Color.fromRGBO(108, 99, 255, 0.1): const Color.fromRGBO(255, 255, 255, 0.1), // Apply the background color
        borderRadius: BorderRadius.circular(8), // Optional: Add rounded corners
      ),
      child: TextField(
        style: TextStyle(
          color: !flag? Colors.black: const Color.fromRGBO(255, 255, 255, 1),
        ),
        controller: widget.controller,
        decoration: InputDecoration(
          labelText: S.of(context).signuptitlebirthdate,
          filled: true,
          fillColor: Colors.transparent, // Ensure it doesn’t override the container color
          prefixIcon: Icon(Icons.calendar_today, color: Colors.grey[750],),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color:  flag? const Color.fromRGBO(108, 99, 255, 1): Colors.transparent,
            ), // Visible border on focus
          ),
        ),
        readOnly: true,
        onTap: _selectDate,
      ),
    );
  }
  Future<void> _selectDate() async {
    DateTime now = DateTime.now();

    DateTime maxDate = widget.quardian ? now.subtract(const Duration(days: 15 * 365)) : now.subtract(const Duration(days: 4 * 365));
    DateTime minDate = DateTime(1980);

    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: maxDate,
      firstDate: minDate,
      lastDate: maxDate,
    );

    if(_picked != null){
      setState(() {
        widget.controller.text = _picked.toString().split(" ")[0];
      });
    }
  }


}
