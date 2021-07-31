import 'package:accountable/data/secureStorage.dart';
import 'package:accountable/model/Keys.dart';
import 'package:accountable/data/backend/auth.dart';
import 'package:accountable/pages/ListAccounts.dart';
import 'package:accountable/pages/LoginOrRegister.dart';
import 'package:accountable/utilities/LoadingScreen.dart';
import 'package:flutter/material.dart';

class ObtainCredentials extends StatefulWidget {
  ObtainCredentials(this.keys, {Key? key}) : super(key: key);

  final Keys keys;

  @override
  _ObtainCredentialsState createState() => _ObtainCredentialsState();
}

class _ObtainCredentialsState extends State<ObtainCredentials> {
  VoidCallback? unsubscribeLogin;
  bool? isLoggedIn;

  @override
  initState() {
    super.initState();
    this._setup();
  }

  _setup() async {
    // Try login first
    LoginInfo? lastLogin = await getLastLogin();
    if (lastLogin != null) {
      try {
        await logIn(widget.keys, lastLogin);
      } catch (e, stackTrace) {
        debugPrint("${e.runtimeType.toString()}: ${e.toString()}\n$stackTrace");
        await clearLastLogin();
      }
    }

    unsubscribeLogin = watchAuthState((isLoggedIn) {
      debugPrint("[ObtainCredentials] New login state: $isLoggedIn");
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

    return ListAccounts();
  }
}
