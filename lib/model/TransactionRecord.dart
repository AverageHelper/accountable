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
  final Money amount;
  final Money balanceRemaining;
  final DateTime createdAt;
  final int month;
  final int year;

  TransactionRecord._({
    required this.id,
    required this.accountId,
    required this.color,
    required this.title,
    required this.notes,
    required this.categoryId,
    required this.isReconciled,
    required this.amount,
    required this.balanceRemaining,
    required this.createdAt,
    required this.month,
    required this.year,
  });

  factory TransactionRecord({
    String? id,
    required String accountId,
    StandardColor? color,
    required String title,
    String? notes,
    String? categoryId,
    bool? isReconciled,
    required Money amount,
    required Money balanceRemaining,
    DateTime? createdAt,
  }) {
    DateTime date = createdAt ?? DateTime.now();

    return TransactionRecord._(
      id: id ?? uuid(),
      accountId: accountId,
      color: color ?? randomColor(),
      title: title,
      notes: notes?.isNotEmpty == true ? notes : null,
      categoryId: categoryId,
      isReconciled: isReconciled ?? false,
      createdAt: date,
      month: date.month,
      year: date.year,
      amount: amount,
      balanceRemaining: balanceRemaining,
    );
  }
}
