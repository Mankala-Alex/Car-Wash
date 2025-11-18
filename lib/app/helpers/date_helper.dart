import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final DateFormat dateFormat = DateFormat("MMM dd, yyyy");
final DateFormat dateFormat2 = DateFormat("yyyy-MM-dd");
final DateFormat dateFormatWithTime = DateFormat("yyyy-MM-dd hh:mm a");
final DateFormat timeformat = DateFormat("hh:mm a");
final DateFormat timeformatWithSS = DateFormat("HH:mm:ss");
final DateFormat dateFormatWithMnD = DateFormat("MMM dd");
final DateFormat dateToShow = DateFormat("dd-MM-yyyy");
final DateFormat dateWithFullMonth = DateFormat("dd/MMMM/yyyy");
final DateFormat dateToPayload = DateFormat("yyyy-MM-dd");
final DateFormat dateOnlyMonth = DateFormat("MMM");

dateWithFormat(date, dateFormatValue) {
  return DateTime.tryParse(date ?? "") != null
      ? dateFormatValue.format(DateTime.parse(date))
      : "--";
}

TimeOfDay stringToTimeOfDay(String tod) {
  final format = DateFormat.jm(); //"6:00 AM"
  return TimeOfDay.fromDateTime(format.parse(tod));
}

String formatToAmPm(String time24) {
  final inputFormat = DateFormat('HH:mm:ss');
  final outputFormat = DateFormat('hh:mm a');
  final dateTime = inputFormat.parse(time24);
  return outputFormat.format(dateTime);
}

String getWeekdayShort(DateTime date) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  return weekdays[date.weekday - 1]; // date.weekday: 1 (Mon) to 7 (Sun)
}
