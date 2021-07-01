import 'package:accountable/data/backend/auth.dart';
import 'package:accountable/pages/AccountsList.dart';
import 'package:accountable/pages/Login.dart';
import 'package:accountable/utilities/LoadingScreen.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  LoginOrRegister({Key? key}) : super(key: key);

  @override
  _LoginOrRegisterState createState() => _LoginOrRegisterState();
}

enum _View {
  login,
  register,
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  VoidCallback? unsubscribeLogin;
  _View view = _View.login;
  bool? isLoggedIn;

  @override
  initState() {
    super.initState();
    unsubscribeLogin = watchAuthState((isLoggedIn) {
      setState(() {
        this.isLoggedIn = isLoggedIn;
      });
    });
  }

  @override
  dispose() {
    if (unsubscribeLogin != null) {
      unsubscribeLogin!();
      unsubscribeLogin = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      return LoadingScreen("Checking login state...");
    }

    if (isLoggedIn == false) {
      switch (view) {
        case _View.login:
          return Login();

        case _View.register:
          return Text("You need to register");
      }
    }

    return AccountsList();
  }
}
