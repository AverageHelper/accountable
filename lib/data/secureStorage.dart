import 'package:accountable/data/backend/auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storage = new FlutterSecureStorage();

// ** Keys

final String _loginKeyPrefix =
    "io.github.averagehelper.accountable.securestorage.loginInfo";

final String _urlKey = _loginKeyPrefix + ".url";
final String _liveQueryKey = _loginKeyPrefix + ".liveQueryUrl";
final String _usernameKey = _loginKeyPrefix + ".username";
final String _passwordKey = _loginKeyPrefix + ".password";

// ** Access functions

/// Fetches and returns login details from secure storage.
Future<LoginInfo?> getLastLogin() async {
  final Map<String, String> allValues = await _storage.readAll();

  final String? url = allValues[_urlKey];
  final String? liveQueryUrl = allValues[_liveQueryKey];
  final String? username = allValues[_usernameKey];
  final String? password = allValues[_passwordKey];

  if (url == null ||
      liveQueryUrl == null ||
      username == null ||
      password == null) {
    return null;
  }

  return new LoginInfo(url, liveQueryUrl, username, password);
}

/// Writes login details to secure storage.
Future<void> setLastLogin(final LoginInfo info) async {
  await _storage.write(key: _urlKey, value: info.url);
  await _storage.write(key: _liveQueryKey, value: info.liveQueryUrl);
  await _storage.write(key: _usernameKey, value: info.username);
  await _storage.write(key: _passwordKey, value: info.password);
}

/// Erases login details from secure storage.
Future<void> clearLastLogin() async {
  await _storage.deleteAll();
}
