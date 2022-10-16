import 'package:flutter/material.dart';

class UserButtons {
  final String visible;
  final String name;

  UserButtons(this.visible, this.name);

  UserButtons.fromJson(Map<String, dynamic> json)
      : visible = json['Visible'],
        name = json['Name'];
}
