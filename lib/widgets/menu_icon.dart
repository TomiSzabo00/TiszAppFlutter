import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Button3D(
          width: constraints.maxWidth - 20,
          height: constraints.maxHeight - 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                icon,
                size: constraints.maxWidth / 3,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                // child: FittedBox(
                //   fit: BoxFit.cover,
                child: Text(
                  text,
                  maxLines: 2,
                  style: TextStyle(
                    color: isDarkTheme
                        ? CustomColor.btnTextNight
                        : CustomColor.btnTextDay,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                // ),
              )
            ],
          ),
          onPressed: () {
            onPressed();
          },
        );
      },
    );
  }
}
