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

  set params(SimulatorParams params) {
    _tryResizeView(params);
    setState(() => _params = params);
  }

  @override
  void initState() {
    super.initState();

    _systemUiOverlayStyleNotifier.addListener(() {
      params = _params.copyWith(
        systemUiOverlayStyle: _systemUiOverlayStyleNotifier.value!,
      );
    });

    _tryResizeView(_params);
  }

  @override
  void dispose() {
    _systemUiOverlayStyleNotifier.dispose();
    super.dispose();
  }

  Future<void> _tryResizeView(SimulatorParams newParams) async {
    const appAdditionalWidth = 32.0;
    final appAdditionalHeight = 64.0 +
        SimulatorHeaderWidget.preferredHeight +
        SimulatorToolbarWidget.preferredHeight;

    final deviceFrameSize = _params.deviceFrame.transformSize(
      _params.rawDeviceScreenOrientation.transformSize(
        _params.deviceInfo.screenSize,
      ),
      _params,
    );

    final newDeviceFrameSize = newParams.deviceFrame.transformSize(
      newParams.rawDeviceScreenOrientation.transformSize(
        _params.deviceInfo.screenSize,
      ),
      newParams,
    );

    final maxSize = Size(
      deviceFrameSize.width + appAdditionalWidth,
      deviceFrameSize.height + appAdditionalHeight,
    );

    final newMaxSize = Size(
      newDeviceFrameSize.width + appAdditionalWidth,
      newDeviceFrameSize.height + appAdditionalHeight,
    );

    final frameRenderObject = SimulatorWidgetsBinding
        .instance.deviceFrameKey.currentContext
        ?.findRenderObject();

    if (frameRenderObject == null) {
      await windowManager.setMaximumSize(maxSize);
      await windowManager.setAspectRatio(maxSize.aspectRatio);
      windowManager.setSize(maxSize);
    } else {
      if (deviceFrameSize == newDeviceFrameSize) {
        return;
      }

      final currentWindowSize = await windowManager.getSize();

      var newComputedMaxSize = newDeviceFrameSize *
          (currentWindowSize.width - appAdditionalWidth) /
          (maxSize.width - appAdditionalWidth);

      newComputedMaxSize = Size(
        (newComputedMaxSize.width + appAdditionalWidth).roundToDouble(),
        (newComputedMaxSize.height + appAdditionalHeight).roundToDouble(),
      );

      await windowManager.setMaximumSize(Size.square(newMaxSize.longestSide));
      windowManager.setSize(Size.square(newComputedMaxSize.longestSide));

      await Future.delayed(Duration(milliseconds: 300));

      await windowManager.setMaximumSize(newMaxSize);
      windowManager.setSize(newComputedMaxSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: _params.simulatorBrightness,
        ),
        useMaterial3: true,
      ),
      home: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Builder(
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SimulatorHeaderWidget(
                params: _params,
                onChanged: (params) {
                  this.params = params;
                },
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
                  this.params = params;
                },
                onScreenshot: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
