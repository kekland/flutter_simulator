import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/imports.dart';
import 'package:window_manager/window_manager.dart';

Future<void> runFlutterSimulatorApp(Widget app) async {
  SimulatorWidgetsBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAsFrameless();
    await windowManager.setHasShadow(false);
    await windowManager.show();
    await windowManager.focus();
  });

  SimulatorWidgetsBinding.instance
    ..attachRootWidget(FlutterSimulatorApp(appChild: app))
    ..scheduleWarmUpFrame();
}
