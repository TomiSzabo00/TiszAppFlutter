import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/helpers/profile_screen_arguments.dart';
import 'package:tiszapp_flutter/viewmodels/main_menu_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/menu_icon.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key, required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final _viewModel = MainMenuViewModel(context);
    return Scaffold(
        body: FutureBuilder(
      future: Future.wait(
          [_viewModel.getButtonVisibility(), _viewModel.getUserData()]),
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
                    children: IterableZip([
                      _viewModel.getButtonTextsForUserRole(
                          snapshot.data![0] as List<bool>),
                      _viewModel.getButtonIconsForUserRole(
                          snapshot.data![0] as List<bool>),
                      _viewModel.getButtonActionsForUserRole(
                          snapshot.data![0] as List<bool>),
                    ]).map((btnData) {
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
                  child: Container(
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
                            Text(
                              "Bejelentkezve, mint ${snapshot.data![1]}",
                              style: TextStyle(
                                color: isDarkTheme
                                    ? CustomColor.btnTextNight
                                    : CustomColor.btnTextDay,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
