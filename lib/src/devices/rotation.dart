import 'dart:math';

import 'package:flutter/widgets.dart';

enum DeviceRotation {
  deg0,
  deg90,
  deg180,
  deg270;

  DeviceRotation rotateCW() {
    switch (this) {
      case DeviceRotation.deg0:
        return DeviceRotation.deg90;
      case DeviceRotation.deg90:
        return DeviceRotation.deg180;
      case DeviceRotation.deg180:
        return DeviceRotation.deg270;
      case DeviceRotation.deg270:
        return DeviceRotation.deg0;
    }
  }

  DeviceRotation rotateCCW() {
    switch (this) {
      case DeviceRotation.deg0:
        return DeviceRotation.deg270;
      case DeviceRotation.deg90:
        return DeviceRotation.deg0;
      case DeviceRotation.deg180:
        return DeviceRotation.deg90;
      case DeviceRotation.deg270:
        return DeviceRotation.deg180;
    }
  }

  bool get isLandscape =>
      this == DeviceRotation.deg90 || this == DeviceRotation.deg270;

  bool get isPortrait =>
      this == DeviceRotation.deg0 || this == DeviceRotation.deg180;

  double get angleRad => index * pi / 2;
}

Size sizeWithRotation(DeviceRotation rotation, Size size) {
  switch (rotation) {
    case DeviceRotation.deg0:
    case DeviceRotation.deg180:
      return size;
    case DeviceRotation.deg90:
    case DeviceRotation.deg270:
      return size.flipped;
  }
}

EdgeInsets viewPaddingWithRotation(
  DeviceRotation rotation,
  EdgeInsets viewPadding,
  EdgeInsets rotatedViewPadding,
) {
  switch (rotation) {
    case DeviceRotation.deg0:
      return viewPadding;
    case DeviceRotation.deg90:
      return rotatedViewPadding;
    case DeviceRotation.deg180:
      return viewPadding.flipped;
    case DeviceRotation.deg270:
      return rotatedViewPadding;
  }
}
