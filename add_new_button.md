# Adding new buttons to the main menu in the app

Here are the step of adding a new button to the main menu.

1. In `main_menu_button_type.dart` (located in `lib -> models -> main_menu`) add a new case to the enum. Please follow the camelCase naming convention.
2. Add new Map entry to the `RawValuesExtension` in the same file. **Remember the value you give here.** Also, the raw value should follow thw snake_case naming convetion.
3. In `main_menu_button.dart`, located in the same file, add the missing switch cases to the title and icon getters. These are the values that will be shown in the app, so name them accordingly.
4. In `main_menu_viewmodel.dart` (located in `lib -> viewmodels`) locate the `_reorderButtons()` function, and in the local `order` list, instert the new `MainMenuButton` into it's new place.
    For example it the original list was this:
    ```dart
    MainMenuButton(type: MainMenuButtonType.schedule),
    MainMenuButton(type: MainMenuButtonType.scores),
    ```
    And you insert it in between them:
    ```dart
    MainMenuButton(type: MainMenuButtonType.schedule),
    MainMenuButton(type: MainMenuButtonType.yourNewButton),
    MainMenuButton(type: MainMenuButtonType.scores),
    ```
    This will mean that in the app, your button will be placed after the `Schedule` and before the `Scores` buttons.
5. In the same file locate the `viewModel.getActionFor(buttonType:context:)` function. Here add the new case to the switch. If your button navigates to a new screen, the new case should look liek this:
    ```dart
    case MainMenuButtonType.yourNewButton:
        return () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => const YourNewScreen(),
            ),
        );
    ```
    Otherwise, just return a Function that your button should excecute on tap.
6. In the same file aswell, locate the `_getButtonFromKey(key:)` function. Extend the long if-else statement with a new `else if` branch like so:
    ```dart
    else if (key == MainMenuButtonType.yourNewButton.rawValue) {
        return MainMenuButtonType.yourNewButton;
    }
    ```
7. **Don't forget this step!** Go to the firebase console and in the RealtimeDatabe insert a new value into the `_main_menu` branch. The key should be the rawValue that you specified in step two.
  The value can be `0`, `1` or `2`. `0` means that the button is currently hidden from the users, only the admins can see it. `1` means that the button is currently visible to everyone.
  `2` means that the button is not visibel to the normal users and that state cannot be changed. So mark buttons with `2` that are strictly admin-based features, like adding new scores, or voting on teams.

Thats it! Your new button should be visible in the main menu.
