import 'package:accountable/data/backend/auth.dart';
import 'package:accountable/pages/AccountsList.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
    return AccountsList();
  }
}
