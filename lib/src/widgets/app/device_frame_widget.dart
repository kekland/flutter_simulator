import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simulator/src/imports.dart';

class DeviceFrameWidget extends StatelessWidget {
  const DeviceFrameWidget({
    super.key,
    required this.deviceInfo,
    required this.deviceFrameRepaintBoundaryKey,
    required this.rotation,
    required this.systemUiOverlayStyle,
    required this.systemMediaQueryData,
    required this.child,
  });

  final Key deviceFrameRepaintBoundaryKey;
  final MediaQueryData systemMediaQueryData;
  final SystemUiOverlayStyle systemUiOverlayStyle;
  final DeviceInfo? deviceInfo;
  final DeviceRotation rotation;
  final Widget child;

  MediaQueryData get _screenMediaQueryData {
    final viewPadding = viewPaddingWithRotation(
      rotation,
      deviceInfo!.viewPadding,
      deviceInfo!.rotatedViewPadding,
    );

    return systemMediaQueryData.copyWith(
      size: sizeWithRotation(rotation, deviceInfo!.screenSize),
      viewPadding: viewPadding,
      padding: viewPadding,
    );
  }

  Widget _buildApp(BuildContext context) {
    return MediaQuery(
      data: _screenMediaQueryData,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: _screenMediaQueryData.size.width,
          height: _screenMediaQueryData.size.height,
          child: child,
        ),
      ),
    );
  }

  Widget _buildFrame(BuildContext context, Widget child) {
    final frameInfo = deviceInfo!.frame!;
    final size = sizeWithRotation(rotation, frameInfo.size);

    return FittedBox(
      fit: BoxFit.fill,
      child: RepaintBoundary(
        key: deviceFrameRepaintBoundaryKey,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: frameInfo.builder(
            context,
            child,
            rotation,
            systemUiOverlayStyle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (deviceInfo == null) return this.child;

    Widget child = _buildApp(context);

    if (deviceInfo!.frame != null) {
      child = _buildFrame(context, child);
    }

    return child;
  }
}
