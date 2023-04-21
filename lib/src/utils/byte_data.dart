import 'dart:typed_data';

import 'package:flutter/widgets.dart';

Color? getScreenPixel(ByteData? byteData, double? width, Offset position) {
  if (byteData == null || width == null) return null;

  final x = position.dx.toInt();
  final y = position.dy.toInt();

  final index = (y * (width.toInt()) + x) * 4;

  final r = byteData.getUint8(index);
  final g = byteData.getUint8(index + 1);
  final b = byteData.getUint8(index + 2);
  final a = byteData.getUint8(index + 3);

  return Color.fromARGB(a, r, g, b);
}
