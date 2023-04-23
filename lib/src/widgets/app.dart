import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simulator/src/imports.dart';

final _appRepaintBoundaryKey = GlobalKey();

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
  final _windowSizeManager = WindowSizeManager();

  var _params = SimulatorParams(
    deviceInfo: AppleDevices.iPhone14,
    deviceOrientationRad: 0.0,
    previousScreenOrientation: DeviceOrientation.portraitUp,
    simulatorBrightness: Brightness.light,
    systemUiOverlayStyle: SystemUiOverlayStyle.light,
    isKeyboardVisible: false,
  );

  set params(SimulatorParams params) {
    _tryResizeView(params);

    _params = params;

    debugDefaultTargetPlatformOverride = _params.deviceInfo.platform;

    WidgetsBinding.instance.endOfFrame.then((_) {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();

    final platformChannelInterceptor =
        SystemPlatformChannelInterceptor.ensureInitialized();

    final textInputChannelInterceptor =
        SystemTextInputChannelInterceptor.ensureInitialized();

    platformChannelInterceptor.addListener(() {
      params = _params.copyWith(
        systemUiOverlayStyle: platformChannelInterceptor.systemUiOverlayStyle,
        applicationSwitcherDescription:
            platformChannelInterceptor.applicationSwitcherDescription,
        appPreferredOrientations:
            platformChannelInterceptor.appPreferredOrientations,
      );
    });

    textInputChannelInterceptor.keyboardVisibilityNotifier.addListener(() {
      params = _params.copyWith(
        isKeyboardVisible:
            textInputChannelInterceptor.keyboardVisibilityNotifier.value,
      );
    });

    _tryResizeView(_params);
  }

  @override
  void dispose() {
    SystemPlatformChannelInterceptor.instance.dispose();
    SystemTextInputChannelInterceptor.instance.dispose();
    _windowSizeManager.dispose();
    super.dispose();
  }

  Future<void> _tryResizeView(SimulatorParams newParams) async {
    return _windowSizeManager.setDeviceFrameSize(
      newParams.rawDeviceScreenOrientation.transformSize(
        newParams.deviceFrame.transformSize(
          newParams.deviceInfo.screenSize,
          newParams,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'simulator-app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: _params.simulatorBrightness,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: RepaintBoundary(
          key: _appRepaintBoundaryKey,
          child: Builder(
            builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder(
                  valueListenable: _windowSizeManager.windowSizeNotifier,
                  builder: (context, size, child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: size.width,
                      height: SimulatorHeaderWidget.preferredHeight,
                      child: child,
                    );
                  },
                  child: SimulatorHeaderWidget(
                    params: _params,
                    onChanged: (params) {
                      this.params = params;
                    },
                    onScreenshot: () {
                      takeScreenshot(
                        context,
                        deviceInfo: _params.deviceInfo,
                        key: _appRepaintBoundaryKey,
                      );
                    },
                    onScreenshotDeviceFrame: () {
                      takeScreenshot(
                        context,
                        deviceInfo: _params.deviceInfo,
                        key: SimulatorWidgetsBinding.instance.deviceFrameKey,
                      );
                    },
                    onScreenshotDeviceScreen: () {
                      takeScreenshot(
                        context,
                        deviceInfo: _params.deviceInfo,
                        key: SimulatorWidgetsBinding.instance.deviceScreenKey,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Expanded(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
