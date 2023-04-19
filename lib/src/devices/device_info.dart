import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/imports.dart';

class DeviceInfo {
  const DeviceInfo({
    required this.name,
    required this.screenDiagonalInches,
    required this.scaleFactor,
    required this.screenSize,
    required this.viewPadding,
    required this.rotatedViewPadding,
    this.frame,
  });

  final String name;
  final double screenDiagonalInches;
  final double scaleFactor;
  final Size screenSize;
  final EdgeInsets viewPadding;
  final EdgeInsets rotatedViewPadding;
  final DeviceFrame? frame;

  Size get scaledScreenSize => screenSize * scaleFactor;
}

typedef DeviceFrameBuilder = Widget Function(
  BuildContext context,
  Widget screenChild,
  DeviceRotation rotation,
  SystemUiOverlayStyle systemUiOverlayStyle,
);

class DeviceFrame {
  DeviceFrame({
    required this.builder,
    required this.size,
  });

  final DeviceFrameBuilder builder;
  final Size size;
}
