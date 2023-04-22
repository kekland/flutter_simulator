import 'dart:math';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/imports.dart';

/// Set of parameters to configure the simulator.
class SimulatorParams {
  const SimulatorParams({
    required this.deviceInfo,
    required this.deviceOrientationRad,
    required this.previousScreenOrientation,
    required this.simulatorBrightness,
    required this.systemUiOverlayStyle,
    this.applicationSwitcherDescription,
    this.appPreferredOrientations,
  });

  /// Current device's info
  final DeviceInfo deviceInfo;

  /// Physical device orientation in radians
  final double deviceOrientationRad;

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

  Size get screenSize =>
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
  }) {
    return SimulatorParams(
      deviceInfo: deviceInfo ?? this.deviceInfo,
      deviceOrientationRad: deviceOrientationRad ?? this.deviceOrientationRad,
      simulatorBrightness: simulatorBrightness ?? this.simulatorBrightness,
      systemUiOverlayStyle: systemUiOverlayStyle ?? this.systemUiOverlayStyle,
      applicationSwitcherDescription:
          applicationSwitcherDescription ?? this.applicationSwitcherDescription,
      appPreferredOrientations:
          appPreferredOrientations?.toSet() ?? this.appPreferredOrientations,
      previousScreenOrientation: deviceScreenOrientation,
    );
  }

  static SimulatorParams lerp(
    SimulatorParams? a,
    SimulatorParams? b,
    double t,
  ) {
    if (a == null && b == null) throw Exception('a and b cannot be null');

    final fromParams = a ?? b!;
    final toParams = b ?? a!;

    return SimulatorParams(
      deviceInfo: t == 0.0 ? fromParams.deviceInfo : toParams.deviceInfo,
      deviceOrientationRad: lerpDouble(
        fromParams.deviceOrientationRad,
        toParams.deviceOrientationRad,
        t,
      )!,
      simulatorBrightness:
          t == 0.0 ? a!.simulatorBrightness : b!.simulatorBrightness,
      systemUiOverlayStyle:
          t == 0.0 ? a!.systemUiOverlayStyle : b!.systemUiOverlayStyle,
      previousScreenOrientation: t == 0.0
          ? a!.previousScreenOrientation
          : b!.previousScreenOrientation,
      appPreferredOrientations:
          t == 0.0 ? a!.appPreferredOrientations : b!.appPreferredOrientations,
      applicationSwitcherDescription: t == 0.0
          ? a!.applicationSwitcherDescription
          : b!.applicationSwitcherDescription,
    );
  }
}

class SimulatorParamsTween extends Tween<SimulatorParams> {
  SimulatorParamsTween({super.begin, super.end});

  @override
  SimulatorParams lerp(double t) {
    return SimulatorParams.lerp(begin, end, t);
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
    extends ImplicitlyAnimatedWidgetState<AnimatedSimulatorParams> {
  SimulatorParamsTween? _data;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _data = visitor(
      _data,
      widget.data,
      (dynamic value) => SimulatorParamsTween(begin: value as SimulatorParams),
    ) as SimulatorParamsTween?;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => widget.builder(
        context,
        _data!.evaluate(animation),
      ),
    );
  }
}
