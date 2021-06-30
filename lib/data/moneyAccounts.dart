import 'package:accountable/model/MoneyAccount.dart';
import 'package:flutter/material.dart';

Map<String, MoneyAccount>? loadedAccounts;

List<Function(Map<String, MoneyAccount>)> accountSubscribers = [];

/// Caches and returns all of the user's known money accounts.
/// Also starts watching the user's accounts for changes. The
/// cache will be updated accordingly.
VoidCallback watchMoneyAccountsForUser(Function(Map<String, MoneyAccount>) cb) {
  // TODO: Call onSnapshot instead; call cb with new sorted data
  if (loadedAccounts == null) {
    loadedAccounts = new Map();
  }

  accountSubscribers.add(cb);
  cb(loadedAccounts!);

  return () {
    accountSubscribers.remove(cb);
  };
}

/// Creates a new money account for the user.
Future<MoneyAccount> createMoneyAccount({
  required String title,
  required String? notes,
}) async {
  MoneyAccount newAccount = new MoneyAccount(
    title: title,
    notes: notes,
  );

  // TODO: Talk to the server instead; let the watcher handle updating the cache
  loadedAccounts!.putIfAbsent(newAccount.id, () => newAccount);
  accountSubscribers.forEach((cb) => cb(loadedAccounts!));

  return newAccount;
}
