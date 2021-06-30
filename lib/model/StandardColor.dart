import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A color value.
enum StandardColor {
  red,
  orange,
  yellow,
  green,
  majenta,
  blue,
  purple,
  brown,
}

extension StandardColorExtension on StandardColor {
  /// Returns a color value that corresponds to the provided `name`, or `null` if no match was found.
  static StandardColor? fromRaw(String name) {
    try {
      return StandardColor.values
          .firstWhere((e) => describeEnum(e) == name || e.toString() == name);
    } catch (e) {
      return null;
    }
  }

  /// The name of the color value.
  String get name => describeEnum(this);

  Color get primaryColor {
    switch (this) {
      case StandardColor.red:
        return Colors.red.shade500;
      case StandardColor.orange:
        return Colors.orange.shade500;
      case StandardColor.yellow:
        return Colors.yellow.shade500;
      case StandardColor.green:
        return Colors.green.shade500;
      case StandardColor.majenta:
        return Colors.purple.shade100;
      case StandardColor.blue:
        return Colors.blue.shade500;
      case StandardColor.purple:
        return Colors.purple.shade500;
      case StandardColor.brown:
        return Colors.brown.shade300;
    }
  }

  MaterialColor get materialColor {
    switch (this) {
      case StandardColor.red:
        return Colors.red;
      case StandardColor.orange:
        return Colors.orange;
      case StandardColor.yellow:
        return Colors.yellow;
      case StandardColor.green:
        return Colors.green;
      case StandardColor.majenta:
        return Colors.purple;
      case StandardColor.blue:
        return Colors.blue;
      case StandardColor.purple:
        return Colors.purple;
      case StandardColor.brown:
        return Colors.brown;
    }
  }
}

/// Returns a random color value.
StandardColor randomColor() {
  final Random random = new Random();
  return StandardColor.values[random.nextInt(StandardColor.values.length)];
}
