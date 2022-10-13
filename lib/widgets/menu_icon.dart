import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import '3d_button.dart';

class MenuIcon extends StatelessWidget {
  const MenuIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Button3D(
      width: 120,
      height: 120,
      style: StyleOf3dButton(
        topColor:
            isDarkTheme ? CustomColor.btnFaceNight : CustomColor.btnFaceDay,
        backColor:
            isDarkTheme ? CustomColor.btnSideNight : CustomColor.btnSideDay,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_month,
            size: 50,
          ),
          const SizedBox(height: 10),
          Text("Napirend",
              style: TextStyle(
                  color: isDarkTheme
                      ? CustomColor.btnTextNight
                      : CustomColor.btnTextDay,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        ],
      ),
      onPressed: () {},
    );
  }
}
