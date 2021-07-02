import 'package:accountable/model/StandardColor.dart';
import 'package:accountable/model/UUID.dart';
import 'package:flutter_data/flutter_data.dart';

class MoneyAccount with DataModel<MoneyAccount> {
  @override
  final String id;
  final StandardColor color;
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
    StandardColor? color,
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

  MoneyAccount withId(String id) {
    return new MoneyAccount(
      id: id,
      color: this.color,
      title: this.title,
      notes: this.notes,
    );
  }
}
