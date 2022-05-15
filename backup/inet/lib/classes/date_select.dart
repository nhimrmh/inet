import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future selectDate(BuildContext context, DateTime initialDate) async {
  final DateTime picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2010,1),
      lastDate: DateTime(2099, 12)
  );
  return picked;
}