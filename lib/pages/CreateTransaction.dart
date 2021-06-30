import 'package:accountable/extensions/StandardColor.dart';
import 'package:accountable/extensions/String.dart';
import 'package:accountable/model/MoneyAccount.dart';
import 'package:accountable/model/StandardColor.dart';
import 'package:accountable/utilities/CheckboxFormField.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

/// A page that requests metadata about a new transaction.
class CreateTransactionPage extends StatefulWidget {
  CreateTransactionPage(this.account, this.onFinished, {Key? key})
      : super(key: key);

  /// The account which owns the transaction.
  final MoneyAccount account;

  /// A function that `CreateTransactionPage` calls when the user commits the form.
  final void Function({
    required MoneyAccount account,
    required String title,
    required String notes,
    required bool isReconciled,
    required DateTime transactionTime,
    required Money amountEarned,
  }) onFinished;

  @override
  _CreateTransactionPageState createState() => _CreateTransactionPageState();
}

Widget colorDropdownItem(StandardColor color) {
  String title = color.name.capitalized();

  return Row(
    children: [
      Icon(
        Icons.circle,
        color: color.primaryColor,
      ),
      Container(
        margin: const EdgeInsets.only(left: 8),
        child: Text(title),
      ),
    ],
  );
}

class _CreateTransactionPageState extends State<CreateTransactionPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _nameFieldController = TextEditingController();
  final TextEditingController _notesFieldController = TextEditingController();
  bool _isReconciled = false;
  DateTime _transactionTime = DateTime.now();
  Currency _currency = Currency.create('USD', 2);
  late Money _amountEarned = Money.from(-0, _currency);

  bool get _isIncome {
    return this._amountEarned.isPositive;
  }

  bool _canCommitTransaction = false;

  void _commitForm() {
    this.widget.onFinished(
          account: this.widget.account,
          title: this._nameFieldController.text,
          notes: this._notesFieldController.text,
          isReconciled: this._isReconciled,
          transactionTime: this._transactionTime,
          amountEarned: this._amountEarned,
        );
  }

  void _onTextFieldChanged(String _) {
    _checkCanCommitAccount();
  }

  void _onAmountFieldChanged(String amt) {
    setState(() {
      try {
        this._amountEarned = Money.parse(amt, _currency);
      } catch (e) {
        this._amountEarned = Money.from(0, _currency);
      }
    });
    _checkCanCommitAccount();
  }

  void _onChecboxChanged(bool? value) {
    setState(() {
      this._isReconciled = value ?? this._isReconciled;
    });
  }

  void _checkCanCommitAccount() {
    setState(() {
      // validate parameters
      this._canCommitTransaction = _nameFieldController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Theme.of(context).brightness,
        primarySwatch: this._isIncome ? Colors.green : Colors.red,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add a transaction"),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: this._canCommitTransaction
                  ? () {
                      Navigator.of(context).pop();
                      this._commitForm();
                    }
                  : null,
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                // Title
                TextFormField(
                  controller: this._nameFieldController,
                  onChanged: _onTextFieldChanged,
                  decoration: const InputDecoration(
                    hintText: "Title",
                    icon: const Icon(
                      Icons.text_fields,
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  autofocus: true,
                ),

                // Notes
                TextFormField(
                  controller: this._notesFieldController,
                  onChanged: _onTextFieldChanged,
                  decoration: const InputDecoration(
                    hintText: "Notes",
                    icon: const Icon(Icons.notes),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                ),

                // Amount
                TextFormField(
                  onChanged: _onAmountFieldChanged,
                  inputFormatters: [
                    CurrencyTextInputFormatter(
                      symbol: this._currency.symbol,
                      decimalDigits: this._currency.precision,
                    )
                  ],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "\$0.00",
                    icon: const Icon(Icons.attach_money),
                  ),
                ),

                // Reconciliation
                CheckboxFormField(
                  title: Text("Reconciled"),
                  value: _isReconciled,
                  onChanged: _onChecboxChanged,
                ),

                // Time
              ],
            ),
          ),
        ),
      ),
    );
  }
}
