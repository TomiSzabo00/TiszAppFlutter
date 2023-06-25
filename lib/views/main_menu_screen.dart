import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/helpers/profile_screen_arguments.dart';
import 'package:tiszapp_flutter/viewmodels/main_menu_viewmodel.dart';
import 'package:tiszapp_flutter/views/profile_screen.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/menu_icon.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  MainMenuState createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> {
  @override
  void initState() {
    super.initState();
    Provider.of<MainMenuViewModel>(context, listen: false)
        .subscribeToButtonEvents();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainMenuViewModel>();
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                isDarkTheme ? "images/bg2_night.png" : "images/bg2_day.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 14,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.only(top: 60),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: List.generate(viewModel.buttons.length, (index) {
                      return MenuIcon(
                        text: viewModel.buttons[index].title,
                        icon: viewModel.buttons[index].icon,
                        onPressed: () {
                          viewModel.getActionFor(
                              buttonType: viewModel.buttons[index].type,
                              context: context)();
                        },
                      );
                    })),
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
                          "Bejelentkezve, mint ${viewModel.user.name}",
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        args: ProfileScreenArguments(
                          user: viewModel.user,
                          context: context,
                        ),
                      ),
                    ),
                  );
                },
              )),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
