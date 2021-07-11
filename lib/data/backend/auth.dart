import 'package:accountable/data/secureStorage.dart';
import 'package:accountable/model/Keys.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

final List<Function(bool)> authStateListeners = [];

ParseUser? loggedInUser;

ParseUser? currentUser() {
  return loggedInUser;
}

class LoginInfo {
  final String url;
  final String liveQueryUrl;
  final String username;
  final String password;

  LoginInfo(this.url, this.liveQueryUrl, this.username, this.password);
}

/// Monitors the current login state and calls a callback
/// when it changes. The callback receives a `bool` that
/// indicates whether the current user is logged in.
VoidCallback watchAuthState(Function(bool) cb) {
  cb(loggedInUser != null);
  authStateListeners.add(cb);

  return () {
    authStateListeners.remove(cb);
  };
}

Future<void> logOut() async {
  await loggedInUser?.logout();
  loggedInUser = null;
  await clearLastLogin();
  authStateListeners.forEach((cb) => cb(false));
}

Future<void> logIn(
  final Keys keys,
  final LoginInfo info,
) async {
  if (loggedInUser != null) {
    throw "Already logged in";
  }
  await Parse().initialize(
    keys.appId,
    info.url,
    liveQueryUrl: info.liveQueryUrl,
    clientKey: keys.clientKey,
    autoSendSessionId: true,
  );

  final user = ParseUser(info.username, info.password, null);
  final response = await user.login();
  await setLastLogin(info);

  if (response.success) {
    loggedInUser = user;
    authStateListeners.forEach((cb) => cb(true));
    return;
  }

  throw response.error!;
}

Future<void> registerUser(
  final Keys keys,
  final LoginInfo info,
  final String email,
) async {
  final user = ParseUser(info.username, info.password, email);
  ParseResponse response = await user.create();

  if (response.success) {
    return logIn(keys, info);
  }

  throw response.error!;
}
