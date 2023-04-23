import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/imports.dart';
import 'package:window_manager/window_manager.dart';

Future<void> _awaitForWithTicker({
  required Duration duration,
  required TickerProvider tickerProvider,
}) async {
  final completer = Completer<void>();
  final ticker = tickerProvider.createTicker((elapsed) {
    if (elapsed > duration) {
      completer.complete();
    }
  });

  ticker.start();
  await completer.future;

  ticker.dispose();
}

class WindowSizeManager with WindowListener {
  WindowSizeManager() {
    windowManager.addListener(this);
  }

  Size? _lastSize;
  SimulatorParams? _lastSimulatorParams;

  static double get minWidth => 320.0;
  static double get headerHeight =>
      SimulatorHeaderWidget.preferredHeight + 16.0;

  final windowSizeNotifier = ValueNotifier(const Size(0, 0));

  Size _inflateSizeWithHeader(Size size) {
    return Size(size.width, size.height + headerHeight);
  }

  Size _squaredSize(Size size) {
    final max = size.longestSide;
    return Size(max, max);
  }

  var _isTransitioning = false;
  Future<void> resizeWithSimulatorParams(
    SimulatorParams params, {
    required TickerProvider vsync,
  }) async {
    final size = params.rawDeviceScreenOrientation.transformSize(
      params.deviceFrame.transformSize(
        params.deviceScreenSize,
        params,
      ),
    );

    final hasFixedAspectRatio = !params.deviceInfo.isResizable;

    if (_lastSimulatorParams?.rawDeviceScreenOrientation ==
            params.rawDeviceScreenOrientation &&
        _lastSize == size) return;

    await windowManager.setMaximumSize(const Size(-1, -1));

    final willAnimate = _lastSize != null &&
        _lastSimulatorParams?.deviceInfo.isResizable == false;

    final windowSize = await windowManager.getSize();

    final contentAspectRatio = size.aspectRatio;

    final minSize = Size(
      minWidth,
      (minWidth / contentAspectRatio) + headerHeight,
    );

    double scale;

    if (_lastSize != null &&
        _lastSimulatorParams!.deviceInfo.isResizable == false) {
      scale = windowSize.width / _lastSize!.width;
    } else {
      scale = 1.0;
    }

    if (size.width * scale < minWidth) {
      scale = minWidth / size.width;
    }

    final newWindowSize = _inflateSizeWithHeader(size * scale);

    windowSizeNotifier.value = newWindowSize;

    _lastSimulatorParams = params;
    _lastSize = size;
    if (!hasFixedAspectRatio) {
      await windowManager.setMinimumSize(minSize.rounded);
      await windowManager.setAspectRatio(0.0);
      windowSizeNotifier.value = windowSize;
      return;
    }

    if (willAnimate) {
      _isTransitioning = true;
      await windowManager.setTitleBarHeight(0.0);
      await windowManager.setAspectRatio(1.0);
      await windowManager.setMinimumSize(_squaredSize(minSize).rounded);
      await _setWindowSize(
        _squaredSize(newWindowSize).rounded,
        reportSize: false,
      );

      await _awaitForWithTicker(
        duration: const Duration(milliseconds: 300),
        tickerProvider: vsync,
      );

      _isTransitioning = false;
    }

    await windowManager.setTitleBarHeight(headerHeight);
    await windowManager.setAspectRatio(contentAspectRatio);
    await windowManager.setMinimumSize(minSize.rounded);
    _setWindowSize(newWindowSize);
  }

  Future<void> _setWindowSize(Size size, {bool reportSize = true}) async {
    if (reportSize) {
      windowSizeNotifier.value = size;
    }

    await windowManager.setSize(size.rounded);
  }

  @override
  Future<void> onWindowResize() async {
    if (_isTransitioning) return;
    windowSizeNotifier.value = await windowManager.getSize();
  }

  void dispose() {
    windowManager.removeListener(this);
  }
}
