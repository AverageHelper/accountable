import 'package:accountable/data/backend/auth.dart';
import 'package:accountable/model/MoneyAccount.dart';
import 'package:accountable/data/backend/MoneyAccountObject.dart';
import 'package:accountable/model/StandardColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

Map<String, MoneyAccount>? loadedAccounts;

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
Future<VoidCallback> watchMoneyAccountsForUser(
    Function(Map<String, MoneyAccount>) cb) async {
  final String? uid = currentUser()?.objectId;
  if (uid == null) {
    cb({});
    return () {};
  }

  final LiveQueryClient client = LiveQueryClient.instance;
  final query = MoneyAccountObject.queryAllForUid(uid);
  final subscription = await client.subscribe(query);

  void processAddition(ParseObject object) {
    final MoneyAccount? account = MoneyAccountObject.fromObject(object);
    debugPrint(
        "Adding or updating ${object.runtimeType}: ${object.toString()}");
    if (account == null) {
      return;
    }

    loadedAccounts?.remove(account.id);
    loadedAccounts?.putIfAbsent(account.id, () => account);
    cb(loadedAccounts!);
  }

  void processRemoval(ParseObject object) {
    final MoneyAccount? account = MoneyAccountObject.fromObject(object);
    if (account == null) {
      debugPrint(
          "[LiveQueryEvent.leave] Received ${object.runtimeType}: ${object.toString()}");
      return;
    }

    loadedAccounts?.remove(account.id);
    cb(loadedAccounts!);
  }

  subscription.on(LiveQueryEvent.enter, processAddition);
  subscription.on(LiveQueryEvent.create, processAddition);
  subscription.on(LiveQueryEvent.update, processAddition);
  subscription.on(LiveQueryEvent.leave, processRemoval);
  subscription.on(LiveQueryEvent.delete, processRemoval);
  subscription.on(LiveQueryEvent.error, (error) {
    debugPrint(error.toString());
    // TODO: Do something in the callback about errors
  });

  // Start fetching out-of-band
  getMoneyAccountsForUser(uid).then((accounts) {
    cb(accounts);
  });

  return () {
    client.unSubscribe(subscription);
  };
}

/// Caches and returns the money account with the given ID.
/// Also starts watching the account for changes. The
/// cached copy will be updated accordingly.
Future<VoidCallback> watchMoneyAccountWithId(
  String id,
  Function(MoneyAccount?) cb,
) async {
  final LiveQueryClient client = LiveQueryClient.instance;
  final query = MoneyAccountObject.queryOneWithId(id);
  final subscription = await client.subscribe(query);

  void processAddition(ParseObject object) {
    final MoneyAccount? account = MoneyAccountObject.fromObject(object);
    if (account == null) {
      debugPrint("Received ${object.runtimeType}: ${object.toString()}");
      return;
    }

    cb(account);
  }

  void processRemoval(ParseObject object) {
    final MoneyAccount? account = MoneyAccountObject.fromObject(object);
    if (account == null) {
      debugPrint(
          "[LiveQueryEvent.leave] Received ${object.runtimeType}: ${object.toString()}");
      return;
    }

    loadedAccounts?.remove(account.id);
    cb(null);
  }

  subscription.on(LiveQueryEvent.enter, processAddition);
  subscription.on(LiveQueryEvent.create, processAddition);
  subscription.on(LiveQueryEvent.update, processAddition);
  subscription.on(LiveQueryEvent.leave, processRemoval);
  subscription.on(LiveQueryEvent.delete, processRemoval);
  subscription.on(LiveQueryEvent.error, (error) {
    debugPrint(error.toString());
    // TODO: Do something in the callback about errors
  });

  return () {
    client.unSubscribe(subscription);
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

  return newAccount;
}
