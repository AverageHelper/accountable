import 'package:accountable/model/StandardColor.dart';
import 'package:accountable/extensions/String.dart';
import 'package:accountable/utilities/CheckboxFormField.dart';
import 'package:flutter/material.dart';

/// A page that requests metadata about a new account.
class CreateAccountPage extends StatefulWidget {
  CreateAccountPage(this.onFinished, {Key? key}) : super(key: key);

  /// A function that `CreateAccountPage` calls when the user commits the form.
  final void Function({
    required String title,
    required String notes,
    required StandardColor color,
    required bool shouldCloseAccountsWhenFinished,
  }) onFinished;

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
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

class _CreateAccountPageState extends State<CreateAccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _nameFieldController = TextEditingController();
  final TextEditingController _notesFieldController = TextEditingController();
  StandardColor _selectedColor = randomColor();
  bool _shouldCloseAccountsWhenFinished = true;

  bool _canCommitAccount = false;

  void _commitForm() {
    this.widget.onFinished(
        title: this._nameFieldController.text,
        notes: this._notesFieldController.text,
        color: this._selectedColor,
        shouldCloseAccountsWhenFinished: this._shouldCloseAccountsWhenFinished);
  }

  void _onTextFieldChanged(String _) {
    _checkCanCommitAccount();
  }

  void _onColorChanged(StandardColor? value) {
    final StandardColor color = value ?? randomColor();
    setState(() {
      this._selectedColor = color;
    });
    _checkCanCommitAccount();
  }

  void _onChecboxChanged(bool? value) {
    setState(() {
      this._shouldCloseAccountsWhenFinished =
          value ?? this._shouldCloseAccountsWhenFinished;
    });
  }

  void _checkCanCommitAccount() {
    setState(() {
      // validate parameters
      this._canCommitAccount = _nameFieldController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Theme.of(context).brightness,
        primarySwatch: this._selectedColor.materialColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add an account"),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: this._canCommitAccount
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
                // Color
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    hintText: "Color",
                    icon: const Icon(Icons.color_lens),
                  ),
                  value: this._selectedColor,
                  onChanged: _onColorChanged,
                  items: StandardColor.values
                      .map((c) => DropdownMenuItem(
                            child: colorDropdownItem(c),
                            value: c,
                          ))
                      .toList(),
                ),

                // Title
                TextFormField(
                  controller: this._nameFieldController,
                  decoration: const InputDecoration(
                    hintText: "Title",
                    icon: const Icon(
                      Icons.text_fields,
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  onChanged: _onTextFieldChanged,
                  autofocus: true,
                ),

                // Notes
                TextFormField(
                  controller: this._notesFieldController,
                  decoration: const InputDecoration(
                    hintText: "Notes",
                    icon: const Icon(Icons.notes),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: _onTextFieldChanged,
                  maxLines: null,
                ),

                // Wanna add transactions right away?
                CheckboxFormField(
                  title: Text("Open when finished"),
                  subtitle: Text(this._shouldCloseAccountsWhenFinished
                      ? "We will open this account after it's created"
                      : "We will return to the accounts list"),
                  value: _shouldCloseAccountsWhenFinished,
                  onChanged: _onChecboxChanged,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
