import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_simulator/src/imports.dart';

/// Paints the physical device frame.
typedef PhysicalDeviceFramePainter = void Function(
  PaintingContext context,
  Offset offset,
  Size size,
  Rect screenRect,
  SimulatorParams params,
);

/// Paints the physical device items that are on top of the screen.
///
/// For example, this is a notch on the iPhone X.
typedef ForegroundPhysicalDeviceFramePainter = void Function(
  PaintingContext context,
  Offset offset,
  Size size,
  Rect screenRect,
  SimulatorParams params,
);

/// Paints the device screen.
///
/// This is the part of the device that displays the app.
///
/// An optional layer can be returned if the screen is clipped.
typedef DeviceScreenPainter = ContainerLayer? Function(
  PaintingContext context,
  Offset offset,
  Rect screenRect,
  SimulatorParams params,
  RenderObject child,
  ContainerLayer? oldLayer,
);

/// Paints the device screen items that are on top of the app.
///
/// For example, this is the status bar.
typedef DeviceScreenForegroundPainter = void Function(
  PaintingContext context,
  Offset offset,
  Rect screenRect,
  SimulatorParams params,
);

/// Paints the device screen items that are on top of the app and dependent
/// on the screen contents.
///
/// For example, this is the home indicator on the iPhone X.
typedef ContentAwareDeviceScreenForegroundPainter = void Function(
  Canvas canvas,
  Size screenSize,
  SimulatorParams params,
  ByteData? byteData,
);

/// Transforms the size of the displayed widget.
typedef SizeTransformer = Size Function(
  Size screenSize,
  SimulatorParams params,
);

/// Transforms the offset of the screen.
typedef ScreenOffsetTransformer = Offset Function(
  Size size,
  Size screenSize,
  SimulatorParams params,
);

class DeviceFrame {
  const DeviceFrame({
    required this.paintDeviceScreen,
    required this.transformScreenOffset,
    required this.transformSize,
    this.frameRadius = Radius.zero,
    this.paintPhysicalDeviceFrame,
    this.paintForegroundPhysicalDeviceFrame,
    this.paintDeviceScreenForeground,
    this.paintContentAwareDeviceScreenForeground,
  });

  final Radius frameRadius;
  final ScreenOffsetTransformer transformScreenOffset;
  final SizeTransformer transformSize;
  final PhysicalDeviceFramePainter? paintPhysicalDeviceFrame;
  final ForegroundPhysicalDeviceFramePainter?
      paintForegroundPhysicalDeviceFrame;
  final DeviceScreenPainter paintDeviceScreen;
  final DeviceScreenForegroundPainter? paintDeviceScreenForeground;
  final ContentAwareDeviceScreenForegroundPainter?
      paintContentAwareDeviceScreenForeground;

  /// A device frame that does no transformations to the screen.
  static const DeviceFrame none = DeviceFrame(
    paintDeviceScreen: _noneDeviceScreenPainter,
    transformScreenOffset: _noneScreenOffsetTransformer,
    transformSize: _noneSizeTransformer,
  );
}

ContainerLayer? _noneDeviceScreenPainter(
  PaintingContext context,
  Offset offset,
  Rect screenRect,
  SimulatorParams params,
  RenderObject child,
  ContainerLayer? oldLayer,
) {
  context.paintChild(child, offset);
  return null;
}

Offset _noneScreenOffsetTransformer(
  Size size,
  Size screenSize,
  SimulatorParams params,
) {
  return Offset.zero;
}

Size _noneSizeTransformer(
  Size size,
  SimulatorParams params,
) {
  return size;
}
