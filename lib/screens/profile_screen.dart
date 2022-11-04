import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/data/user_data.dart';
import 'package:tiszapp_flutter/helpers/profile_screen_arguments.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key, required this.args}) : super(key: key);
  final ProfileScreenArguments args;

  String _getTeamNum() {
    if (args.user.teamNum == 0) {
      return "Szervező";
    } else {
      return args.user.teamNum.toString();
    }
  }

  Future<List<String>> _getTeammates() async {
    List<String> teammates = [];
    FirebaseDatabase.instance.ref().child("users").get().then((snapshot) {
      snapshot.children.forEach((value) {
        var currentUser = UserData.fromSnapshot(value);
        if (currentUser.teamNum == args.user.teamNum &&
            currentUser.uid != args.user.uid) {
          teammates.add(currentUser.name);
        }
      });
    });
    return teammates;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.of(args.context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profilom'),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  isDarkTheme ? "images/bg2_night.png" : "images/bg2_day.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Wrap(direction: Axis.vertical, children: [
                  Text('Név: ${args.user.name}',
                      style: Theme.of(context).textTheme.headline6),
                  const SizedBox(height: 20),
                  Text('Csapat: ${_getTeamNum()}',
                      style: Theme.of(context).textTheme.headline6),
                ]),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: double.infinity,
                alignment: Alignment.topLeft,
                child: FutureBuilder(
                    future: _getTeammates(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ExpansionTile(
                            collapsedBackgroundColor:
                                isDarkTheme ? Colors.black : Colors.white,
                            backgroundColor:
                                isDarkTheme ? Colors.black : Colors.white,
                            title: Text("Regisztrált csapattagok",
                                style: Theme.of(context).textTheme.headline6),
                            children: [
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.5 *
                                      0.8,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          title: Text(
                                            snapshot.data![index],
                                            style: TextStyle(
                                                color: isDarkTheme
                                                    ? Colors.white
                                                    : Colors.black),
                                          ),
                                        );
                                      }))
                            ]);
                      } else {
                        return Text('Csapattársak: Betöltés...',
                            style: Theme.of(context).textTheme.headline6);
                      }
                    }),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Button3D(
                  width: 160,
                  onPressed: signOut,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout),
                      const SizedBox(width: 10),
                      Text(
                        'Kijelentkezés',
                        style: TextStyle(
                            color: isDarkTheme
                                ? CustomColor.btnTextNight
                                : CustomColor.btnTextDay,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ));
  }
}
