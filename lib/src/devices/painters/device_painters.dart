import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/devices/devices.dart';
import 'package:matrix4_transform/matrix4_transform.dart';

abstract class DeviceFramePainter extends CustomPainter {
  DeviceFramePainter({required this.rotation});

  final DeviceRotation rotation;

  Size get screenSize;

  Matrix4 _getTransformation(Size size) {
    // I'm pretty sure there's a better way of doing this, but my linear algebra
    // skills are a bit lacking :/
    switch (rotation) {
      case DeviceRotation.deg0:
        return Matrix4.identity();
      case DeviceRotation.deg90:
        return Matrix4Transform()
            .rotate(pi / 2)
            .translate(x: size.width)
            .matrix4;
      case DeviceRotation.deg180:
        return Matrix4Transform()
            .rotate(pi, origin: size.center(Offset.zero))
            .matrix4;
      case DeviceRotation.deg270:
        return Matrix4Transform()
            .rotate(-pi / 2)
            .translate(y: size.height)
            .matrix4;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.transform(_getTransformation(size).storage);

    final portraitSize = rotation.isLandscape ? size.flipped : size;
    paintFrame(canvas, portraitSize, sizeWithRotation(rotation, screenSize));
  }

  void paintFrame(Canvas canvas, Size size, Size screenSize);

  @override
  bool shouldRepaint(DeviceFramePainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}

abstract class DeviceForegroundPainter extends CustomPainter {
  DeviceForegroundPainter({
    required this.rotation,
    required this.overlayStyle,
  });

  Size get screenSize;

  final SystemUiOverlayStyle overlayStyle;
  final DeviceRotation rotation;

  Matrix4 _getTransformation(Size size) {
    // I'm pretty sure there's a better way of doing this, but my linear algebra
    // skills are a bit lacking :/
    switch (rotation) {
      case DeviceRotation.deg0:
        return Matrix4.identity();
      case DeviceRotation.deg90:
        return Matrix4Transform()
            .rotate(pi / 2)
            .translate(x: size.width)
            .matrix4;
      case DeviceRotation.deg180:
        return Matrix4Transform()
            .rotate(pi, origin: size.center(Offset.zero))
            .matrix4;
      case DeviceRotation.deg270:
        return Matrix4Transform()
            .rotate(-pi / 2)
            .translate(y: size.height)
            .matrix4;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    paintDigital(canvas, size, sizeWithRotation(rotation, screenSize));

    canvas.transform(_getTransformation(size).storage);

    final portraitSize = rotation.isLandscape ? size.flipped : size;
    paintPhysical(canvas, portraitSize, sizeWithRotation(rotation, screenSize));
  }

  void paintPhysical(Canvas canvas, Size size, Size screenSize);
  void paintDigital(Canvas canvas, Size size, Size screenSize);

  @override
  bool shouldRepaint(DeviceForegroundPainter oldDelegate) =>
      oldDelegate.rotation != rotation ||
      oldDelegate.overlayStyle != overlayStyle;
}
