import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget EmptyWidget({String title}) {
  return Column (
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.warning, size: 30, color: Colors.red,),
      Container(
        margin: const EdgeInsets.only(top: 10),
        child: Text(title != null ? "Hiện chưa có $title, vui lòng thêm mới" : "Danh sách rỗng, vui lòng thêm mới"),
      )
    ],
  );
}