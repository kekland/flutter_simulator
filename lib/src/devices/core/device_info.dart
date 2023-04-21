import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
    this.deviceFrame = DeviceFrame.none,
    this.allowedOrientations = _allDeviceOrientations,
  });

  final String name;
  final TargetPlatform platform;
  final double screenDiagonalInches;
  final double devicePixelRatio;
  final Size screenSize;
  final Map<DeviceOrientation, EdgeInsets> viewPaddings;
  final Set<DeviceOrientation> allowedOrientations;
  final DeviceFrame deviceFrame;

  Size get phyiscalPixelsScreenSize => screenSize * devicePixelRatio;
}
