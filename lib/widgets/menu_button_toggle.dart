import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/main_menu/main_menu_button.dart';
import 'package:tiszapp_flutter/models/main_menu/visibility_type.dart';

class MenuButtonsToggle extends StatelessWidget {
  const MenuButtonsToggle({
    Key? key,
    required this.button,
    this.action,
  }) : super(key: key);

  final MainMenuButton button;
  final Function(bool value)? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          button.title,
          style: const TextStyle(fontSize: 16),
        ),
        Switch(
          value: button.isVisible,
          activeColor: Colors.green,
          onChanged: button.visibilityType == VisibilityType.never
              ? null
              : (value) {
                  action?.call(value);
                },
        ),
      ],
    );
  }
}
