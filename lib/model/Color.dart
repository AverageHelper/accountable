import 'package:flutter/foundation.dart';

/// A color value.
enum Color {
  red,
  orange,
  yellow,
  green,
  majenta,
  blue,
  purple,
  brown,
}

extension ColorExtension on Color {
  /// The name of the color value.
  String get name => describeEnum(this);

  /// Returns a color value that corresponds to the provided `name`, or `null` if no match was found.
  static Color? fromRaw(String name) {
    try {
      return Color.values
          .firstWhere((e) => describeEnum(e) == name || e.toString() == name);
    } catch (e) {
      return null;
    }
  }
}

/// Returns a random color value.
Color randomColor() {
  return Color.red;
}
