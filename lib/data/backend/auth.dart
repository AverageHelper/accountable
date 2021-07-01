import 'package:flutter/material.dart';

final List<Function(bool)> authStateListeners = [];

/// Monitors the current login state and calls a callback
/// when it changes. The callback receives a `bool` that
/// indicates whether the current user is logged in.
VoidCallback watchAuthState(Function(bool) cb) {
  cb(true);
  authStateListeners.add(cb);

  return () {
    authStateListeners.remove(cb);
  };
}
