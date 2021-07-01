import 'package:accountable/model/MoneyAccount.dart';
import 'package:accountable/model/TransactionRecord.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

Map<String, Map<String, TransactionRecord>>? loadedTransactionsForAccounts;

Map<String, List<Function(Map<String, TransactionRecord>)>>
    accountTransactionSubscribers = {};

/// Caches and returns all of the user's transactions associated
/// with an account with the given ID. Also starts watching the
/// transaction list for changes. The cache will be updated accordingly.
VoidCallback watchTransactionsForAccountWithId(
  String id,
  Function(Map<String, TransactionRecord>) cb,
) {
  // TODO: Call onSnapshot instead; call cb with new data
  if (loadedTransactionsForAccounts == null) {
    loadedTransactionsForAccounts = {};
  }

  var subs = accountTransactionSubscribers[id] ?? [];
  subs.add(cb);
  accountTransactionSubscribers[id] = subs;

  cb(loadedTransactionsForAccounts![id] ?? {});

  return () {
    accountTransactionSubscribers[id]?.remove(cb);
  };
}

/// Creates a new money account for the user.
Future<TransactionRecord> createTransactionRecord({
  required MoneyAccount account,
  required String title,
  required String? notes,
  required bool isReconciled,
  required DateTime transactionTime,
  required Money amountEarned,
}) async {
  var accountTransactions =
      loadedTransactionsForAccounts?[account.id]?.values.toList() ?? [];
  accountTransactions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  TransactionRecord? lastRecord =
      accountTransactions.isNotEmpty ? accountTransactions.last : null;

  Money zero = Money.from(0, amountEarned.currency);
  debugPrint("Creating transaction...");
  TransactionRecord newRecord = new TransactionRecord(
    title: title.trim(),
    notes: notes?.trim(),
    isReconciled: isReconciled,
    createdAt: transactionTime,
    amountEarned: amountEarned,
    accountId: account.id,
    accountBalanceAfterThis:
        (lastRecord?.accountBalanceAfterThis ?? zero) + amountEarned,
  );
  var amt = amountEarned.toString();
  debugPrint("Created $amt transaction named $title");

  // TODO: Talk to the server instead; let the watchers handle updating the cache and listeners
  if (loadedTransactionsForAccounts == null) {
    loadedTransactionsForAccounts = {};
  }
  loadedTransactionsForAccounts!.putIfAbsent(account.id, () => {});
  loadedTransactionsForAccounts![account.id]!
      .putIfAbsent(newRecord.id, () => newRecord);
  accountTransactionSubscribers[account.id]
      ?.forEach((cb) => cb(loadedTransactionsForAccounts?[account.id] ?? {}));
  // singleAccountSubscribers.forEach((id, cb) {
  //   if (id == newAccount.id) {
  //     cb(newAccount);
  //   }
  // });

  return newRecord;
}
