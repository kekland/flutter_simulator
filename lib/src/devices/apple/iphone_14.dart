import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/imports.dart';
import 'dart:ui' as ui;

const viewPadding = EdgeInsets.only(
  top: 47.0,
  bottom: 34.0,
);

const rotatedViewPadding = EdgeInsets.only(
  bottom: 21.0,
  left: 47.0,
  right: 47.0,
);

final iPhone14 = DeviceInfo(
  name: 'iPhone 14',
  platform: TargetPlatform.iOS,
  screenDiagonalInches: 6.1,
  screenSize: const Size(390, 844),
  devicePixelRatio: 3.0,
  viewPaddings: {
    DeviceOrientation.portraitUp: viewPadding,
    DeviceOrientation.landscapeLeft: rotatedViewPadding,
    DeviceOrientation.landscapeRight: rotatedViewPadding,
  },
  allowedOrientations: {
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  },
  deviceFrame: _iPhone14Frame,
);

const _iPhone14Frame = DeviceFrame(
  transformSize: _transformSize,
  transformScreenOffset: _transformScreenOffset,
  frameRadius: Radius.circular(47.33 + _totalBorderWidth),
  paintDeviceScreen: _paintDeviceScreen,
  paintPhysicalDeviceFrame: _paintPhysicalDeviceFrame,
  paintForegroundPhysicalDeviceFrame: _paintForegroundPhysicalDeviceFrame,
  paintDeviceScreenForeground: _paintDeviceScreenForeground,
  paintContentAwareDeviceScreenForeground:
      _paintContentAwareDeviceScreenForeground,
);

const _screenRadius = Radius.circular(47.33);

const _borderWidth = 15.0;
const _outerBorderWidth = 4.0;
const _totalBorderWidth = _borderWidth + _outerBorderWidth;

const _borderColor = Color(0xFF010101);
const _outerBorderColor = Color(0xFF2C2C2C);
const _outer2BorderColor = Color(0xFF7D7D7D);
const _buttonOuterColor = Color(0xFF5D5D5D);
const _buttonColor = Color(0xFF2B2B2B);

const _notchSize = Size(484 / 3, 101 / 3);

Size _transformSize(Size screenSize, SimulatorParams params) {
  return Size(screenSize.width + 38, screenSize.height + 38);
}

Offset _transformScreenOffset(
  Size size,
  Size screenSize,
  SimulatorParams params,
) {
  return const Offset(19, 19);
}

void _paintPhysicalDeviceFrame(
  PaintingContext context,
  Offset offset,
  Size size,
  Rect screenRect,
  SimulatorParams params,
) {
  final screenSize = screenRect.size;

  void _paintButton(
    Offset bOffset,
    Size buttonSize,
    bool isLeft,
  ) {
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.15);
    final outerPaint = Paint()..color = _buttonOuterColor;
    final paint = Paint()..color = _buttonColor;

    final size = buttonSize / 3;
    const radius = Radius.circular(3 / 3);

    final buttonOffset =
        Offset(isLeft ? -(buttonSize.width + 3) : 1287, bOffset.dy) / 3;

    final rect = (offset + buttonOffset) & size;
    final outerRect = rect.shift(const Offset(0, -3 / 3));
    final shadowRect = rect.expandToInclude(outerRect).inflate(3 / 3);

    RRect rrectBuilder(Rect rect) {
      if (isLeft) {
        return RRect.fromRectAndCorners(
          rect,
          topLeft: radius,
          bottomLeft: radius,
        );
      }

      return RRect.fromRectAndCorners(
        rect,
        topRight: radius,
        bottomRight: radius,
      );
    }

    context.canvas.drawRRect(rrectBuilder(shadowRect), shadowPaint);
    context.canvas.drawRRect(rrectBuilder(outerRect), outerPaint);
    context.canvas.drawRRect(rrectBuilder(rect), paint);
  }

  void _paintButtons() {
    _paintButton(const Offset(0, 426), const Size(12, 87), true);
    _paintButton(const Offset(0, 618), const Size(12, 207), true);
    _paintButton(const Offset(0, 870), const Size(12, 207), true);
    _paintButton(const Offset(0, 687), const Size(9, 342), false);
  }

  void _paintBorder(
    double width,
    Color color,
  ) {
    final paint = Paint()..color = color;

    final screenRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: screenSize.width,
      height: screenSize.height,
    );

    final radius = Radius.circular(_screenRadius.x + width);
    final borderRect = screenRect.inflate(width);

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(borderRect, radius),
      paint,
    );
  }

  context.canvas.drawRect(
    screenRect,
    Paint()..color = Colors.black,
  );

  _paintButtons();

  _paintBorder(
    _outerBorderWidth + _borderWidth + 2.0,
    Colors.black.withOpacity(0.15),
  );

  _paintBorder(
    _outerBorderWidth + _borderWidth + 1.0,
    _outer2BorderColor,
  );

  _paintBorder(
    _outerBorderWidth + _borderWidth,
    _outerBorderColor,
  );

  _paintBorder(
    _borderWidth,
    _borderColor,
  );
}

ContainerLayer? _paintDeviceScreen(
  PaintingContext context,
  Offset offset,
  Rect screenRect,
  SimulatorParams params,
  RenderObject child,
  ContainerLayer? oldLayer,
) {
  final rrect = RRect.fromRectAndRadius(
    screenRect,
    _screenRadius,
  );

  return context.pushClipRRect(
    true,
    offset,
    screenRect,
    rrect.shift(-offset),
    (context, offset) {
      context.paintChild(child, offset);
    },
    oldLayer: oldLayer as ClipRRectLayer?,
  );
}

void _paintForegroundPhysicalDeviceFrame(
  PaintingContext context,
  Offset offset,
  Size size,
  Rect screenRect,
  SimulatorParams params,
) {
  final borderPaint = Paint()..color = _borderColor;

  final sizeRect = Offset.zero & size;
  final screenRect = sizeRect.deflate(_totalBorderWidth);

  final notchPath = Path();

  notchPath.moveTo(
    size.width / 2 - _notchSize.width / 2 - (36 / 6),
    screenRect.top - 1,
  );

  notchPath.relativeArcToPoint(
    const Offset(36 / 6, 36 / 6),
    clockwise: true,
    radius: const Radius.circular(36 / 3),
  );

  notchPath.relativeLineTo(0.0, 16.0 / 3.0);

  notchPath.relativeArcToPoint(
    const Offset(67 / 3, 67 / 3),
    radius: const Radius.circular(67 / 3),
    clockwise: false,
  );

  notchPath.relativeLineTo(350 / 3, 0);

  notchPath.relativeArcToPoint(
    const Offset(67 / 3, -67 / 3),
    radius: const Radius.circular(67 / 3),
    clockwise: false,
  );

  notchPath.relativeLineTo(0.0, -16.0 / 3.0);

  notchPath.relativeArcToPoint(
    const Offset(36 / 6, -36 / 6),
    clockwise: true,
    radius: const Radius.circular(36 / 3),
  );

  notchPath.close();

  context.canvas.drawPath(notchPath, borderPaint);
}

void _paintDeviceScreenForeground(
  PaintingContext context,
  Offset offset,
  Rect screenRect,
  SimulatorParams params,
) {
  final statusBarIconColor =
      params.systemUiOverlayStyle.statusBarIconBrightness == Brightness.dark
          ? Colors.black
          : Colors.white;

  void _drawTime() {
    final timePainter = TextPainter(
      text: TextSpan(
        text: '10:28',
        style: TextStyle(
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w600,
          fontSize: 15.0,
          letterSpacing: 0.5,
          height: 1.0,
          color: statusBarIconColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    timePainter.layout();

    // canvas.drawRect(
    //   (const Offset(153, 115) / 3) & (const Size(120, 33) / 3),
    //   Paint()..color = Colors.white,
    // );

    timePainter.paint(
      context.canvas,
      offset + const Offset(96, 55) / 3,
    );
  }

  void _drawCellularStatus() {
    final squareSize = const Size.square(9) / 3;
    const radius = Radius.circular(3 / 3);

    final gap = const Offset(5, 0) / 3;
    var cOffset = offset + const Offset(907, 82) / 3;

    for (var i = 0; i < 4; i++) {
      final rect = cOffset & squareSize;
      cOffset += Offset(gap.dx + squareSize.width, 0);

      context.canvas.drawRRect(
        RRect.fromRectAndRadius(rect, radius),
        Paint()..color = statusBarIconColor.withOpacity(0.2),
      );
    }
  }

  void _drawWifiIcon() {
    const icon = CupertinoIcons.wifi;

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          package: icon.fontPackage,
          fontFamily: icon.fontFamily,
          fontSize: 17,
          height: 0.85,
          color: statusBarIconColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    iconPainter.layout();

    // canvas.drawRect(
    //   (const Offset(1032, 112) / 3) & (const Size(48, 36) / 3),
    //   Paint()..color = Colors.white,
    // );

    iconPainter.paint(context.canvas, offset + const Offset(975, 55) / 3);
  }

  void _drawBatteryIcon() {
    const icon = CupertinoIcons.battery_0;
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          package: icon.fontPackage,
          fontFamily: icon.fontFamily,
          fontSize: 25,
          height: 0.8,
          color: statusBarIconColor.withOpacity(0.4),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    iconPainter.layout();

    final innerRect =
        (offset + const Offset(1046, 60) / 3) & (const Size(56 * 0.75, 23) / 3);

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, const Radius.circular(3 / 3)),
      Paint()..color = statusBarIconColor,
    );

    iconPainter.paint(context.canvas, offset + const Offset(1040, 52) / 3);
  }

  if (params.deviceScreenOrientation.isLandscape) return;

  _drawTime();
  _drawCellularStatus();
  _drawWifiIcon();
  _drawBatteryIcon();
}

void _paintContentAwareDeviceScreenForeground(
  Canvas canvas,
  Size screenSize,
  SimulatorParams params,
  ByteData? byteData,
) {
  final landscapeBottomBarSize = const Size(651, 15) / 3;
  final bottomBarSize = const Size(417, 15) / 3;
  const radius = Radius.circular(15 / 3);

  final screenRect = Rect.fromCenter(
    center: screenSize.center(Offset.zero),
    width: screenSize.width,
    height: screenSize.height,
  );

  final offset = const Offset(0, 31.5) / 3;

  final homeIndicatorSize = params.deviceScreenOrientation.isLandscape
      ? landscapeBottomBarSize
      : bottomBarSize;

  final rect = Rect.fromCenter(
    center: screenRect.bottomCenter - offset,
    width: homeIndicatorSize.width,
    height: homeIndicatorSize.height,
  );

  const sampleCount = 16;
  final lumas = <double>[];

  for (var i = 0; i < sampleCount; i++) {
    final x = rect.left + (rect.width / sampleCount) * i;
    final y = rect.top + rect.height / 2;

    final point = Offset(x, y);

    final pixelColor = getScreenPixel(byteData, screenSize.width, point);

    if (pixelColor != null) {
      final luminance = pixelColor.computeLuminance();
      lumas.add(luminance);
    }
  }

  if (lumas.isEmpty) return;

  final avgLuma = lumas.reduce((a, b) => a + b) / lumas.length;

  late final Color baseColor;

  if (avgLuma > 0.85) {
    baseColor = Colors.black;
  } else if (avgLuma < 0.1) {
    baseColor = const Color(0xFF484848);
  } else {
    baseColor = const Color(0xFF121212);
  }

  final shader = ui.Gradient.linear(
    rect.centerLeft,
    rect.centerRight,
    lumas.map((v) {
      final lumaDeviation = (v - avgLuma);
      final deviationAbsScaled = lumaDeviation.abs() * 0.3;

      late final Color color;

      if (lumaDeviation > 0.0) {
        color = baseColor.darken(deviationAbsScaled);
      } else if (lumaDeviation < 0.0) {
        color = baseColor.lighten(deviationAbsScaled);
      } else {
        color = baseColor;
      }

      return color;
    }).toList(),
    List.generate(lumas.length, (i) => i / (lumas.length - 1)),
  );

  canvas.drawRRect(
    RRect.fromRectAndRadius(rect, radius),
    Paint()..shader = shader,
    // Paint()..color = baseColor,
  );
}
