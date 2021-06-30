import 'package:accountable/model/TransactionRecord.dart';

extension TransactionRecordExtension on TransactionRecord {
  int get month {
    return this.createdAt.month;
  }

  int get year {
    return this.createdAt.year;
  }
}
