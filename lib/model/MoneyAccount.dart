import 'package:flutter_data/flutter_data.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

class MoneyAccount with DataModel<MoneyAccount> {
  @override
  final String id;
  String title;
  String notes;
  String color;

  MoneyAccount(String? id, {this.title = "", this.notes = "", this.color = ""})
      : id = id ?? uuid.v4();
}
