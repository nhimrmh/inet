import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

showAlertDialog(BuildContext context, String title, String des) {
  // show the dialog
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
    title: Text(title),
    content: Text(des, style: TextStyle(fontWeight: FontWeight.w400),),
    actions: [
      TextButton(
        child: Text("OK"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      )
    ],
  ));
}