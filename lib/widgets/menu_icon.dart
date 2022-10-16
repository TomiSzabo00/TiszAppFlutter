import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import '3d_button.dart';

class MenuIcon extends StatelessWidget {
  const MenuIcon({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Button3D(
      width: 150,
      height: 150,
      style: StyleOf3dButton(
        topColor:
            isDarkTheme ? CustomColor.btnFaceNight : CustomColor.btnFaceDay,
        backColor:
            isDarkTheme ? CustomColor.btnSideNight : CustomColor.btnSideDay,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 50,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              text,
              style: TextStyle(
                color: isDarkTheme
                    ? CustomColor.btnTextNight
                    : CustomColor.btnTextDay,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
      onPressed: () {
        onPressed();
      },
    );
  }
}
