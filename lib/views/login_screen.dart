import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/views/register_screen.dart';
import 'package:tiszapp_flutter/viewmodels/authentication_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import '../widgets/input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.context});
  final BuildContext context;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AuthenticationViewModel _authenticationViewModel = AuthenticationViewModel();

  @override
  void initState() {
    super.initState();
    AuthenticationViewModel.init().then((value) {
      setState(() {
        _authenticationViewModel = value;
      });
    });
  }

  void _showRegisterScreen() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) {
          return RegisterScreen(context: context);
        },
        fullscreenDialog: true));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: isDarkTheme
                  ? const AssetImage("images/bg2_night.png")
                  : const AssetImage("images/bg2_day.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("images/logo2_outline.png",
                    width: 200, height: 200),
                const SizedBox(height: 50),
                _emailField(),
                const SizedBox(height: 15),
                _passwordField(),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerRight,
                  child: _loginButton3d(),
                ),
                _registerText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailField() {
    return InputField(
      controller: _emailController,
      placeholder: "Felhasználónév",
      icon: const Icon(CupertinoIcons.person_fill),
    );
  }

  Widget _passwordField() {
    return InputField(
      controller: _passwordController,
      placeholder: "Jelszó",
      icon: const Icon(CupertinoIcons.lock_fill),
      obscureText: true,
    );
  }

  void _login() {
    _authenticationViewModel
        .loginToFirebase(_emailController.text, _passwordController.text)
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
      }
    });
  }

  Widget _loginButton3d() {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Button3D(
      width: 150,
      onPressed: _login,
      child: Text(
        'Bejelentkezés',
        style: TextStyle(
          color:
              isDarkTheme ? CustomColor.btnTextNight : CustomColor.btnTextDay,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _registerText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Nincs még fiókod?",
          style: _textStyle(),
        ),
        _registerButton(),
      ],
    );
  }

  Widget _registerButton() {
    return TextButton(
      child: Text(
        "Regisztrálj!",
        style: _textButtonStyle(),
      ),
      onPressed: () {
        _showRegisterScreen();
      },
    );
  }

  TextStyle _textStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 20,
    );
  }

  TextStyle _textButtonStyle() {
    return const TextStyle(
      color: Colors.black,
      fontSize: 20,
    );
  }
}
