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
  bool obscurePassword = true;

  AuthenticationViewModel _authenticationViewModel = AuthenticationViewModel();

  @override
  void initState() {
    super.initState();
    AuthenticationViewModel.init().then((value) {
      setState(() {
        _authenticationViewModel = value;
      });
    });
    //obscurePassword = true;
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
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                SizedBox(
                  height: 55,
                  child: TextField(
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    controller: _passwordController,
                    obscureText: obscurePassword,
                    autocorrect: false,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDarkTheme
                              ? Colors.white.withOpacity(0.7)
                              : CustomColor.btnTextDay,
                        ),
                      ),
                      labelText: 'Jelszó',
                      labelStyle: TextStyle(
                        color: isDarkTheme
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black.withOpacity(0.3),
                      ),
                      floatingLabelStyle: TextStyle(
                        color: isDarkTheme
                            ? Colors.white.withOpacity(0.7)
                            : CustomColor.btnTextDay,
                      ),
                      prefixIcon: const Icon(CupertinoIcons.lock_fill),
                      prefixIconColor: isDarkTheme
                          ? Colors.white.withOpacity(0.7)
                          : CustomColor.btnTextDay,
                      suffixIcon: IconButton(
                        icon: obscurePassword
                            ? const Icon(CupertinoIcons.eye_fill)
                            : const Icon(CupertinoIcons.eye_slash_fill),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                      fillColor: Colors.white.withOpacity(0.5),
                      filled: true,
                    ),
                  ),
                ),
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
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SizedBox(
      height: 55,
      child: TextField(
        controller: _emailController,
        autocorrect: false,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDarkTheme
                  ? Colors.white.withOpacity(0.7)
                  : CustomColor.btnTextDay,
            ),
          ),
          labelText: 'Felhasználónév',
          labelStyle: TextStyle(
            color: isDarkTheme
                ? Colors.white.withOpacity(0.7)
                : Colors.black.withOpacity(0.3),
          ),
          floatingLabelStyle: TextStyle(
            color: isDarkTheme
                ? Colors.white.withOpacity(0.7)
                : CustomColor.btnTextDay,
          ),
          prefixIcon: const Icon(CupertinoIcons.person_fill),
          prefixIconColor: isDarkTheme
              ? Colors.white.withOpacity(0.7)
              : CustomColor.btnTextDay,
          fillColor: Colors.white.withOpacity(0.5),
          filled: true,
        ),
      ),
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
