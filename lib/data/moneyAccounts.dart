import 'package:accountable/data/backend/auth.dart';
import 'package:accountable/model/MoneyAccount.dart';
import 'package:accountable/data/backend/MoneyAccountObject.dart';
import 'package:accountable/model/StandardColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

Map<String, MoneyAccount>? loadedAccounts;

final List<Function(Map<String, MoneyAccount>)> accountSubscribers = [];
final Map<String, Function(MoneyAccount?)> singleAccountSubscribers = {};

Future<Map<String, MoneyAccount>> getMoneyAccountsForUser(String uid) async {
  final ParseResponse response =
      await MoneyAccountObject.queryAllForUid(uid).query();

  final Map<String, MoneyAccount> result = {};
  if (response.success && response.result != null) {
    response.results?.forEach((obj) {
      final ParseObject object = obj as ParseObject;
      final MoneyAccount? account = MoneyAccountObject.fromObject(object);
      if (account != null) {
        result.putIfAbsent(account.id, () => account);

        if (loadedAccounts == null) {
          loadedAccounts = {};
        }
        loadedAccounts?.remove(account.id);
        loadedAccounts?.putIfAbsent(account.id, () => account);
      }
    });
  }

  return result;
}

/// Caches and returns all of the user's known money accounts.
/// Also starts watching the user's accounts for changes. The
/// cache will be updated accordingly.
VoidCallback watchMoneyAccountsForUser(Function(Map<String, MoneyAccount>) cb) {
  final String? uid = currentUser()?.objectId;
  if (uid == null) {
    cb({});
    return () {};
  }

  if (loadedAccounts == null) {
    loadedAccounts = {};
  }

  accountSubscribers.add(cb);
  cb(loadedAccounts!);

  // Start fetching out-of-band
  getMoneyAccountsForUser(uid).then((accounts) {
    accountSubscribers.forEach((cb) => cb(accounts));
  });

  return () {
    accountSubscribers.remove(cb);
  };
}

/// Caches and returns the money account with the given ID.
/// Also starts watching the account for changes. The
/// cached copy will be updated accordingly.
VoidCallback watchMoneyAccountWithId(
  String id,
  Function(MoneyAccount?) cb,
) {
  // TODO: Call onSnapshot instead; call cb with new data
  MoneyAccount? account = loadedAccounts?[id];

  singleAccountSubscribers[id] = cb;
  cb(account);

  return () {
    singleAccountSubscribers.remove(id);
  };
}

/// Creates a new money account for the user.
Future<MoneyAccount> createMoneyAccount({
  required String title,
  required String? notes,
  required StandardColor? color,
}) async {
  String? userId = currentUser()?.objectId;
  if (userId == null)
    throw DataException("You must be signed in to write data.");

  MoneyAccount newAccount = new MoneyAccount(
    title: title.trim(),
    notes: notes?.trim(),
    color: color,
  );

  final ParseResponse response = await newAccount.serialized().save();

  if (!response.success) {
    throw response.error!;
  }

  String objectId = (response.results?.first as ParseObject).objectId!;
  newAccount = newAccount.withId(objectId);

  loadedAccounts?.putIfAbsent(newAccount.id, () => newAccount);
  accountSubscribers.forEach((cb) => cb(loadedAccounts ?? {}));
  singleAccountSubscribers.forEach((id, cb) {
    if (id == newAccount.id) {
      cb(newAccount);
    }
  });

  return newAccount;
}
