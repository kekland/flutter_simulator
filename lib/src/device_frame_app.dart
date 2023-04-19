import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/imports.dart';

void runFlutterSimulatorApp(Widget app) {
  DeviceFrameWidgetBinding.ensureInitialized()
    ..attachRootWidget(
      DeviceFrameApp(
        child: RepaintBoundary(
          key: DeviceFrameWidgetBinding.instance!.deviceScreenKey,
          child: app,
        ),
      ),
    )
    ..scheduleWarmUpFrame();
}

