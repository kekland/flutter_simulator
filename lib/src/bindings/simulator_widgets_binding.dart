import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/flutter_simulator.dart';

import 'package:window_manager/window_manager.dart';

/// A [WidgetsBinding] that can be used to run the Flutter Simulator.
///
/// This binding can intercept system calls through
/// [InterceptableDefaultBinaryMessengerBinding] and the rendering process
/// through [InterceptableRendererBinding].
class SimulatorWidgetsBinding extends WidgetsFlutterBinding
    with
        InterceptableDefaultBinaryMessengerBinding,
        InterceptableRendererBinding,
        ScreenInterceptor {
  static Future<SimulatorWidgetsBinding> ensureInitialized() async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = SimulatorWidgetsBinding();
    _instance!.initScreenInterceptor();

    await windowManager.ensureInitialized();

    return _instance!;
  }

  static SimulatorWidgetsBinding get instance =>
      BindingBase.checkInstance(_instance);

  static SimulatorWidgetsBinding? _instance;

  /// The widget that contains the device screen is keyed with this key.
  final deviceScreenKey = GlobalKey();

  /// Render object of the device screen.
  RenderRepaintBoundary get deviceScreenRenderObject =>
      deviceScreenKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;

  /// The widget that contains the device frame is keyed with this key.
  final deviceFrameKey = GlobalKey();
}
