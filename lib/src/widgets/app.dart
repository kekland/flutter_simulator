// ignore_for_file: use_build_context_synchronously

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

class _FlutterSimulatorAppState extends State<FlutterSimulatorApp>
    with TickerProviderStateMixin {
  late final FocusScopeNode _headerFocusScopeNode;
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
    if (params == _params) return;

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

    _headerFocusScopeNode = FocusScopeNode();

    _tryResizeView(_params);
  }

  @override
  void dispose() {
    SystemPlatformChannelInterceptor.instance.dispose();
    SystemTextInputChannelInterceptor.instance.dispose();
    _windowSizeManager.dispose();
    _headerFocusScopeNode.dispose();

    super.dispose();
  }

  Future<void> _tryResizeView(SimulatorParams newParams) async {
    return _windowSizeManager.resizeWithSimulatorParams(
      newParams,
      vsync: this,
    );
  }

  Widget _buildHeader(BuildContext context, SimulatorParams params) {
    final header = SimulatorHeaderWidget(
      params: params,
      onChanged: (params) {
        this.params = params;
      },
      onScreenshot: () async {
        await Future.delayed(const Duration(milliseconds: 300));

        takeScreenshot(
          context,
          deviceInfo: params.deviceInfo,
          key: _appRepaintBoundaryKey,
        );
      },
      onScreenshotDeviceFrame: () async {
        await Future.delayed(const Duration(milliseconds: 300));

        takeScreenshot(
          context,
          deviceInfo: params.deviceInfo,
          key: SimulatorWidgetsBinding.instance.deviceFrameKey,
        );
      },
      onScreenshotDeviceScreen: () async {
        await Future.delayed(const Duration(milliseconds: 300));

        takeScreenshot(
          context,
          deviceInfo: params.deviceInfo,
          key: SimulatorWidgetsBinding.instance.deviceScreenKey,
        );
      },
    );

    return ValueListenableBuilder(
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
      child: header,
    );
  }

  Widget _buildSimulator(BuildContext context, SimulatorParams params) {
    return AnimatedSimulatorParams(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      data: params,
      builder: (context, params) => SimulatorWidget(
        params: params,
        appChild: widget.appChild,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: _headerFocusScopeNode,
      canRequestFocus: false,
      child: MaterialApp(
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
            child: ResizableSimulatorHandler(
              params: _params,
              builder: (context, params) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, params),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: _buildSimulator(context, params),
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

class ResizableSimulatorHandler extends StatelessWidget {
  const ResizableSimulatorHandler({
    super.key,
    required this.params,
    required this.builder,
  });

  final SimulatorParams params;
  final Widget Function(BuildContext context, SimulatorParams params) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!params.deviceInfo.isResizable) {
          return builder(context, params.copyWithoutOverrides());
        }

        final maxSize = constraints.biggest;
        final deviceScreenSize = Size(
          maxSize.width - 4.0,
          maxSize.height - SimulatorHeaderWidget.preferredHeight - 16.0 - 4.0,
        );

        return builder(
          context,
          params.copyWith(
            deviceScreenSizeOverride: deviceScreenSize,
            deviceOrientationRadOverride: 0.0,
          ),
        );
      },
    );
  }
}
