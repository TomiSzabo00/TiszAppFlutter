import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/viewmodels/main_menu_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/menu_button_toggle.dart';

class MenuButtonsScreen extends StatefulWidget {
  const MenuButtonsScreen({Key? key}) : super(key: key);

  @override
  MenuButtonsScreenState createState() => MenuButtonsScreenState();
}

class MenuButtonsScreenState extends State<MenuButtonsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<MainMenuViewModel>(context, listen: false)
        .subscribeToButtonEvents();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainMenuViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Főmenü gombok"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Mely gombok legyenek a főmenüben?",
              style: TextStyle(fontSize: 20),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: viewModel.buttons.length,
                itemBuilder: (context, index) {
                  return MenuButtonsToggle(
                    button: viewModel.buttonToggles[index],
                    action: (value) {
                      viewModel.toggleButtonVisibility(
                          button: viewModel.buttonToggles[index],
                          isVisible: value);
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
