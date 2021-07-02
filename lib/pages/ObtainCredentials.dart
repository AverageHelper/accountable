import 'package:accountable/data/backend/Keys.dart';
import 'package:accountable/data/backend/auth.dart';
import 'package:accountable/pages/AccountsList.dart';
import 'package:accountable/pages/LoginOrRegister.dart';
import 'package:accountable/utilities/LoadingScreen.dart';
import 'package:flutter/material.dart';

class ObtainCredentials extends StatefulWidget {
  ObtainCredentials(this.keys, {Key? key}) : super(key: key);

  final Keys keys;

  @override
  _LoginOrRegisterState createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<ObtainCredentials> {
  VoidCallback? unsubscribeLogin;
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
      return LoginOrRegister(
        widget.keys,
        tryLogin: logIn,
        tryRegister: registerUser,
      );
    }

    return AccountsList();
  }
}
