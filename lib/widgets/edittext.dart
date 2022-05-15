import 'package:colour/colour.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget MyTextEdittingController({
  TextEditingController controller,
  String title,
  String description,
  IconData icon,
  Function validator,
  Function onChangedFunction,
  TextInputType textInputType,
  Function onTap
}) {
  return TextFormField(
    controller: controller,
    autovalidateMode: AutovalidateMode.disabled,
    keyboardType: textInputType ?? TextInputType.text,
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    onTap: (){
      if(onTap != null) {
        onTap();
      }
    },
    onChanged: (text){
      if(onChangedFunction != null) {
        onChangedFunction();
      }
    },
    validator: (value) {
      if(validator != null) {
        return validator(value);
      }
      else {
        return null;
      }
    },
    decoration: icon != null ? InputDecoration(
      errorMaxLines: 2,
      filled: true,
      fillColor: Colour('#F8FAFF'),
      labelText: title,
      contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
      prefixIcon: Icon(icon, size: 25,),
      hintText: description, hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(
              color: Colour('#D1DBEE'),
              width: 1
          )
      ),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(
              color: Colour('#D1DBEE'),
              width: 1
          )
      ),

    ) :
    InputDecoration(
      errorMaxLines: 2,
      filled: true,
      fillColor: Colour('#F8FAFF'),
      labelText: title,
      contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
      hintText: description, hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(
              color: Colour('#D1DBEE'),
              width: 1
          )
      ),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(
              color: Colour('#D1DBEE'),
              width: 1
          )
      ),

    ),
  );
}