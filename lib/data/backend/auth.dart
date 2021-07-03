import 'package:accountable/model/Keys.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

final List<Function(bool)> authStateListeners = [];

ParseUser? loggedInUser;

ParseUser? currentUser() {
  return loggedInUser;
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

Future<void> logIn({
  required Keys keys,
  required String url,
  required String username,
  required String password,
}) async {
  final String defaultUrl =
      "https://accountable.b4a.io"; // "https://parseapi.back4app.com";

  await Parse().initialize(
    keys.appId,
    url,
    // FIXME: This may cause issues
    liveQueryUrl: url == defaultUrl ? "wss://accountable.b4a.io" : null,
    clientKey: keys.clientKey,
    autoSendSessionId: true,
  );

  final user = ParseUser(username, password, null);
  final response = await user.login();

  if (response.success) {
    loggedInUser = user;
    authStateListeners.forEach((cb) => cb(true));
    return;
  }

  throw response.error!;
}

Future<void> registerUser({
  required Keys keys,
  required String url,
  required String email,
  required String username,
  required String password,
}) async {
  final user = ParseUser(username, password, email);
  ParseResponse response = await user.create();

  if (response.success) {
    return logIn(
      keys: keys,
      url: url,
      username: username,
      password: password,
    );
  }

  throw response.error!;
}
