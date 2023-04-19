import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/imports.dart';

class DeviceFrameApp extends StatefulWidget {
  const DeviceFrameApp({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<DeviceFrameApp> createState() => _DeviceFrameAppState();
}

class _DeviceFrameAppState extends State<DeviceFrameApp>
    with WidgetsBindingObserver {
  final _deviceFrameRepaintBoundaryKey = GlobalKey();
  DeviceInfo? _deviceInfo;
  late MediaQueryData _mediaQueryData;
  var _systemUiOverlayStyle = SystemUiOverlayStyle.light;
  var _rotation = DeviceRotation.deg0;

  @override
  void initState() {
    super.initState();

    _mediaQueryData = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    WidgetsBinding.instance.addObserver(this);

    FlutterSimulatorWidgetBinding.instance!.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.platform,
      (message) {
        if (message.method == 'SystemChrome.setSystemUIOverlayStyle') {
          final data = message.arguments as Map<String, dynamic>;
          _systemUiOverlayStyle = systemUiOverlayStyleFromJson(data);

          setState(() {});
        }

        return null;
      },
    );
  }

  @override
  void didChangeMetrics() {
    _mediaQueryData = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: DeviceFrameWidget(
                      deviceFrameRepaintBoundaryKey:
                          _deviceFrameRepaintBoundaryKey,
                      deviceInfo: _deviceInfo,
                      systemMediaQueryData: _mediaQueryData,
                      systemUiOverlayStyle: _systemUiOverlayStyle,
                      rotation: _rotation,
                      child: widget.child,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                DeviceFrameToolbarWidget(
                  initialDeviceInfo: _deviceInfo,
                  onDeviceInfoChanged: (v) => setState(() => _deviceInfo = v),
                  onRotateCCW: () {
                    setState(() => _rotation = _rotation.rotateCCW());
                  },
                  onRotateCW: () {
                    setState(() => _rotation = _rotation.rotateCW());
                  },
                  onScreenshot: () {
                    takeScreenshot(
                      context,
                      deviceInfo: _deviceInfo!,
                      deviceFrameRepaintBoundaryKey:
                          _deviceFrameRepaintBoundaryKey,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
