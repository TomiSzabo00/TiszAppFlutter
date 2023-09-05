import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/helpers/profile_screen_arguments.dart';
import 'package:tiszapp_flutter/services/database_service.dart';

class ProfileViewModel {
  ProfileScreenArguments args;

  ProfileViewModel(this.args);

  Future<void> signOut() async {
    await DatabaseService.database
        .child('notification_tokens/${FirebaseAuth.instance.currentUser!.uid}')
        .remove();
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.of(args.context).pop();
  }

  Future<void> deleteAccount() async {
    await DatabaseService.database
        .child('notification_tokens/${FirebaseAuth.instance.currentUser!.uid}')
        .remove();
    await FirebaseAuth.instance.currentUser!.delete();
  }
}
