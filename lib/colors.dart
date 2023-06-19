import 'package:flutter/material.dart';

class CustomColor extends Color {
  const CustomColor(int value) : super(value);

  static const btnFaceDay = Color.fromARGB(255, 255, 243, 110);
  static const btnFaceNight = Color.fromARGB(255, 134, 160, 234);
  static const btnSideDay = Color.fromARGB(255, 255, 221, 43);
  static const btnSideNight = Color.fromARGB(255, 81, 86, 142);
  static const btnTextDay = Color.fromARGB(255, 220, 147, 70);
  static const btnTextNight = Color.fromARGB(255, 67, 73, 120);
  static const semiTransparentWhite = Color.fromARGB(150, 255, 255, 255);

  static MaterialColor white = const MaterialColor(
    0xFFFFFFFF,
    <int, Color>{
      50: Color(0xFFFFFFFF),
      100: Color(0xFFFFFFFF),
      200: Color(0xFFFFFFFF),
      300: Color(0xFFFFFFFF),
      400: Color(0xFFFFFFFF),
      500: Color(0xFFFFFFFF),
      600: Color(0xFFFFFFFF),
      700: Color(0xFFFFFFFF),
      800: Color(0xFFFFFFFF),
      900: Color(0xFFFFFFFF),
    },
  );
}

extension WordleColors on CustomColor {
  static const correctColorDark = Color(0xFF538D4E);
  static const inWordColorDark = Color(0xFFB49F3A);
  static const notInWordColorDark = Color(0xFF3A3A3C);

  static const correctColorLight = Color.fromARGB(255, 125, 194, 119);
  static const inWordColorLight = Color.fromARGB(255, 241, 210, 54);
  static const notInWordColorLight = Color.fromARGB(255, 193, 193, 193);
}
