import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../widgets/input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? errorMessage = "";
  bool isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case "invalid-email":
        return "A felhasználónév nem megfelelő formátumú.";
      case "user-not-found":
        return "Nincs ilyen nevű felhasználó.";
      case "wrong-password":
        return "Hibás jelszó.";
      case "user-disabled":
        return "Túl sok sikertelen bejelentkezési kísérlet miatt a felhasználó letiltva. Próbáld újra pár perc múlva.";
      default:
        return "Ismeretlen hiba történt.";
    }
  }

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "${_emailController.text}@tiszap.hu",
        password: _passwordController.text,
      );
      //Navigator.of(context).pushReplacementNamed('/main_menu');
    } on FirebaseAuthException catch (e) {
      // setState(() {
      //   errorMessage = e.message;
      // });
      showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: const Text("Hiba"),
                content: Text(_getErrorMessage(e.code)),
                actions: [
                  CupertinoDialogAction(
                    child: const Text("OK"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ));
    }
  }

  void _showRegisterScreen() {
    showCupertinoModalBottomSheet(
      expand: true,
      isDismissible: true,
      context: context,
      builder: (context) => Container(
        child: Column(
          children: [
            const Text("Regisztráció"),
            const SizedBox(height: 20),
            CupertinoTextField(
              placeholder: "Felhasználónév",
              controller: _emailController,
            ),
            const SizedBox(height: 20),
            CupertinoTextField(
              placeholder: "Jelszó",
              controller: _passwordController,
            ),
            const SizedBox(height: 20),
            CupertinoButton(
              child: const Text("Regisztráció"),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg2_night.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("images/logo2_outline.png", width: 200, height: 200),
              const SizedBox(height: 50),
              _emailField(),
              const SizedBox(height: 15),
              _passwordField(),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: _loginButton(),
              ),
              _registerText(),
            ],
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

  Widget _loginButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text('Logging in...')),
          // );
          print("logging in");
          _login();
        }
      },
      child: const Text('Login'),
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
