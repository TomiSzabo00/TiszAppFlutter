import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/input_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Regisztráció"),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(
              height: 80,
            ),
            InputField(
              controller: _nameController,
              placeholder: "Teljes neved",
            ),
            const SizedBox(
              height: 10,
            ),
            InputField(
              controller: _idController,
              placeholder: "Egyedi azonosító",
              isNumber: true,
            ),
            const SizedBox(
              height: 50,
            ),
            InputField(
              controller: _usernameController,
              placeholder: "Felhasználónév",
            ),
            const SizedBox(
              height: 10,
            ),
            InputField(
              controller: _passwordController,
              placeholder: "Jelszó",
              obscureText: true,
            ),
            const SizedBox(
              height: 10,
            ),
            InputField(
              controller: _passwordConfirmController,
              placeholder: "Jelszó megerősítése",
              obscureText: true,
            ),
            const SizedBox(
              height: 30,
            ),
            Align(alignment: Alignment.centerRight, child: _registerButton()),
          ],
        ),
      ),
    );
  }

  Widget _registerButton() {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Button3D(
      width: 150,
      onPressed: _register,
      style: StyleOf3dButton(
        topColor:
            isDarkTheme ? CustomColor.btnFaceNight : CustomColor.btnFaceDay,
        backColor:
            isDarkTheme ? CustomColor.btnSideNight : CustomColor.btnSideDay,
      ),
      child: Text('Regisztráció',
          style: TextStyle(
              color: isDarkTheme
                  ? CustomColor.btnTextNight
                  : CustomColor.btnTextDay,
              fontSize: 18)),
    );
  }

  void _register() {
    // TODO: implement
  }
}
