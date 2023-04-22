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

class _FlutterSimulatorAppState extends State<FlutterSimulatorApp>
    with WindowListener {
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
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _systemUiOverlayStyleNotifier.dispose();
    super.dispose();
  }

  Future<void> _tryResizeView(SimulatorParams newParams) async {
    // TODO: Clean up this mess of a code

    const appAdditionalWidth = 0.0;
    final appAdditionalHeight = 16.0 + SimulatorHeaderWidget.preferredHeight;

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
      await windowManager.setMinimumSize(minSize.rounded);
      await windowManager.setMaximumSize(maxSize.rounded);
      windowManager.setSize(maxSize);
    } else {
      if (deviceFrameSize == newDeviceFrameSize) {
        await windowManager.setMinimumSize(minSize.rounded);
        await windowManager.setMaximumSize(newMaxSize.rounded);
        return;
      }

      final currentWindowSize = await windowManager.getSize();

      var newComputedMaxSize = newDeviceFrameSize *
          (currentWindowSize.width - appAdditionalWidth) /
          (maxSize.width - appAdditionalWidth);

      newComputedMaxSize = Size(
        (newComputedMaxSize.width + appAdditionalWidth),
        (newComputedMaxSize.height + appAdditionalHeight),
      );

      await windowManager.setMaximumSize(
        Size.square(newMaxSize.longestSide).rounded,
      );

      await windowManager.setAspectRatio(1.0);
      windowManager
          .setSize(Size.square(newComputedMaxSize.longestSide).rounded);

      await Future.delayed(const Duration(milliseconds: 300));

      await windowManager.setMinimumSize(minSize.rounded);
      await windowManager.setMaximumSize(newMaxSize.rounded);
      windowManager.setSize(newComputedMaxSize.rounded);
    }
  }

  Size? _lastSetSize;
  @override
  Future<void> onWindowResize() async {
    // final size = await windowManager.getSize();
    // if (size == _lastSetSize) return;

    // const appAdditionalWidth = 0.0;
    // final appAdditionalHeight = 16.0 + SimulatorHeaderWidget.preferredHeight;

    // final deviceFrameSize = _params.deviceFrame.transformSize(
    //   _params.rawDeviceScreenOrientation.transformSize(
    //     _params.deviceInfo.screenSize,
    //   ),
    //   _params,
    // );

    // final width = size.width;
    // final height = width * deviceFrameSize.height / deviceFrameSize.width +
    //     appAdditionalHeight;

    // _lastSetSize = Size(width, height).rounded;
    // await windowManager.setSize(_lastSetSize!);
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
                // const SizedBox(height: 16.0),
                // Builder(
                //   builder: (context) => SimulatorToolbarWidget(
                //     params: _params,
                //     onChanged: (params) {
                //       this.params = params;
                //     },
                //     onScreenshot: () {
                //       takeScreenshot(
                //         context,
                //         deviceInfo: _params.deviceInfo,
                //         key: _appRepaintBoundaryKey,
                //       );
                //     },
                //     onScreenshotDeviceFrame: () {
                //       takeScreenshot(
                //         context,
                //         deviceInfo: _params.deviceInfo,
                //         key: SimulatorWidgetsBinding.instance.deviceFrameKey,
                //       );
                //     },
                //     onScreenshotDeviceScreen: () {
                //       takeScreenshot(
                //         context,
                //         deviceInfo: _params.deviceInfo,
                //         key: SimulatorWidgetsBinding.instance.deviceScreenKey,
                //       );
                //     },
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
