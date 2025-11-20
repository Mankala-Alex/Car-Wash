import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import 'custome_textbox_label.dart';

class CustomDatePicker extends StatelessWidget {
  final String? labelText;
  final String hintText;
  final Widget? suffixIcon;
  final int? maxLines;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool isBorderRequired;
  final bool realOnly;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool isRequired;
  final ValueChanged<DateTime>? onDateChanged;
  final bool isFutureDateDisable;

  CustomDatePicker({
    super.key,
    this.labelText,
    required this.hintText,
    this.suffixIcon,
    this.maxLines = 1,
    TextEditingController? controller,
    this.validator,
    this.enabled = true,
    this.realOnly = false,
    this.isBorderRequired = true,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.isRequired = false,
    this.onDateChanged,
    this.isFutureDateDisable = false,
  }) : controller = controller ?? TextEditingController();

  Future<void> selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime initialDateValue = initialDate ?? DateTime.now();
    if (controller.text.isNotEmpty) {
      try {
        initialDateValue = DateFormat('dd/MM/yyyy').parse(controller.text);
      } catch (_) {
        // Handle parse errors if the text is not a valid date
      }
    }
    // DateTime initialDate = DateTime.now();
    // if (controller.text.isNotEmpty) {
    //   initialDate = DateFormat('dd/MM/yyyy').parse(controller.text);
    // }

    final customTheme = CustomTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: initialDateValue,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      // barrierColor: customTheme.bgBackDropColor,
      selectableDayPredicate: isFutureDateDisable
          ? (DateTime date) {
              // Disable future dates if isFutureDateDisable is true
              return date.isBefore(DateTime.now());
            }
          : null,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: customTheme
                  .primaryColor, // Background color of the selected date
              onPrimary: Colors.white, // Text color of the selected date
              surface: Colors.white, // Background color of the dialog
              onSurface: Colors.black, // Text color of the dates
            ),
            //dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
            // dialogTheme: DialogThemeData(
            //   backgroundColor: Colors.white,
            // ), // Background color of the dialog
          ),
          child: child!,
        );
      },
    );
    controller.text = DateFormat('dd/MM/yyyy').format(
      pickedDate!,
    ); //"${pickedDate.toLocal()}".split(' ')[0]; // Format the date as you like
    if (onDateChanged != null) {
      onDateChanged!(pickedDate); // Call the callback
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomeTextBoxLabel(
      controller: controller,
      validator: validator,
      realOnly: true,
      hintText: hintText,
      isRequired: isRequired,
      labelText: labelText,
      isBorderRequired: isBorderRequired,
      onTap: () {
        selectDate(context, controller);
      },
      suffixIcon: const Icon(
        Icons.date_range,
        size: 20,
        color: Color.fromARGB(255, 145, 146, 158),
      ),
    );
  }
}
