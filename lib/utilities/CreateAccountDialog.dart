import 'package:flutter/material.dart';

/// A dialog that requests metadata about an account.
class CreateAccountDialog extends StatefulWidget {
  CreateAccountDialog(this.onFinished, {Key? key}) : super(key: key);

  /// A function that `CreateAccountDialog` calls when the user commits the form.
  final void Function({
    required String title,
    required String notes,
  }) onFinished;

  @override
  _CreateAccountDialogState createState() => _CreateAccountDialogState();
}

class _CreateAccountDialogState extends State<CreateAccountDialog> {
  final TextEditingController nameFieldController = TextEditingController();
  final TextEditingController notesFieldController = TextEditingController();

  bool canCreateAccount = false;

  void onTextFieldChanged(String s) {
    checkCanCreateAccount();
  }

  void checkCanCreateAccount() {
    setState(() {
      // validate parameters
      this.canCreateAccount = nameFieldController.text.isNotEmpty;
    });
  }

  void commitForm() {
    this.widget.onFinished(
          title: this.nameFieldController.text,
          notes: this.notesFieldController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add an account"),
      content: Column(
        children: <Widget>[
          TextField(
            controller: this.nameFieldController,
            decoration: const InputDecoration(hintText: "Title"),
            textCapitalization: TextCapitalization.words,
            onChanged: onTextFieldChanged,
            autofocus: true,
          ),
          TextField(
            controller: this.notesFieldController,
            decoration: const InputDecoration(hintText: "Notes"),
            textCapitalization: TextCapitalization.sentences,
            onChanged: onTextFieldChanged,
            maxLines: null,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("CANCEL"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("ADD"),
          onPressed: this.canCreateAccount
              ? () {
                  Navigator.of(context).pop();
                  this.commitForm();
                }
              : null,
        ),
      ],
    );
  }
}
