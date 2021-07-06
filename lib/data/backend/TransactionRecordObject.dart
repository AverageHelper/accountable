import 'package:accountable/data/backend/auth.dart';
import 'package:accountable/data/moneyAccounts.dart';
import 'package:accountable/model/MoneyAccount.dart';
import 'package:accountable/data/backend/MoneyAccountObject.dart';
import 'package:accountable/model/TransactionRecord.dart';
import 'package:accountable/extensions/StandardColor.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

String encodedMoney(final Money money) {
  return "${money.currency.code} ${money.toString()}";
}

extension TransactionRecordObject on TransactionRecord {
  static final String _className = "TransactionRecord";

  ParseObject serialized({bool forUpdating = false}) {
    final ParseObject object = ParseObject(_className)
      ..set("account", this.account.pointer())
      ..set("color", this.color.name)
      ..set("title", this.title)
      ..set("notes", this.notes)
      ..set("categoryId", this.categoryId)
      ..set("isReconciled", this.isReconciled)
      ..set("amountEarned", encodedMoney(this.amountEarned))
      ..set(
          "accountBalanceAfterThis", encodedMoney(this.accountBalanceAfterThis))
      ..set("createdAt", this.createdAt);
    if (forUpdating) {
      object.set("objectId", this.id);
    }
    object.setACL(ParseACL(owner: currentUser()));
    return object;
  }

  static QueryBuilder<ParseObject> queryOneWithId(final String id) {
    return QueryBuilder<ParseObject>(ParseObject(_className))
      ..whereEqualTo("objectId", id);
  }

  static QueryBuilder<ParseObject> queryAllForAccount(
      final MoneyAccount account) {
    return QueryBuilder<ParseObject>(ParseObject(_className))
      ..whereEqualTo("account", account.pointer())
      ..orderByDescending('createdAt');
  }

  static Future<TransactionRecord?> fromObject(final ParseObject object) async {
    CommonCurrencies().registerAll();
    try {
      String accountId = object.get<ParseObject>("account")!.objectId!;
      MoneyAccount? account = await getMoneyAccountWithId(accountId);

      return new TransactionRecord(
        id: object.get<String>("objectId"),
        account: account!,
        color: StandardColorExtension.fromRaw(object.get<String>("color")!),
        title: object.get<String>("title")!,
        notes: object.get<String>("notes"),
        categoryId: object.get<String>("categoryId"),
        isReconciled: object.get<bool>("isReconciled"),
        amountEarned: Currencies.parse(object.get<String>("amountEarned")!),
        accountBalanceAfterThis:
            Currencies.parse(object.get<String>("accountBalanceAfterThis")!),
        createdAt: object.get<DateTime>("createdAt"),
      );
    } catch (e, stackTrace) {
      debugPrint("${e.runtimeType.toString()}: ${e.toString()}\n$stackTrace");
      return null;
    }
  }

  static TransactionRecord? fromObjectAndAccount(
      final ParseObject object, final MoneyAccount account) {
    CommonCurrencies().registerAll();
    try {
      return new TransactionRecord(
        id: object.get<String>("objectId"),
        account: account,
        color: StandardColorExtension.fromRaw(object.get<String>("color")!),
        title: object.get<String>("title")!,
        notes: object.get<String>("notes"),
        categoryId: object.get<String>("categoryId"),
        isReconciled: object.get<bool>("isReconciled"),
        amountEarned: Currencies.parse(object.get<String>("amountEarned")!),
        accountBalanceAfterThis:
            Currencies.parse(object.get<String>("accountBalanceAfterThis")!),
        createdAt: object.get<DateTime>("createdAt"),
      );
    } catch (e, stackTrace) {
      debugPrint("${e.runtimeType.toString()}: ${e.toString()}\n$stackTrace");
      return null;
    }
  }
}
