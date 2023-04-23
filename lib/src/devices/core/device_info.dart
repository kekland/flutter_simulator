import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/devices/core/device_keyboard.dart';
import 'package:flutter_simulator/src/imports.dart';

const _allDeviceOrientations = {
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
};

class DeviceInfo {
  DeviceInfo({
    required this.name,
    required this.platform,
    required this.screenDiagonalInches,
    required this.devicePixelRatio,
    required this.screenSize,
    required this.viewPaddings,
    this.deviceKeyboard = DeviceKeyboard.none,
    this.deviceFrame = DeviceFrame.none,
    this.allowedOrientations = _allDeviceOrientations,
  });

  /// Name must be unique
  final String name;
  final TargetPlatform platform;
  final double screenDiagonalInches;
  final double devicePixelRatio;
  final Size screenSize;
  final Map<DeviceOrientation, EdgeInsets> viewPaddings;
  final Set<DeviceOrientation> allowedOrientations;
  final DeviceFrame deviceFrame;
  final DeviceKeyboard deviceKeyboard;

  Size get phyiscalPixelsScreenSize => screenSize * devicePixelRatio;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DeviceInfo && name == other.name;

  @override
  int get hashCode => name.hashCode;
}
