import 'package:flutter/material.dart';

class CustomColor extends Color {
  const CustomColor(int value) : super(value);

  static const btnFaceDay = Color.fromARGB(255, 255, 243, 110);
  static const btnFaceNight = Color.fromARGB(255, 134, 160, 234);
  static const btnSideDay = Color.fromARGB(255, 255, 221, 43);
  static const btnSideNight = Color.fromARGB(255, 81, 86, 142);
  static const btnTextDay = Color.fromARGB(255, 220, 147, 70);
  static const btnTextNight = Color.fromARGB(255, 67, 73, 120);
  static const semiTransparentWhite = Color.fromARGB(75, 255, 255, 255);

  static MaterialColor white = const MaterialColor(
    0xFFFFFFFF,
    <int, Color>{
      50: const Color(0xFFFFFFFF),
      100: const Color(0xFFFFFFFF),
      200: const Color(0xFFFFFFFF),
      300: const Color(0xFFFFFFFF),
      400: const Color(0xFFFFFFFF),
      500: const Color(0xFFFFFFFF),
      600: const Color(0xFFFFFFFF),
      700: const Color(0xFFFFFFFF),
      800: const Color(0xFFFFFFFF),
      900: const Color(0xFFFFFFFF),
    },
  );
}
