import 'package:accountable/model/StandardColor.dart';
import 'package:accountable/model/UUID.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:money2/money2.dart';

class TransactionRecord with DataModel<TransactionRecord> {
  @override
  final String id;
  final String accountId;
  final StandardColor color;
  final String title;
  final String? notes;
  final String? categoryId;
  final bool isReconciled;
  final Money amountEarned;
  final Money accountBalanceAfterThis;
  final DateTime createdAt;

  TransactionRecord._({
    required this.id,
    required this.accountId,
    required this.color,
    required this.title,
    required this.notes,
    required this.categoryId,
    required this.isReconciled,
    required this.amountEarned,
    required this.accountBalanceAfterThis,
    required this.createdAt,
  });

  factory TransactionRecord({
    String? id,
    required String accountId,
    StandardColor? color,
    required String title,
    String? notes,
    String? categoryId,
    bool? isReconciled,
    required Money amountEarned,
    required Money accountBalanceAfterThis,
    DateTime? createdAt,
  }) {
    return TransactionRecord._(
      id: id ?? uuid(),
      accountId: accountId,
      color: color ?? randomColor(),
      title: title,
      notes: notes?.isNotEmpty == true ? notes : null,
      categoryId: categoryId,
      isReconciled: isReconciled ?? false,
      createdAt: createdAt ?? DateTime.now(),
      amountEarned: amountEarned,
      accountBalanceAfterThis: accountBalanceAfterThis,
    );
  }
}
