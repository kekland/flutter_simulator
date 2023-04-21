import 'dart:math';

import 'package:flutter/services.dart';

extension DeviceOrientationUtils on DeviceOrientation {
  DeviceOrientation rotateCW() {
    switch (this) {
      case DeviceOrientation.portraitUp:
        return DeviceOrientation.landscapeRight;
      case DeviceOrientation.landscapeRight:
        return DeviceOrientation.portraitDown;
      case DeviceOrientation.portraitDown:
        return DeviceOrientation.landscapeLeft;
      case DeviceOrientation.landscapeLeft:
        return DeviceOrientation.portraitUp;
    }
  }

  DeviceOrientation rotateCCW() {
    switch (this) {
      case DeviceOrientation.portraitUp:
        return DeviceOrientation.landscapeLeft;
      case DeviceOrientation.landscapeRight:
        return DeviceOrientation.portraitUp;
      case DeviceOrientation.portraitDown:
        return DeviceOrientation.landscapeRight;
      case DeviceOrientation.landscapeLeft:
        return DeviceOrientation.portraitDown;
    }
  }

  bool get isLandscape =>
      this == DeviceOrientation.landscapeLeft ||
      this == DeviceOrientation.landscapeRight;

  bool get isPortrait =>
      this == DeviceOrientation.portraitUp ||
      this == DeviceOrientation.portraitDown;

  double get angleRad => index * pi / 2;

  Size transformSize(Size size) {
    switch (this) {
      case DeviceOrientation.portraitUp:
      case DeviceOrientation.portraitDown:
        return size;
      case DeviceOrientation.landscapeLeft:
      case DeviceOrientation.landscapeRight:
        return size.flipped;
    }
  }
}
