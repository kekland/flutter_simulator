import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/imports.dart';

void runFlutterSimulatorApp(Widget app) {
  FlutterSimulatorWidgetBinding.ensureInitialized()
    ..attachRootWidget(
      DeviceFrameApp(
        child: RepaintBoundary(
          key: FlutterSimulatorWidgetBinding
              .instance!.screenDependentPainterRepaintBoundaryKey,
          child: RepaintBoundary(
            key: FlutterSimulatorWidgetBinding.instance!.deviceScreenKey,
            child: app,
          ),
        ),
      ),
    )
    ..scheduleWarmUpFrame();
}
