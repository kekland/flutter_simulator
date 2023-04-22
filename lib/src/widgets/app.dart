import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/widgets/header/header.dart';
import 'package:window_manager/window_manager.dart';
import '../../../../src/imports.dart';

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
    _params = params;

    debugDefaultTargetPlatformOverride = _params.deviceInfo.platform;

    WidgetsBinding.instance.endOfFrame.then((_) {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();

    _systemUiOverlayStyleNotifier.addListener(() {
      params = _params.copyWith(
        systemUiOverlayStyle:
            _systemUiOverlayStyleNotifier.systemUiOverlayStyle,
        applicationSwitcherDescription:
            _systemUiOverlayStyleNotifier.applicationSwitcherDescription,
        appPreferredOrientations:
            _systemUiOverlayStyleNotifier.appPreferredOrientations,
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
        newParams.deviceInfo.screenSize,
      ),
      newParams,
    );

    final minWidth = SimulatorToolbarWidget.preferredWidth;

    final minSize = Size(
      minWidth + appAdditionalWidth,
      minWidth * newDeviceFrameSize.height / newDeviceFrameSize.width +
          appAdditionalHeight,
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
      await windowManager.setMinimumSize(minSize);
      await windowManager.setMaximumSize(maxSize);
      await windowManager.setAspectRatio(maxSize.aspectRatio);
      windowManager.setSize(maxSize);
    } else {
      if (deviceFrameSize == newDeviceFrameSize) {
        await windowManager.setMinimumSize(minSize);
        await windowManager.setMaximumSize(newMaxSize);
        await windowManager.setAspectRatio(newMaxSize.aspectRatio);
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
      await windowManager.setAspectRatio(1.0);
      windowManager.setSize(Size.square(newComputedMaxSize.longestSide));

      await Future.delayed(const Duration(milliseconds: 300));

      await windowManager.setMinimumSize(minSize);
      await windowManager.setMaximumSize(newMaxSize);
      await windowManager.setAspectRatio(newMaxSize.aspectRatio);
      windowManager.setSize(newComputedMaxSize);
    }
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
          child: Padding(
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
                  Builder(
                    builder: (context) => SimulatorToolbarWidget(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
