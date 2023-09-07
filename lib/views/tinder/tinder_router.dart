import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/user_data.dart';
import 'package:tiszapp_flutter/viewmodels/tinder_viewmodel.dart';
import 'package:tiszapp_flutter/views/tinder/tinder_registration_screen.dart';
import 'package:tiszapp_flutter/views/tinder/tinder_screen.dart';

class TinderRouter extends StatefulWidget {
  const TinderRouter({Key? key, required this.user}) : super(key: key);

  final UserData user;

  @override
  TinderRouterState createState() => TinderRouterState();
}

class TinderRouterState extends State<TinderRouter> {
  final viewModel = TinderViewModel();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: viewModel.isUserRegistered(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool isUserRegistered = snapshot.data as bool;
          if (isUserRegistered) {
            return TinderScreen(context: context);
          }
          return TinderRegistrationScreen(user: widget.user, context: context);
        }
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Betöltés...'),
              ],
            ),
          ),
        );
      },
    );
  }
}
