import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/data/admin_api_data.dart';
import 'package:tiszapp_flutter/data/user_data.dart';
import 'package:tiszapp_flutter/services/api_service.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/autocomplete_textfield.dart';
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

  List<AdminApiData> _availableUsers = [];
  List<UserData> _userInfos = [];

  @override
  void initState() {
    super.initState();
    ApiService.getAvailableUsers().then((value) {
      setState(() {
        _availableUsers = value;
      });
    });
    ApiService.getUserInfos().then((value) {
      setState(() {
        _userInfos = value;
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
        future: ApiService.getNames(),
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
    var errorMessage = "";
    if (_passwordController.text != _passwordConfirmController.text) {
      errorMessage = "not-matching-passwords";
    }
    if (_usernameController.text.isEmpty) {
      errorMessage = "invalid-email";
    }
    if (!_isUsernameAndIDMatching()) {
      errorMessage = "invalid-id";
    }

    if (errorMessage.isNotEmpty) {
      showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: const Text("Hiba"),
                content: Text(_getErrorMessage(errorMessage)),
                actions: [
                  CupertinoDialogAction(
                    child: const Text("OK"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ));
      return;
    }

    _registerToFirebase().then((value) {
      _writeUserToDatabase();
      Navigator.of(context).pop();
    });
  }

  bool _isUsernameAndIDMatching() {
    for (var user in _availableUsers) {
      if (user.name == _nameController.text && user.id == _idController.text) {
        return true;
      }
    }
    return false;
  }

  Future<void> _registerToFirebase() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: "${_usernameController.text}@tiszap.hu",
          password: _passwordController.text);
    } on FirebaseAuthException catch (e) {
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

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case "invalid-email":
        return "A felhasználónév nem megfelelő formátumú.";
      case "email-already-in-use":
        return "A felhasználónév már foglalt.";
      case "weak-password":
        return "A jelszó túl gyenge. Legalább 6 karakter hosszúnak kell lennie.";
      case "operation-not-allowed":
        return "A regisztráció jelenleg nem engedélyezett.";
      case "not-matching-passwords":
        return "A két jelszó nem egyezik.";
      case "invalid-id":
        return "Ehhez a névhez nem ez az azonosító tartozik.";
      default:
        return "Ismeretlen hiba történt.";
    }
  }

  void _writeUserToDatabase() {
    final registeredUser = findUserByName()!;
    FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(registeredUser.uid)
        .set(registeredUser.toJson());
  }

  UserData? findUserByName() {
    for (var user in _userInfos) {
      if (user.name == _nameController.text) {
        user.uid = FirebaseAuth.instance.currentUser!.uid;
        return user;
      }
    }
    return null;
  }
}
