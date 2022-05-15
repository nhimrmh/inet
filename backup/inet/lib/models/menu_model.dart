import 'package:flutter/cupertino.dart';

class MenuModel {
  String _title;
  Icon _icon;
  Color _color;
  String _image;


  String get image => _image;

  set image(String value) {
    _image = value;
  }

  String get title => _title;

  set title(String value) {
    _title = value;
  }

  Icon get icon => _icon;

  set icon(Icon value) {
    _icon = value;
  }

  Color get color => _color;

  set color(Color value) {
    _color = value;
  }
}