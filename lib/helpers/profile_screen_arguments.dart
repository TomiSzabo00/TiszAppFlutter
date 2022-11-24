import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/user_data.dart';

class ProfileScreenArguments {
  final BuildContext context;
  final UserData user;

  ProfileScreenArguments({required this.context, required this.user});
}
