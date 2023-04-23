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
  const DeviceInfo({
    required this.name,
    required this.platform,
    required this.screenDiagonalInches,
    required this.devicePixelRatio,
    required this.screenSize,
    required this.viewPaddings,
    this.deviceKeyboard = DeviceKeyboard.none,
    this.deviceFrame = DeviceFrame.none,
    this.allowedOrientations = _allDeviceOrientations,
    this.isResizable = false,
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
  final bool isResizable;

  Size get phyiscalPixelsScreenSize => screenSize * devicePixelRatio;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DeviceInfo && name == other.name;

  @override
  int get hashCode => name.hashCode;

  static const DeviceInfo none = DeviceInfo(
    name: 'frameless',
    platform: TargetPlatform.windows,
    devicePixelRatio: 2.0,
    screenDiagonalInches: 0.0,
    screenSize: Size.square(300.0),
    isResizable: true,
    viewPaddings: {
      DeviceOrientation.landscapeLeft: EdgeInsets.zero,
      DeviceOrientation.landscapeRight: EdgeInsets.zero,
      DeviceOrientation.portraitUp: EdgeInsets.zero,
      DeviceOrientation.portraitDown: EdgeInsets.zero,
    },
    allowedOrientations: {DeviceOrientation.portraitUp},
  );
}
