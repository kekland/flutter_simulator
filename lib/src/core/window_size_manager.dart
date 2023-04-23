import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/imports.dart';
import 'package:window_manager/window_manager.dart';

class WindowSizeManager with WindowListener {
  WindowSizeManager() {
    windowManager.addListener(this);
  }

  Size? _lastDeviceFrameSize;

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
  Future<void> setDeviceFrameSize(Size size) async {
    await windowManager.setMaximumSize(const Size(-1, -1));

    if (_lastDeviceFrameSize == size) return;

    final windowSize = await windowManager.getSize();

    final contentAspectRatio = size.aspectRatio;

    final minSize = Size(
      minWidth,
      (minWidth / contentAspectRatio) + headerHeight,
    );

    double scale;

    if (_lastDeviceFrameSize != null) {
      scale = windowSize.width / _lastDeviceFrameSize!.width;
    } else {
      scale = 1.0;
    }

    if (size.width * scale < minWidth) {
      scale = minWidth / size.width;
    }

    final newWindowSize = _inflateSizeWithHeader(size * scale);

    windowSizeNotifier.value = newWindowSize;
    if (_lastDeviceFrameSize != null) {
      _isTransitioning = true;
      await windowManager.setTitleBarHeight(0.0);
      await windowManager.setAspectRatio(1.0);
      await windowManager.setMinimumSize(_squaredSize(minSize).rounded);
      await _setWindowSize(
        _squaredSize(newWindowSize).rounded,
        reportSize: false,
      );

      await Future.delayed(const Duration(milliseconds: 300));
      _isTransitioning = false;
    }

    await windowManager.setTitleBarHeight(headerHeight);
    await windowManager.setAspectRatio(contentAspectRatio);
    await windowManager.setMinimumSize(minSize.rounded);
    _setWindowSize(newWindowSize);
    _lastDeviceFrameSize = size;
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