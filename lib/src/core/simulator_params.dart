import 'dart:math';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/imports.dart';

/// Set of parameters in [SimulatorParams] that should be animated.
class _AnimatedSimulatorParams {
  _AnimatedSimulatorParams({
    required this.deviceOrientationRad,
  });

  _AnimatedSimulatorParams.fromParams(SimulatorParams params)
      : this(
          deviceOrientationRad: params._deviceOrientationRad,
        );

  final double deviceOrientationRad;

  static _AnimatedSimulatorParams lerp(
    _AnimatedSimulatorParams? a,
    _AnimatedSimulatorParams? b,
    double t,
  ) {
    if (a == null && b == null) throw Exception('a and b cannot be null');

    final fromParams = a ?? b!;
    final toParams = b ?? a!;

    return _AnimatedSimulatorParams(
      deviceOrientationRad: lerpDouble(
        fromParams.deviceOrientationRad,
        toParams.deviceOrientationRad,
        t,
      )!,
    );
  }

  SimulatorParams toParams(SimulatorParams params) {
    return params.copyWith(
      deviceOrientationRad: deviceOrientationRad,
      deviceScreenSizeOverride: params.deviceScreenSizeOverride,
      deviceOrientationRadOverride: params.deviceOrientationRadOverride,
    );
  }

  @override
  int get hashCode => deviceOrientationRad.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _AnimatedSimulatorParams &&
          deviceOrientationRad == other.deviceOrientationRad;
}

/// Set of parameters to configure the simulator.
class SimulatorParams {
  const SimulatorParams({
    required this.deviceInfo,
    required double deviceOrientationRad,
    required this.previousScreenOrientation,
    required this.simulatorBrightness,
    required this.systemUiOverlayStyle,
    required this.isKeyboardVisible,
    this.applicationSwitcherDescription,
    this.appPreferredOrientations,
    this.deviceScreenSizeOverride,
    this.deviceOrientationRadOverride,
  }) : _deviceOrientationRad = deviceOrientationRad;

  /// Current device's info
  final DeviceInfo deviceInfo;

  /// Physical device orientation in radians
  final double _deviceOrientationRad;
  double get deviceOrientationRad =>
      deviceOrientationRadOverride ?? _deviceOrientationRad;

  /// Screen orientation in the previous frame
  final DeviceOrientation previousScreenOrientation;

  /// Brightness of the simulator
  final Brightness simulatorBrightness;

  /// Intercepted [SystemUiOverlayStyle] from the app
  final SystemUiOverlayStyle systemUiOverlayStyle;

  /// Intercepted [ApplicationSwitcherDescription] from the app
  final ApplicationSwitcherDescription? applicationSwitcherDescription;

  /// Intercepted [Set<DeviceOrientation>] from the app
  final Set<DeviceOrientation>? appPreferredOrientations;

  /// Whether the keyboard is shown
  final bool isKeyboardVisible;

  final Size? deviceScreenSizeOverride;

  final double? deviceOrientationRadOverride;

  Size get deviceScreenSize =>
      deviceScreenSizeOverride ?? deviceInfo.screenSize;

  Size get phyiscalPixelsScreenSize =>
      deviceScreenSize * deviceInfo.devicePixelRatio;

  /// Returns the preferred (raw) screen orientation based on the
  /// [deviceOrientationRad]
  DeviceOrientation get rawDeviceScreenOrientation {
    var rotation = deviceOrientationRad -
        (deviceOrientationRad / (2 * pi)).floor() * (2 * pi);

    if (rotation < 0) rotation += 2 * pi;

    if (rotation < pi / 4) return DeviceOrientation.portraitUp;
    if (rotation < 3 * pi / 4) return DeviceOrientation.landscapeRight;
    if (rotation < 5 * pi / 4) return DeviceOrientation.portraitDown;
    if (rotation < 7 * pi / 4) return DeviceOrientation.landscapeLeft;

    return DeviceOrientation.portraitUp;
  }

  Set<DeviceOrientation> get _allowedOrientations => deviceInfo
      .allowedOrientations
      .intersection(appPreferredOrientations ?? deviceInfo.allowedOrientations);

  /// Returns the screen orientation based on the raw orientation from
  /// [rawDeviceScreenOrientation] and the [allowedOrientations] from
  /// [deviceInfo].
  DeviceOrientation get deviceScreenOrientation {
    if (_allowedOrientations.isEmpty) {
      throw Exception('allowedOrientations cannot be empty');
    }

    final preferredOrientation = rawDeviceScreenOrientation;

    if (_allowedOrientations.contains(preferredOrientation)) {
      return preferredOrientation;
    }

    return _allowedOrientations.contains(previousScreenOrientation)
        ? previousScreenOrientation
        : _allowedOrientations.first;
  }

  DeviceFrame get deviceFrame => deviceInfo.deviceFrame;

  Size get orientedScreenSize =>
      deviceScreenOrientation.transformSize(deviceInfo.screenSize);

  EdgeInsets get viewPadding =>
      deviceInfo.viewPaddings[deviceScreenOrientation]!;

  SimulatorParams copyWith({
    DeviceInfo? deviceInfo,
    double? deviceOrientationRad,
    Brightness? simulatorBrightness,
    SystemUiOverlayStyle? systemUiOverlayStyle,
    ApplicationSwitcherDescription? applicationSwitcherDescription,
    List<DeviceOrientation>? appPreferredOrientations,
    bool? isKeyboardVisible,
    Size? deviceScreenSizeOverride,
    double? deviceOrientationRadOverride,
  }) {
    return SimulatorParams(
      deviceInfo: deviceInfo ?? this.deviceInfo,
      deviceOrientationRad: deviceOrientationRad ?? _deviceOrientationRad,
      simulatorBrightness: simulatorBrightness ?? this.simulatorBrightness,
      systemUiOverlayStyle: systemUiOverlayStyle ?? this.systemUiOverlayStyle,
      applicationSwitcherDescription:
          applicationSwitcherDescription ?? this.applicationSwitcherDescription,
      appPreferredOrientations:
          appPreferredOrientations?.toSet() ?? this.appPreferredOrientations,
      previousScreenOrientation: deviceScreenOrientation,
      isKeyboardVisible: isKeyboardVisible ?? this.isKeyboardVisible,
      deviceOrientationRadOverride: deviceOrientationRadOverride,
      deviceScreenSizeOverride: deviceScreenSizeOverride,
    );
  }

  SimulatorParams copyWithoutOverrides() {
    return SimulatorParams(
      deviceInfo: deviceInfo,
      deviceOrientationRad: deviceOrientationRad,
      simulatorBrightness: simulatorBrightness,
      systemUiOverlayStyle: systemUiOverlayStyle,
      applicationSwitcherDescription: applicationSwitcherDescription,
      appPreferredOrientations: appPreferredOrientations,
      previousScreenOrientation: deviceScreenOrientation,
      isKeyboardVisible: isKeyboardVisible,
      deviceScreenSizeOverride: null,
      deviceOrientationRadOverride: null,
    );
  }

  @override
  int get hashCode => Object.hash(
        deviceInfo,
        deviceOrientationRad,
        previousScreenOrientation,
        simulatorBrightness,
        systemUiOverlayStyle,
        applicationSwitcherDescription?.label,
        applicationSwitcherDescription?.primaryColor,
        appPreferredOrientations,
        isKeyboardVisible,
      );

  @override
  bool operator ==(Object other) {
    return other is SimulatorParams && other.hashCode == hashCode;
  }
}

class _AnimatedSimulatorParamsTween extends Tween<_AnimatedSimulatorParams> {
  _AnimatedSimulatorParamsTween({super.begin});

  @override
  _AnimatedSimulatorParams lerp(double t) {
    return _AnimatedSimulatorParams.lerp(begin, end, t);
  }
}

class AnimatedSimulatorParams extends ImplicitlyAnimatedWidget {
  const AnimatedSimulatorParams({
    super.key,
    required super.duration,
    super.curve,
    required this.data,
    required this.builder,
  });

  final SimulatorParams data;
  final Widget Function(BuildContext context, SimulatorParams params) builder;

  @override
  ImplicitlyAnimatedWidgetState<AnimatedSimulatorParams> createState() =>
      _AnimatedIconThemeState();
}

class _AnimatedIconThemeState
    extends AnimatedWidgetBaseState<AnimatedSimulatorParams> {
  _AnimatedSimulatorParamsTween? _data;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _data = visitor(
      _data,
      _AnimatedSimulatorParams.fromParams(widget.data),
      (dynamic value) => _AnimatedSimulatorParamsTween(begin: value),
    ) as _AnimatedSimulatorParamsTween?;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _data!.evaluate(animation).toParams(widget.data),
    );
  }
}
