import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tiszapp_flutter/models/admin_api_data.dart';
import 'package:tiszapp_flutter/models/user_data.dart';
import 'package:tiszapp_flutter/services/api_service.dart';

class AuthenticationViewModel {
  List<AdminApiData> _availableUsers = [];
  List<UserData> _userInfos = [];
  String errorMessage = "";

  AuthenticationViewModel._init() {
    ApiService.getAvailableUsers().then((value) {
      _availableUsers = value;
    });
    ApiService.getUserInfos().then((value) {
      _userInfos = value;
    });
  }

  AuthenticationViewModel();

  static Future<AuthenticationViewModel> init() async {
    return AuthenticationViewModel._init();
  }

  bool isUsernameAndIDMatching(String name, String id) {
    for (var user in _availableUsers) {
      if (user.name == name && user.id == id) {
        return true;
      }
    }
    return false;
  }

  Future<void> registerToFirebase(String username, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: "$username@tiszap.hu", password: password);
    } on FirebaseAuthException catch (e) {
      errorMessage = e.code;
    }
  }

  String getErrorMessage() {
    switch (errorMessage) {
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

  void writeUserToDatabase(String name) {
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }

    final registeredUser = findUserByName(name)!;
    FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(registeredUser.uid)
        .set(registeredUser.toJson());
  }

  UserData? findUserByName(String name) {
    for (var user in _userInfos) {
      if (user.name == name) {
        user.uid = FirebaseAuth.instance.currentUser!.uid;
        return user;
      }
    }
    return null;
  }

  Future<List<String>> getNames() async {
    return ApiService.getNames();
  }

  void validateRegistrationData(String name, String username, String id,
      String password, String passwordConfirm) {
    errorMessage = "";
    if (password != passwordConfirm) {
      errorMessage = "not-matching-passwords";
    }
    if (username.isEmpty) {
      errorMessage = "invalid-email";
    }
    if (!isUsernameAndIDMatching(name, id)) {
      errorMessage = "invalid-id";
    }
    if (password.length < 6) {
      errorMessage = "weak-password";
    }
  }

  Future<void> loginToFirebase(String username, String password) async {
    errorMessage = "";
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "${username}@tiszap.hu",
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      errorMessage = e.code;
    }
  }
}
