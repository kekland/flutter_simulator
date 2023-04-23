import 'dart:math';

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

  PreferredSizeWidget _buildKeyboard(BuildContext context) {
    final keyboard = params.deviceInfo.deviceKeyboard;
    return keyboard.builder(
      context,
      params,
      SystemTextInputChannelInterceptor.instance.maybeActiveIME,
    );
  }

  Widget _buildKeyboardWithAnimation(BuildContext context) {
    final keyboard = params.deviceInfo.deviceKeyboard;
    return ValueListenableBuilder(
      valueListenable:
          SystemTextInputChannelInterceptor.instance.keyboardVisibilityNotifier,
      builder: (context, isVisible, child) {
        final keyboardChild = child as PreferredSizeWidget;

        return keyboard.animationBuilder(
          context,
          params.orientedScreenSize,
          params,
          isVisible,
          keyboardChild,
        );
      },
      child: _buildKeyboard(context),
    );
  }

  /// Builds the app widget.
  ///
  /// This is wrapped in a [RepaintBoundary] to prevent the simulator stuff
  /// from being repainted when the stuff in the app is repainted.
  Widget _buildAppWidget(BuildContext context) {
    return RepaintBoundary(
      key: deviceContentAwareScreenForegroundKey,
      child: RepaintBoundary(
        key: SimulatorWidgetsBinding.instance.deviceScreenKey,
        child: Stack(
          children: [
            widget.appChild,
            _buildKeyboardWithAnimation(context),
          ],
        ),
      ),
    );
  }

  /// This wraps the app with appropriate [MediaQuery] data.
  Widget _buildMediaQuery(BuildContext context) {
    final size = params.orientedScreenSize;

    final keyboard = params.deviceInfo.deviceKeyboard;

    return ValueListenableBuilder(
      valueListenable:
          SystemTextInputChannelInterceptor.instance.keyboardVisibilityNotifier,
      builder: (context, isKeyboardVisible, child) {
        return AnimatedViewInsets(
          duration: keyboard.keyboardRevealAnimationDuration,
          curve: keyboard.keyboardRevealAnimationCurve,
          viewInsets: isKeyboardVisible
              ? keyboard.computeViewInsets(
                  context,
                  params,
                  SystemTextInputChannelInterceptor.instance.maybeActiveIME,
                )
              : EdgeInsets.zero,
          builder: (context, viewInsets) {
            final viewPadding = params.viewPadding;

            final padding = EdgeInsets.only(
              left: max(viewPadding.left, viewInsets.left),
              top: max(viewPadding.top, viewInsets.top),
              right: max(viewPadding.right, viewInsets.right),
              bottom: max(viewPadding.bottom, viewInsets.bottom),
            );

            final mediaQueryData = _mediaQueryData.copyWith(
              size: size,
              viewPadding: viewPadding,
              viewInsets: viewInsets,
              padding: padding,
              platformBrightness: simulatorBrightness,
            );

            return MediaQuery(
              data: mediaQueryData,
              child: child!,
            );
          },
        );
      },
      child: _buildAppWidget(context),
    );
  }

  Widget _buildResizableArea(BuildContext context) {
    final size = params.orientedScreenSize;

    return SizedBox.fromSize(
      size: size,
      child: MouseRegion(
        cursor: SystemMouseCursors.basic,
        hitTestBehavior: HitTestBehavior.opaque,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (_) {},
          child: _buildMediaQuery(context),
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
            params: params,
            child: _buildResizableArea(context),
          ),
        ),
      ),
    );
  }
}
