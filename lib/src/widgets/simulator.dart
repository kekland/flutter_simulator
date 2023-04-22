import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simulator/src/imports.dart';

/// A widget that builds the simulator.
///
/// This builds the app and the device frame.
class SimulatorWidget extends StatefulWidget {
  const SimulatorWidget({
    super.key,
    required this.params,
    required this.appChild,
  });

  final SimulatorParams params;
  final Widget appChild;

  @override
  State<SimulatorWidget> createState() => _SimulatorWidgetState();
}

class _SimulatorWidgetState extends State<SimulatorWidget>
    with WidgetsBindingObserver {
  /// The [MediaQueryData] of the surrounding platform.
  ///
  /// This is transformed in [_buildAppWidget()] to provide one suitable for the
  /// simulated app.
  late MediaQueryData _mediaQueryData;

  @override
  void initState() {
    super.initState();

    _mediaQueryData = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    WidgetsBinding.instance.addObserver(this);
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

  SimulatorParams get params => widget.params;
  DeviceInfo get deviceInfo => params.deviceInfo;
  DeviceOrientation get deviceScreenOrientation =>
      params.deviceScreenOrientation;

  Brightness get simulatorBrightness => params.simulatorBrightness;

  /// Builds the app widget.
  ///
  /// This is wrapped in a [RepaintBoundary] to prevent the simulator stuff
  /// from being repainted when the stuff in the app is repainted.
  ///
  /// This also wraps the app with appropriate [MediaQuery] data, as well as
  /// sizing it to the size of the device.
  Widget _buildAppWidget(BuildContext context) {
    final size = params.screenSize;

    final mediaQueryData = _mediaQueryData.copyWith(
      size: size,
      viewPadding: params.viewPadding,
      padding: params.viewPadding,
      platformBrightness: simulatorBrightness,
    );

    return SizedBox.fromSize(
      size: size,
      child: MouseRegion(
        cursor: SystemMouseCursors.basic,
        hitTestBehavior: HitTestBehavior.opaque,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (_) {},
          child: MediaQuery(
            data: mediaQueryData,
            child: RepaintBoundary(
              key: deviceContentAwareScreenForegroundKey,
              child: RepaintBoundary(
                key: SimulatorWidgetsBinding.instance.deviceScreenKey,
                child: widget.appChild,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.topLeft,
      child: ResizableGestureDetectorWidget(
        params: params,
        child: RepaintBoundary(
          key: SimulatorWidgetsBinding.instance.deviceFrameKey,
          child: SimulatorRenderObjectWidget(
            key: const Key('simulator-render-object'),
            params: widget.params,
            child: _buildAppWidget(context),
          ),
        ),
      ),
    );
  }
}
