import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simulator/src/devices/apple/ios_keyboard_animation.dart';
import 'package:flutter_simulator/src/devices/core/device_keyboard.dart';
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
  deviceKeyboard: _keyboard,
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
const _outer2BorderColor = Color(0xFF7E7E7E);
final _outer3BorderColor = Colors.black.withOpacity(0.15);
final _buttonOuterColor = Colors.black.withOpacity(0.15);
const _buttonColor = Color(0xFF2B2B2B);

const _notchSize = Size(484 / 3, 101 / 3);

Size _transformSize(Size screenSize, SimulatorParams params) {
  return Size(screenSize.width + 45, screenSize.height + 41);
}

Offset _transformScreenOffset(
  Size size,
  Size screenSize,
  SimulatorParams params,
) {
  return const Offset(23, 19);
}

void _paintPhysicalDeviceFrame(
  PaintingContext context,
  Offset offset,
  Size size,
  Rect screenRect,
  SimulatorParams params,
) {
  void paintButton(
    Offset bOffset,
    Size buttonSize,
    bool isLeft,
  ) {
    final shadowPaint = Paint()..color = _outer3BorderColor;
    final outerPaint = Paint()..color = _buttonOuterColor;
    final paint = Paint()..color = _buttonColor;

    final size = buttonSize / 3;
    const radius = Radius.circular(3 / 3);

    final buttonOffset = Offset(isLeft ? 0.0 : 1297, bOffset.dy) / 3;

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

  void paintButtons() {
    paintButton(const Offset(0, 426), const Size(12, 87), true);
    paintButton(const Offset(0, 618), const Size(12, 207), true);
    paintButton(const Offset(0, 870), const Size(12, 207), true);
    paintButton(const Offset(0, 687), const Size(9, 342), false);
  }

  void paintBorder(
    double width,
    Color color,
  ) {
    final paint = Paint()..color = color;

    final radius = Radius.circular(_screenRadius.x + width);
    final borderRect = screenRect.inflate(width);

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(borderRect, radius),
      paint,
    );
  }

  // context.canvas.drawRect(
  //   screenRect,
  //   Paint()..color = Colors.black,
  // );

  paintButtons();

  paintBorder(
    _outerBorderWidth + _borderWidth + 2.0,
    _outer3BorderColor,
  );

  paintBorder(
    _outerBorderWidth + _borderWidth + 1.0,
    _outer2BorderColor,
  );

  paintBorder(
    _outerBorderWidth + _borderWidth,
    _outerBorderColor,
  );

  paintBorder(
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

  final notchPath = Path();

  notchPath.moveTo(
    screenRect.width / 2 -
        _notchSize.width / 2 -
        (36 / 6) +
        screenRect.topLeft.dx,
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

  void drawTime() {
    final time = DateTime.now();

    // TODO: Support i18n here
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    final timePainter = TextPainter(
      text: TextSpan(
        text: '$hour:$minute',
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

  void drawCellularStatus() {
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

  void drawWifiIcon() {
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

  void drawBatteryIcon() {
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

  drawTime();
  drawCellularStatus();
  drawWifiIcon();
  drawBatteryIcon();
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

  const sampleCount = 64;
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

const _keyboard = DeviceKeyboard(
  builder: _buildKeyboard,
  viewInsetsBuilder: _buildViewInsets,
  animationBuilder: _buildKeyboardAnimation,
);

Widget _buildViewInsets(
  BuildContext context,
  SimulatorParams params,
  SimulatedIME? ime,
  bool isVisible,
  Widget Function(BuildContext context, EdgeInsets viewInsets) builder,
) {
  return IOSKeyboardAnimatedBuilder(
    isVisible: isVisible,
    builder: (context, value) {
      return builder(
        context,
        EdgeInsets.only(bottom: _keyboardHeight * value),
      );
    },
  );
}

Widget _buildKeyboardAnimation(
  BuildContext context,
  Size screenSize,
  SimulatorParams params,
  bool isVisible,
  PreferredSizeWidget keyboardWidget,
) {
  return Positioned(
    width: keyboardWidget.preferredSize.width,
    height: keyboardWidget.preferredSize.height,
    bottom: 0.0,
    child: IOSKeyboardAnimatedBuilder(
      isVisible: isVisible,
      builder: (context, value) {
        return Transform.translate(
          offset:
              Offset(0.0, (1 - value) * keyboardWidget.preferredSize.height),
          child: RepaintBoundary(child: keyboardWidget),
        );
      },
    ),
  );
}

const _keyboardHeight = 336.0;
const _keyRadius = Radius.circular(5.0);

class _KeyboardTheme {
  const _KeyboardTheme({
    required this.keyColor,
    required this.keyForegroundColor,
    required this.specialKeyColor,
    required this.keyShadowColor,
    required this.suggestionsForegroundColor,
    required this.suggestionsDividerColor,
    required this.trailingForegroundColor,
    required this.keyboardBackgroundColor,
  });

  final Color keyColor;
  final Color keyForegroundColor;
  final Color specialKeyColor;
  final Color keyShadowColor;
  final Color suggestionsForegroundColor;
  final Color suggestionsDividerColor;
  final Color trailingForegroundColor;
  final Color keyboardBackgroundColor;

  static _KeyboardTheme of(BuildContext context) {
    return _InheritedKeyboardWidget.of(context).theme;
  }

  static const _light = _KeyboardTheme(
    keyColor: Color(0xFFFDFDFE),
    keyForegroundColor: Color(0xFF000000),
    specialKeyColor: Color(0xFFB3BAC3),
    keyShadowColor: Color(0xFF888A8D),
    suggestionsForegroundColor: Color(0xFF141515),
    suggestionsDividerColor: Color(0xFFBDBFC3),
    trailingForegroundColor: Color(0xFF51555B),
    keyboardBackgroundColor: Color(0xFFD1D4D9),
  );

  static const _dark = _KeyboardTheme(
    keyColor: Color(0xFF535353),
    keyForegroundColor: Color(0xFFFFFFFF),
    specialKeyColor: Color(0xFF2D2D2D),
    keyShadowColor: Color(0xFF535353),
    suggestionsForegroundColor: Color(0xFFE7E7E7),
    suggestionsDividerColor: Color(0xFFBDBFC3),
    trailingForegroundColor: Color(0xFFFFFFFF),
    keyboardBackgroundColor: Color(0xFF0A0A0A),
  );
}

class _InheritedKeyboardWidget extends InheritedWidget {
  const _InheritedKeyboardWidget({
    super.key,
    required this.theme,
    this.ime,
    required super.child,
  });

  final _KeyboardTheme theme;
  final SimulatedIME? ime;

  static _InheritedKeyboardWidget of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_InheritedKeyboardWidget>();
    return inherited!;
  }

  @override
  bool updateShouldNotify(_InheritedKeyboardWidget oldWidget) =>
      theme != oldWidget.theme || ime != oldWidget.ime;
}

PreferredSizeWidget _buildKeyboard(
  BuildContext context,
  SimulatorParams params,
  SimulatedIME? ime,
) {
  return PreferredSize(
    preferredSize: Size(
      params.orientedScreenSize.width,
      _keyboardHeight,
    ),
    child: _InheritedKeyboardWidget(
      theme: ime?.configuration.keyboardAppearance == Brightness.light
          ? _KeyboardTheme._light
          : _KeyboardTheme._dark,
      ime: ime,
      child: Builder(
        builder: (context) => DefaultTextStyle(
          style: TextStyle(
            fontFamily: 'SF Pro',
            color: _KeyboardTheme.of(context).suggestionsForegroundColor,
          ),
          child: Container(
            width: double.infinity,
            height: _keyboardHeight,
            color: _KeyboardTheme.of(context).keyboardBackgroundColor,
            child: Column(
              children: const [
                _IOSKeyboardSuggestionsRowWidget(),
                SizedBox(height: 2.0),
                _IOSEnglishKeyboardWidget(),
                _IOSKeyboardTrailingWidget(),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _IOSKeyboardSuggestionsRowWidget extends StatelessWidget
    with PreferredSizeWidget {
  const _IOSKeyboardSuggestionsRowWidget();

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1.0,
      height: 25.0,
      color: _KeyboardTheme.of(context).suggestionsDividerColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: preferredSize,
      child: Row(
        children: [
          const Expanded(
            child: Center(child: Text('sup')),
          ),
          _buildDivider(context),
          const Expanded(
            child: Center(child: Text('sup')),
          ),
          _buildDivider(context),
          const Expanded(
            child: Center(child: Text('sup')),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(51);
}

class _IOSKeyboardTrailingWidget extends StatelessWidget
    with PreferredSizeWidget {
  const _IOSKeyboardTrailingWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: preferredSize,
      child: Row(
        children: [
          SizedBox.square(
            dimension: preferredSize.height,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: Icon(
                CupertinoIcons.globe,
                color: _KeyboardTheme.of(context).trailingForegroundColor,
                size: 27.0,
              ),
            ),
          ),
          const Spacer(),
          SizedBox.square(
            dimension: preferredSize.height,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: Icon(
                CupertinoIcons.mic,
                color: _KeyboardTheme.of(context).trailingForegroundColor,
                size: 27.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(78);
}

class _IOSEnglishKeyboardWidget extends StatelessWidget
    with PreferredSizeWidget {
  const _IOSEnglishKeyboardWidget();

  void _onCharacterTap(String character) {
    final eventData = RawKeyEventDataIos(
      characters: character,
      charactersIgnoringModifiers: character,
      keyCode: 0,
      modifiers: 0,
    );

    SystemTextInputChannelInterceptor.instance.activeIME.handleKeyEvent(
      RawKeyDownEvent(
        data: eventData,
        character: character,
        repeat: false,
      ),
    );

    SystemTextInputChannelInterceptor.instance.activeIME.handleKeyEvent(
      RawKeyUpEvent(
        data: eventData,
        character: character,
      ),
    );
  }

  Widget _buildGap(BuildContext context) {
    return const SizedBox(width: 6.0);
  }

  Widget _buildKeyRow(
    BuildContext context, {
    required EdgeInsets padding,
    required List<String> characters,
    List<Widget> leading = const [],
    List<Widget> trailing = const [],
  }) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          ...leading,
          if (characters.isNotEmpty) const Spacer(),
          ...characters
              .map<Widget>(
                (v) => _IOSKeyboardKeyWidget.character(
                  v,
                  onTap: () => _onCharacterTap(v),
                ),
              )
              .intersperse(_buildGap(context))
              .toList(),
          if (characters.isNotEmpty) const Spacer(),
          ...trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: preferredSize,
      child: Column(
        children: [
          _buildKeyRow(
            context,
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            characters: ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
          ),
          const SizedBox(height: 11.0),
          _buildKeyRow(
            context,
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            characters: ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
          ),
          const SizedBox(height: 11.0),
          _buildKeyRow(
            context,
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            characters: ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
            leading: [
              _IOSKeyboardKeyWidget(
                size: const Size(44, 43),
                foregroundColor: _KeyboardTheme.of(context).specialKeyColor,
                onTap: () {},
                child: Icon(
                  CupertinoIcons.shift,
                  size: 20.0,
                  color: _KeyboardTheme.of(context).keyForegroundColor,
                ),
              ),
            ],
            trailing: [
              _IOSKeyboardKeyWidget(
                size: const Size(44, 43),
                foregroundColor: _KeyboardTheme.of(context).specialKeyColor,
                onTap: () {
                  SystemTextInputChannelInterceptor.instance.activeIME
                      .handleBackspacePress();
                },
                child: Icon(
                  CupertinoIcons.delete_left,
                  size: 20.0,
                  color: _KeyboardTheme.of(context).keyForegroundColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11.0),
          _buildKeyRow(
            context,
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            characters: [],
            leading: [
              _IOSKeyboardKeyWidget(
                size: const Size(42, 43),
                foregroundColor: _KeyboardTheme.of(context).specialKeyColor,
                child: Icon(
                  CupertinoIcons.textformat_123,
                  size: 20.0,
                  color: _KeyboardTheme.of(context).keyForegroundColor,
                ),
              ),
              _buildGap(context),
              _IOSKeyboardKeyWidget(
                size: const Size(42, 43),
                foregroundColor: _KeyboardTheme.of(context).specialKeyColor,
                // TODO: Insert the proper icon here
                child: Icon(
                  CupertinoIcons.smiley,
                  size: 20.0,
                  color: _KeyboardTheme.of(context).keyForegroundColor,
                ),
              ),
              _buildGap(context),
              Expanded(
                child: _IOSKeyboardKeyWidget(
                  onTap: () {
                    _onCharacterTap(' ');
                  },
                  child: const Text(
                    'space',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              _buildGap(context),
            ],
            trailing: [
              _IOSKeyboardKeyWidget(
                size: const Size(91, 43),
                foregroundColor: _KeyboardTheme.of(context).specialKeyColor,
                onTap: () {
                  SystemTextInputChannelInterceptor.instance.activeIME
                      .handleNewlinePress();
                },
                child: const Text(
                  'return',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(205);
}

const _keySize = Size.fromHeight(43);
const _characterKeySize = Size(33, 43);

class _IOSKeyboardKeyWidget extends StatelessWidget {
  const _IOSKeyboardKeyWidget({
    required this.child,
    this.onTap,
    this.foregroundColor,
    this.size = _keySize,
  });

  _IOSKeyboardKeyWidget.character(
    String character, {
    this.onTap,
    this.size = _characterKeySize,
    this.foregroundColor,
  }) : child = Transform.translate(
          offset: const Offset(0, -1),
          child: Text(character),
        );

  final Size size;
  final Widget child;
  final Color? foregroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox.fromSize(
          size: size,
          child: Container(
            height: size.height,
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(_keyRadius),
              color: _KeyboardTheme.of(context).keyShadowColor,
            ),
            child: Container(
              height: size.height - 1,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(_keyRadius),
                color: foregroundColor ?? _KeyboardTheme.of(context).keyColor,
              ),
              child: Center(
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: 24.0,
                    height: 1.0,
                    color: _KeyboardTheme.of(context).keyForegroundColor,
                    fontWeight: FontWeight.w300,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
