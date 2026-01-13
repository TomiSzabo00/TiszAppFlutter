import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/viewmodels/authentication_viewmodel.dart';
import 'package:tiszapp_flutter/views/songs_screen.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/otp_input.dart';

import '../widgets/autocomplete_textfield.dart' show AutocompleteTextField;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  String _currentOtp = "";
  bool _isLoading = false;

  late AuthenticationViewModel _authenticationViewModel;
  late Future<List<String>> _namesFuture;

  @override
  void initState() {
    super.initState();
    _authenticationViewModel = AuthenticationViewModel();
    _namesFuture = _authenticationViewModel.getNames();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: FutureBuilder(
          future: _namesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Hiba történt a nevek betöltése közben.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _namesFuture = _authenticationViewModel.getNames();
                        });
                      },
                      child: const Text('Újrapróbálás'),
                    ),
                  ],
                ),
              );
            }
            final nameOptions = snapshot.data ?? [];
            return SingleChildScrollView(
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        "Bejelentkezés",
                        style: _titleStyle(),
                      ),
                      const SizedBox(height: 40),
                      //_emailField(),
                      AutocompleteTextField(
                        placeholder: "Teljes neved",
                        controller: _nameController,
                        options: nameOptions,
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                          child: Text(
                            "Egyedi azonosítód",
                            style: _labelStyle(),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      OtpInput(
                        onCodeChanged: (code) {
                          setState(() {
                            _currentOtp = code;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      Align(
                        alignment: Alignment.centerRight,
                        child: _loginButton3d(),
                      ),
                      //_registerText(),
                      const SizedBox(height: 40),
                      Image.asset("images/logo2_outline.png",
                          width: 100, height: 100),
                      const SizedBox(height: 40),
                      _offlineSongs(),
                    ],
                  ),
                ),
              ),
            );
          }),
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

  void _login() async {
    if (_nameController.text.isEmpty || _currentOtp.length < 4) return;
    setState(() => _isLoading = true);

    try {
      // Normalize name for Firebase Auth
      await _authenticationViewModel.loginToFirebase(
          removeSpaces(_nameController.text.toLowerCase()), _currentOtp);

      if (_authenticationViewModel.errorMessage.isNotEmpty) {
        _showErrorDialog(_authenticationViewModel.getErrorMessage());
      } else {
        // Success! Navigate away
      }
    } catch (e) {
      _showErrorDialog("Váratlan hiba történt.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Hiba"),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _loginButton3d() {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Button3D(
      width: 150,
      onPressed: _login,
      child: _isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: isDarkTheme
                    ? CustomColor.btnTextNight
                    : CustomColor.btnTextDay,
                strokeWidth: 2,
              ),
            )
          : Text(
              'Bejelentkezés',
              style: TextStyle(
                color: isDarkTheme
                    ? CustomColor.btnTextNight
                    : CustomColor.btnTextDay,
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
          style: _labelStyle(),
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
        //_showRegisterScreen();
      },
    );
  }

  Widget _offlineSongs() {
    return Column(
      children: [
        Text(
          "Nincs interneted?",
          style: _titleStyle(),
        ),
        _offlineSongsButton(),
      ],
    );
  }

  Widget _offlineSongsButton() {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Button3D(
      width: 200,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SongsScreen(isOffline: true),
          ),
        );
      },
      child: Text(
        'Offline daloskönyv',
        style: TextStyle(
          color:
              isDarkTheme ? CustomColor.btnTextNight : CustomColor.btnTextDay,
          fontSize: 18,
        ),
      ),
    );
  }

  TextStyle _titleStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 32,
      shadows: [
        Shadow(
          color: Colors.black,
          offset: Offset(1, 1),
          blurRadius: 1,
        ),
      ],
    );
  }

  TextStyle _labelStyle() {
    return const TextStyle(
      fontSize: 16,
    );
  }

  TextStyle _textButtonStyle() {
    return const TextStyle(
      color: Colors.black,
      fontSize: 20,
      shadows: [
        Shadow(
          color: Colors.white,
          offset: Offset(1, 1),
          blurRadius: 1,
        ),
      ],
    );
  }

  String removeSpaces(String lowerCase) {
    return lowerCase.replaceAll(" ", "");
  }
}
