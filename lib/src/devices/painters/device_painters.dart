import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/devices/devices.dart';
import 'dart:ui' as ui;
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

abstract class DeviceScreenDependentPainter {
  int? width;
  ByteData? _byteData;

  Color? getScreenPixel(Offset position) {
    if (_byteData == null || width == null) return null;

    final x = position.dx.toInt();
    final y = position.dy.toInt();

    final index = (y * (width!.toInt()) + x) * 4;

    final r = _byteData!.getUint8(index);
    final g = _byteData!.getUint8(index + 1);
    final b = _byteData!.getUint8(index + 2);
    final a = _byteData!.getUint8(index + 3);

    return Color.fromARGB(a, r, g, b);
  }

  void paint(
    Canvas canvas,
    Size size,
    Size screenSize,
    DeviceRotation rotation,
    ByteData? byteData,
  ) {
    width = screenSize.width.toInt();
    _byteData = byteData;

    paintContents(canvas, size, screenSize, rotation);
  }

  void paintContents(
    Canvas canvas,
    Size size,
    Size screenSize,
    DeviceRotation rotation,
  );
}
