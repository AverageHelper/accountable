import 'package:accountable/data/backend/auth.dart';
import 'package:accountable/model/MoneyAccount.dart';
import 'package:accountable/model/TransactionRecord.dart';
import 'package:accountable/data/backend/TransactionRecordObject.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:money2/money2.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

Map<MoneyAccount, Map<String, TransactionRecord>>
    loadedTransactionsForAccounts = {};

Future<Map<String, TransactionRecord>> getTransactionsForMoneyAccount(
    MoneyAccount account) async {
  final ParseResponse response =
      await TransactionRecordObject.queryAllForAccount(account).query();

  final Map<String, TransactionRecord> result = {};
  if (response.success && response.result != null) {
    response.results?.forEach((obj) {
      final ParseObject object = obj as ParseObject;
      final TransactionRecord? record =
          TransactionRecordObject.fromObjectAndAccount(object, account);
      if (record != null) {
        result.putIfAbsent(record.id, () => record);
      }
    });
  }

  loadedTransactionsForAccounts.remove(account);
  loadedTransactionsForAccounts.putIfAbsent(account, () => result);
  return result;
}

/// Caches and returns all of the user's transactions associated
/// with an account with the given ID. Also starts watching the
/// transaction list for changes. The cache will be updated accordingly.
Future<VoidCallback> watchTransactionsForAccount(
  MoneyAccount account,
  Function(Map<String, TransactionRecord>) cb,
) async {
  final LiveQueryClient client = LiveQueryClient.instance;
  final query = TransactionRecordObject.queryAllForAccount(account);
  final subscription = await client.subscribe(query);

  void processAddition(ParseObject object) {
    final TransactionRecord? record =
        TransactionRecordObject.fromObjectAndAccount(object, account);
    debugPrint(
        "Adding or updating ${object.runtimeType}: ${object.toString()}");
    if (record == null) {
      return;
    }

    loadedTransactionsForAccounts.putIfAbsent(account, () => {});
    if (loadedTransactionsForAccounts[account]!.containsKey(record.id)) {
      loadedTransactionsForAccounts[account]!.remove(record.id);
    }
    loadedTransactionsForAccounts[account]!
        .putIfAbsent(record.id, () => record);
    cb(loadedTransactionsForAccounts[account]!);
  }

  void processRemoval(ParseObject object) {
    final TransactionRecord? record =
        TransactionRecordObject.fromObjectAndAccount(object, account);
    if (record == null) {
      debugPrint("Removing ${object.runtimeType}: ${object.toString()}");
      return;
    }

    if (loadedTransactionsForAccounts[account]!.containsKey(record.id)) {
      loadedTransactionsForAccounts[account]!.remove(record.id);
    }
    cb(loadedTransactionsForAccounts[account]!);
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
  getTransactionsForMoneyAccount(account).then((accounts) {
    cb(accounts);
  });

  return () {
    client.unSubscribe(subscription);
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
  String? userId = currentUser()?.objectId;
  if (userId == null)
    throw DataException("You must be signed in to write data.");

  // FIXME: We should fetch the actual latest transaction, not rely on the cache
  final accountTransactions =
      loadedTransactionsForAccounts[account.id]?.values.toList() ?? [];
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
    account: account,
    accountBalanceAfterThis:
        (lastRecord?.accountBalanceAfterThis ?? zero) + amountEarned,
  );

  final ParseResponse response = await newRecord.serialized().save();

  if (!response.success) {
    throw response.error!;
  }

  String objectId = (response.results?.first as ParseObject).objectId!;
  newRecord = newRecord.withId(objectId);

  return newRecord;
}

Future<void> deleteTransaction(final TransactionRecord transaction) async {
  await transaction.serialized().delete();
  // loadedTransactionsForAccounts[transaction.account]?.remove(transaction.id);
}
