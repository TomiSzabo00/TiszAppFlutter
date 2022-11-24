import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/viewmodels/authentication_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/autocomplete_textfield.dart';
import 'package:tiszapp_flutter/widgets/input_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.context});
  final BuildContext context;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  AuthenticationViewModel _authenticationViewModel = AuthenticationViewModel();

  @override
  void initState() {
    super.initState();
    AuthenticationViewModel.init(widget.context).then((value) {
      setState(() {
        _authenticationViewModel = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Regisztráció"),
      ),
      body: FutureBuilder(
        future: _authenticationViewModel.getNames(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  const SizedBox(
                    height: 80,
                  ),
                  AutocompleteTextField(
                    placeholder: "Teljes neved",
                    controller: _nameController,
                    options: snapshot.data!,
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
                  Align(
                      alignment: Alignment.centerRight,
                      child: _registerButton()),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget _registerButton() {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Button3D(
      width: 150,
      onPressed: _register,
      child: Text('Regisztráció',
          style: TextStyle(
              color: isDarkTheme
                  ? CustomColor.btnTextNight
                  : CustomColor.btnTextDay,
              fontSize: 18)),
    );
  }

  void _register() {
    _authenticationViewModel.validateRegistrationData(
        _nameController.text,
        _usernameController.text,
        _idController.text,
        _passwordController.text,
        _passwordConfirmController.text);
    if (_authenticationViewModel.errorMessage.isNotEmpty) {
      showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: const Text("Hiba"),
                content: Text(_authenticationViewModel.getErrorMessage()),
                actions: [
                  CupertinoDialogAction(
                    child: const Text("OK"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ));
      return;
    }

    _authenticationViewModel
        .registerToFirebase(_usernameController.text, _passwordController.text)
        .then((value) {
      if (_authenticationViewModel.errorMessage.isNotEmpty) {
        showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
                  title: const Text("Hiba"),
                  content: Text(_authenticationViewModel.getErrorMessage()),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text("OK"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ));
        return;
      }
      _authenticationViewModel.writeUserToDatabase(_nameController.text);
      Navigator.of(context).pop();
    });
  }
}
