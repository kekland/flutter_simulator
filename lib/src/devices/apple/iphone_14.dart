import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simulator/src/imports.dart';
import 'package:matrix4_transform/matrix4_transform.dart';

final iPhone14 = DeviceInfo(
  name: 'iPhone 14',
  platform: TargetPlatform.iOS,
  screenDiagonalInches: 6.1,
  screenSize: _screenSize,
  scaleFactor: _scaleFactor,
  viewPadding: const EdgeInsets.only(
    top: 47.0,
    bottom: 34.0,
  ),
  rotatedViewPadding: const EdgeInsets.only(
    bottom: 21.0,
    left: 47.0,
    right: 47.0,
  ),
  frame: DeviceFrame(
    size: _sizeWithBorder,
    builder: (context, child, rotation, overlayStyle) => _FrameWidget(
      overlayStyle: overlayStyle,
      rotation: rotation,
      child: child,
    ),
  ),
);

const _scaleFactor = 3.0;
const _screenSize = Size(390, 844);
const _radius = Radius.circular(47.33);
const _borderWidth = 15.0;
const _outerBorderWidth = 4.0;
const _totalBorderWidth = _borderWidth + _outerBorderWidth;
final _sizeWithBorder = Size(
  _screenSize.width + 2 * _totalBorderWidth,
  _screenSize.height + 2 * _totalBorderWidth,
);

const _borderColor = Color(0xFF010101);
const _outerBorderColor = Color(0xFF2C2C2C);
const _outer2BorderColor = Color(0xFF7D7D7D);
const _buttonOuterColor = Color(0xFF5D5D5D);
const _buttonColor = Color(0xFF2B2B2B);

const _notchSize = Size(484 / 3, 101 / 3);

class _FrameWidget extends StatelessWidget {
  const _FrameWidget({
    required this.overlayStyle,
    required this.child,
    required this.rotation,
  });

  final DeviceRotation rotation;
  final SystemUiOverlayStyle overlayStyle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FramePainter(rotation: rotation),
      foregroundPainter: _ForegroundFramePainter(
        rotation: rotation,
        overlayStyle: overlayStyle,
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: const BorderRadius.all(_radius),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ),
    );
  }
}

class _FramePainter extends DeviceFramePainter {
  _FramePainter({required super.rotation});

  @override
  Size get screenSize => _screenSize;

  @override
  void paintFrame(Canvas canvas, Size size, Size screenSize) {
    // final transform = Matrix4Transform().rotate(
    //   rotation.angleRad,
    //   origin: size.center(Offset.zero),
    // );

    // canvas.transform(transform.matrix4.storage);

    paintButtons(canvas, size);

    paintBorder(
      canvas,
      size,
      _outerBorderWidth + _borderWidth + 2.0,
      Colors.black.withOpacity(0.15),
    );

    paintBorder(
      canvas,
      size,
      _outerBorderWidth + _borderWidth + 1.0,
      _outer2BorderColor,
    );

    paintBorder(
      canvas,
      size,
      _outerBorderWidth + _borderWidth,
      _outerBorderColor,
    );

    paintBorder(canvas, size, _borderWidth, _borderColor);
  }

  void paintBorder(Canvas canvas, Size size, double width, Color color) {
    final paint = Paint()..color = color;

    final screenRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: _screenSize.width,
      height: _screenSize.height,
    );

    final radius = Radius.circular(_radius.x + width);
    final borderRect = screenRect.inflate(width);

    canvas.drawRRect(RRect.fromRectAndRadius(borderRect, radius), paint);
  }

  void paintButtons(Canvas canvas, Size size) {
    _paintButton(canvas, size, const Offset(0, 426), const Size(12, 87), true);
    _paintButton(canvas, size, const Offset(0, 618), const Size(12, 207), true);
    _paintButton(canvas, size, const Offset(0, 870), const Size(12, 207), true);

    _paintButton(canvas, size, const Offset(0, 687), const Size(9, 342), false);
  }

  void _paintButton(
    Canvas canvas,
    Size size,
    Offset offset,
    Size buttonSize,
    bool isLeft,
  ) {
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.15);
    final outerPaint = Paint()..color = _buttonOuterColor;
    final paint = Paint()..color = _buttonColor;

    final size = buttonSize / 3;
    const radius = Radius.circular(3 / 3);

    final buttonOffset =
        Offset(isLeft ? -(buttonSize.width + 3) : 1287, offset.dy) / 3;

    final rect = buttonOffset & size;
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

    canvas.drawRRect(rrectBuilder(shadowRect), shadowPaint);
    canvas.drawRRect(rrectBuilder(outerRect), outerPaint);
    canvas.drawRRect(rrectBuilder(rect), paint);
  }
}

class _ForegroundFramePainter extends DeviceForegroundPainter {
  _ForegroundFramePainter({
    required super.overlayStyle,
    required super.rotation,
  });

  @override
  Size get screenSize => _screenSize;

  @override
  void paintPhysical(Canvas canvas, Size size, Size screenSize) {
    _drawNotch(canvas, size);
  }

  @override
  void paintDigital(Canvas canvas, Size size, Size screenSize) {
    if (rotation.isPortrait) {
      _drawStatusBar(canvas, size);
    }

    _drawBottomBar(canvas, size, screenSize);
  }

  void _drawStatusBar(Canvas canvas, Size size) {
    _drawTime(canvas, size);
    _drawCellularStatus(canvas, size);
    _drawWifiIcon(canvas, size);
    _drawBatteryIcon(canvas, size);
  }

  Color get statusBarIconColor {
    if (overlayStyle.statusBarIconBrightness == Brightness.dark) {
      return Colors.black;
    }

    return Colors.white;
  }

  void _drawTime(Canvas canvas, Size size) {
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
    timePainter.paint(canvas, const Offset(153, 112) / 3);
  }

  void _drawCellularStatus(Canvas canvas, Size size) {
    final squareSize = const Size.square(9) / 3;
    const radius = Radius.circular(3 / 3);

    final gap = const Offset(5, 0) / 3;
    var offset = const Offset(964, 139) / 3;

    for (var i = 0; i < 4; i++) {
      final rect = offset & squareSize;
      offset += Offset(gap.dx + squareSize.width, 0);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, radius),
        Paint()..color = statusBarIconColor.withOpacity(0.2),
      );
    }
  }

  void _drawWifiIcon(Canvas canvas, Size size) {
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

    iconPainter.paint(canvas, const Offset(1032, 115) / 3);
  }

  void _drawBatteryIcon(Canvas canvas, Size size) {
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
        (const Offset(1103, 120) / 3) & (const Size(56 * 0.75, 23) / 3);

    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, const Radius.circular(3 / 3)),
      Paint()..color = statusBarIconColor,
    );

    iconPainter.paint(canvas, const Offset(1097, 112) / 3);
  }

  void _drawNotch(Canvas canvas, Size size) {
    final borderPaint = Paint()..color = _borderColor;

    final sizeRect = Offset.zero & size;
    final screenRect = sizeRect.deflate(_totalBorderWidth);

    final notchPath = Path();

    notchPath.moveTo(
      size.width / 2 - _notchSize.width / 2 - (36 / 6),
      screenRect.top,
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

    canvas.drawPath(notchPath, borderPaint);
  }

  void _drawBottomBar(Canvas canvas, Size size, Size screenSize) {
    final landscapeBottomBarSize = const Size(651, 15) / 3;
    final bottomBarSize = const Size(417, 15) / 3;
    const radius = Radius.circular(15 / 3);

    final screenRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: screenSize.width,
      height: screenSize.height,
    );

    final rect = Rect.fromCenter(
      center: screenRect.bottomCenter - const Offset(0, 31.5) / 3,
      width: rotation.isLandscape
          ? landscapeBottomBarSize.width
          : bottomBarSize.width,
      height: bottomBarSize.height,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, radius),
      Paint()..color = statusBarIconColor,
    );
  }
}
