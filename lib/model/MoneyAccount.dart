import 'package:accountable/model/Color.dart';
import 'package:accountable/model/UUID.dart';
import 'package:flutter_data/flutter_data.dart';

class MoneyAccount with DataModel<MoneyAccount> {
  @override
  final String id;
  final Color color;
  final String title;
  final String? notes;

  MoneyAccount._({
    required this.id,
    required this.color,
    required this.title,
    this.notes,
  });

  factory MoneyAccount({
    String? id,
    Color? color,
    required String title,
    String? notes,
  }) {
    return MoneyAccount._(
      title: title,
      notes: notes?.isNotEmpty == true ? notes : null,
      id: id ?? uuid(),
      color: color ?? randomColor(),
    );
  }
}
