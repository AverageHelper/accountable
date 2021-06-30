import 'package:accountable/model/StandardColor.dart';
import 'package:accountable/extensions/String.dart';
import 'package:flutter/material.dart';

/// A dialog that requests metadata about an account.
class CreateAccountPage extends StatefulWidget {
  CreateAccountPage(this.onFinished, {Key? key}) : super(key: key);

  /// A function that `CreateAccountPage` calls when the user commits the form.
  final void Function({
    required String title,
    required String notes,
    required StandardColor color,
  }) onFinished;

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController nameFieldController = TextEditingController();
  final TextEditingController notesFieldController = TextEditingController();
  StandardColor selectedColor = randomColor();

  bool canCreateAccount = false;

  void onTextFieldChanged(String s) {
    checkCanCreateAccount();
  }

  void onColorChanged(StandardColor? value) {
    final StandardColor color = value ?? randomColor();
    setState(() {
      this.selectedColor = color;
    });
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
          color: this.selectedColor,
        );
  }

  Widget colorDropdownItem(StandardColor color) {
    String title = color.name.capitalized();

    // return Text(title);
    return Row(
      children: [
        Icon(
          Icons.circle,
          color: color.primaryColor,
        ),
        Container(
          margin: EdgeInsets.only(left: 8),
          child: Text(title),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Theme.of(context).brightness,
        primarySwatch: this.selectedColor.materialColor,
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
                // Color
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    hintText: "Color",
                    icon: const Icon(Icons.color_lens),
                  ),
                  value: this.selectedColor,
                  onChanged: onColorChanged,
                  items: StandardColor.values
                      .map((c) => DropdownMenuItem(
                            child: colorDropdownItem(c),
                            value: c,
                          ))
                      .toList(),
                ),

                // Title
                TextFormField(
                  controller: this.nameFieldController,
                  decoration: const InputDecoration(
                    hintText: "Title",
                    icon: const Icon(
                      Icons.text_fields,
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  onChanged: onTextFieldChanged,
                  autofocus: true,
                ),

                // Notes
                TextFormField(
                  controller: this.notesFieldController,
                  decoration: const InputDecoration(
                    hintText: "Notes",
                    icon: const Icon(Icons.notes),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: onTextFieldChanged,
                  maxLines: null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
