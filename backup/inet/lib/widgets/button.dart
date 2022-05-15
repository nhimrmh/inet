
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget MyButton({Function clickedFunction, String title, IconData icon, Color color}) {
  return GestureDetector(
    onTap: (){
      clickedFunction();
    },
    child: Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon != null ? Icon(icon, color: Colors.white,) : Container(),
          Container(
            margin: EdgeInsets.only(left: 15, right: 15),
            child: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
          )
        ],
      ),
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(25))
      ),
    ),
  );
}

Widget MyIconButton({Function clickedFunction, String title, IconData icon, Color color}) {
  return GestureDetector(
    onTap: (){
      clickedFunction();
    },
    child: Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          icon != null ? Icon(icon, color: Colors.white,) : Container(),
          Expanded(child: Container(
            margin: EdgeInsets.only(right: 15),
            child: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          ))
        ],
      ),
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(10))
      ),
    ),
  );
}