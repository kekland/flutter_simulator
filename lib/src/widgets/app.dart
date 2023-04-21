import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/widgets/header/header.dart';
import 'package:window_manager/window_manager.dart';
import '../../../../src/imports.dart';

class FlutterSimulatorApp extends StatefulWidget {
  const FlutterSimulatorApp({
    super.key,
    required this.appChild,
  });

  final Widget appChild;

  @override
  State<FlutterSimulatorApp> createState() => _FlutterSimulatorAppState();
}

class _FlutterSimulatorAppState extends State<FlutterSimulatorApp> {
  final _systemUiOverlayStyleNotifier = SystemUiOverlayStyleNotifier();

  var _params = SimulatorParams(
    deviceInfo: AppleDevices.iPhone14,
    deviceOrientationRad: 0.0,
    previousScreenOrientation: DeviceOrientation.portraitUp,
    simulatorBrightness: Brightness.light,
    systemUiOverlayStyle: SystemUiOverlayStyle.light,
  );

  @override
  void initState() {
    super.initState();

    _systemUiOverlayStyleNotifier.addListener(() {
      setState(() {
        _params = _params.copyWith(
          systemUiOverlayStyle: _systemUiOverlayStyleNotifier.value!,
        );
      });
    });
  }

  @override
  void dispose() {
    _systemUiOverlayStyleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var totalSize = _params.deviceFrame.transformSize(
      _params.rawDeviceScreenOrientation.transformSize(
        _params.deviceInfo.screenSize,
      ),
      _params,
    );

    totalSize = Size(
      totalSize.width,
      totalSize.height +
          32.0 +
          SimulatorHeaderWidget.preferredHeight +
          SimulatorToolbarWidget.preferredHeight,
    );

    windowManager.setMaximumSize(totalSize).then((v) {
      windowManager.setSize(totalSize);
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: _params.simulatorBrightness,
        ),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SimulatorHeaderWidget(
                params: _params,
              ),
              const SizedBox(height: 16.0),
              Flexible(
                child: AnimatedSimulatorParams(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  data: _params,
                  builder: (context, params) => SimulatorWidget(
                    params: params,
                    appChild: widget.appChild,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              SimulatorToolbarWidget(
                params: _params,
                onChanged: (params) {
                  setState(() => _params = params);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
