import 'package:flutter/material.dart';

/// See https://stackoverflow.com/a/57897318
class CheckboxFormField extends FormField<bool> {
  CheckboxFormField(
      {required Widget title,
      Widget? subtitle,
      FormFieldSetter<bool>? onSaved,
      FormFieldSetter<bool>? onChanged,
      FormFieldValidator<bool>? validator,
      bool value = false})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: value,
            builder: (FormFieldState<bool> state) {
              return CheckboxListTile(
                value: state.value,
                onChanged: (value) {
                  state.didChange(value);
                  if (onChanged != null) {
                    onChanged(value);
                  }
                },
                title: title,
                subtitle: subtitle ??
                    (state.hasError
                        ? Builder(
                            builder: (BuildContext context) => Text(
                              state.errorText!,
                              style: TextStyle(
                                  color: Theme.of(context).errorColor),
                            ),
                          )
                        : null),
                controlAffinity: ListTileControlAffinity.leading,
              );
            });
}
