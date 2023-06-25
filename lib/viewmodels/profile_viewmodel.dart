import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/helpers/profile_screen_arguments.dart';
import 'package:tiszapp_flutter/models/user_data.dart';

class ProfileViewModel {
  ProfileScreenArguments args;

  ProfileViewModel(this.args);

  String getTeamNum() {
    if (args.user.teamNum == 0) {
      return "Szervező";
    } else {
      return args.user.teamNum.toString();
    }
  }

  Future<List<String>> getTeammates() async {
    List<String> teammates = [];
    await FirebaseDatabase.instance.ref().child("users").get().then((snapshot) {
      for (var value in snapshot.children) {
        var currentUser = UserData.fromSnapshot(value);
        if (currentUser.teamNum == args.user.teamNum &&
            currentUser.uid != args.user.uid) {
          teammates.add(currentUser.name);
        }
      }
    });
    return teammates;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.of(args.context).pop();
  }
}
