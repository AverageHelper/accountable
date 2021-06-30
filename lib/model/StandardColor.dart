import 'dart:math';

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

/// Returns a random color value.
StandardColor randomColor() {
  final Random random = new Random();
  return StandardColor.values[random.nextInt(StandardColor.values.length)];
}
