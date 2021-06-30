import 'package:flutter/material.dart';

/// A dialog that requests metadata about an account.
class CreateAccountPage extends StatefulWidget {
  CreateAccountPage(this.onFinished, {Key? key}) : super(key: key);

  /// A function that `CreateAccountPage` calls when the user commits the form.
  final void Function({
    required String title,
    required String notes,
  }) onFinished;

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Add an account"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: this.canCreateAccount
                ? () {
                    Navigator.of(context).pop();
                    this.commitForm();
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
              TextFormField(
                controller: this.nameFieldController,
                decoration: const InputDecoration(hintText: "Title"),
                textCapitalization: TextCapitalization.words,
                onChanged: onTextFieldChanged,
                autofocus: true,
              ),
              TextFormField(
                controller: this.notesFieldController,
                decoration: const InputDecoration(hintText: "Notes"),
                textCapitalization: TextCapitalization.sentences,
                onChanged: onTextFieldChanged,
                maxLines: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
