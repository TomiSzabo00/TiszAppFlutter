import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/helpers/profile_screen_arguments.dart';
import 'package:tiszapp_flutter/viewmodels/main_menu_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/menu_icon.dart';

class MainMenu extends StatelessWidget {
  MainMenu({super.key, required this.context}) {
    _viewModel = MainMenuViewModel(context);
  }

  final BuildContext context;
  late final MainMenuViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
        body: FutureBuilder(
      future: _viewModel.getButtons(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Hiba történt: ${snapshot.error}"),
          );
        } else if (snapshot.hasData) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(isDarkTheme
                    ? "images/bg2_night.png"
                    : "images/bg2_day.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 12,
                  child: GridView.count(
                    padding: const EdgeInsets.only(top: 60),
                    crossAxisCount: 2,
                    children: snapshot.data!.map((btnData) {
                      return MenuIcon(
                        text: btnData[0] as String,
                        icon: btnData[1] as IconData,
                        onPressed: btnData[2] as Function(),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                      child: Button3D(
                    width: MediaQuery.of(context).size.width - 40,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person),
                          const SizedBox(width: 10),
                          FittedBox(
                            fit: BoxFit.cover,
                            child: Text(
                              "Bejelentkezve, mint ${_viewModel.user.name}",
                              style: TextStyle(
                                color: isDarkTheme
                                    ? CustomColor.btnTextNight
                                    : CustomColor.btnTextDay,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/Profil',
                          arguments: ProfileScreenArguments(
                              context: context, user: _viewModel.user));
                    },
                  )),
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    ));
  }
}
