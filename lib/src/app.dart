import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/imports.dart';
import 'package:flutter_simulator/src/widgets/header/header.dart';
import 'package:window_manager/window_manager.dart';

Future<void> runFlutterSimulatorApp(Widget app) async {
  SimulatorWidgetsBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final windowOptions = WindowOptions(
    size: Size(600, 600),
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
  );

  await windowManager.waitUntilReadyToShow(
    windowOptions,
    () async {
      await windowManager.setAsFrameless();
      await windowManager.show();
    },
  );

  // if (Platform.isMacOS) {
  //   // Investigate: black background on macOS
  //   // See:
  //   // https://github.com/leanflutter/window_manager/issues/293
  //   // https://github.com/alexmercerind/flutter_acrylic
  //   WindowManipulator.setWindowBackgroundColorToClear();
  // }

  // return runApp(SizedBox());

  SimulatorWidgetsBinding.instance
    ..attachRootWidget(FlutterSimulatorApp(appChild: app))
    ..scheduleWarmUpFrame();
}
