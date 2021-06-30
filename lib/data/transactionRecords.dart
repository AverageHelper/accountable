import 'package:accountable/model/TransactionRecord.dart';
import 'package:flutter/material.dart';

Map<String, Map<String, TransactionRecord>>? loadedTransactionsForAccounts;

List<Function(Map<String, TransactionRecord>)> accountTransactionSubscribers =
    [];

VoidCallback watchTransactionsForAccountWithId(
  String id,
  Function(Map<String, TransactionRecord>) cb,
) {
  // TODO: Call onSnapshot instead; call cb with new data
  if (loadedTransactionsForAccounts == null) {
    loadedTransactionsForAccounts = {};
  }

  accountTransactionSubscribers.add(cb);
  cb(loadedTransactionsForAccounts![id] ?? {});

  return () {
    accountTransactionSubscribers.remove(cb);
  };
}
