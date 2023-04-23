import 'package:flutter/material.dart';
import 'package:flutter_simulator/src/imports.dart';
import 'package:window_manager/window_manager.dart';

Future<void> runFlutterSimulatorApp(Widget app) async {
  await SimulatorWidgetsBinding.ensureInitialized();

  // TODO: Make this preserve the old size
  const windowOptions = WindowOptions(
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

  SimulatorWidgetsBinding.instance
    ..attachRootWidget(FlutterSimulatorApp(appChild: app))
    ..scheduleWarmUpFrame();
}
