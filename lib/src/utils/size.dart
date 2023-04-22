import 'package:flutter/widgets.dart';

extension RoundedSize on Size {
  Size get rounded => Size(width.roundToDouble(), height.roundToDouble());
}