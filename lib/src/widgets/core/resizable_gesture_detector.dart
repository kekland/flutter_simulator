import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_desktop_cursor/flutter_desktop_cursor.dart';
import 'package:flutter_simulator/src/imports.dart';
import 'package:window_manager/window_manager.dart';

class ResizableGestureDetectorWidget extends StatelessWidget {
  const ResizableGestureDetectorWidget({
    super.key,
    required this.child,
    required this.params,
  });

  final Widget child;
  final SimulatorParams params;

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return _MacOSResizableGestureDetector(
        params: params,
        child: child,
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.resizeUpLeftDownRight,
      hitTestBehavior: HitTestBehavior.deferToChild,
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onPanStart: (_) {
          windowManager.startResizing(ResizeEdge.bottomRight);
        },
        child: child,
      ),
    );
  }
}

class _MacOSResizableGestureDetector extends StatefulWidget {
  const _MacOSResizableGestureDetector({
    super.key,
    required this.child,
    required this.params,
  });

  final Widget child;
  final SimulatorParams params;

  @override
  State<_MacOSResizableGestureDetector> createState() =>
      _MacOSResizableGestureDetectorState();
}

class _MacOSResizableGestureDetectorState
    extends State<_MacOSResizableGestureDetector> {
  Size? _initialSize;
  Offset? _initialPanPosition;

  @override
  void initState() {
    super.initState();
    windowManager.setResizable(false);
  }

  Future<void> onPanStart(DragStartDetails details) async {
    _initialSize = await windowManager.getSize();
    _initialPanPosition = details.globalPosition;
  }

  Future<void> onPanUpdate(DragUpdateDetails details) async {
    if (_initialPanPosition == null) return;
    final frameSize = widget.params.rawDeviceScreenOrientation.transformSize(
      widget.params.deviceFrame.transformSize(
        widget.params.deviceInfo.screenSize,
        widget.params,
      ),
    );

    final frameAspectRatio = frameSize.aspectRatio;

    final delta = details.globalPosition - _initialPanPosition!;
    final newSize = _initialSize! + delta;

    final minFrameWidth = WindowSizeManager.minWidth;
    final minFrameHeight = minFrameWidth / frameAspectRatio;

    final frameHeight = max(
      minFrameHeight,
      newSize.height - WindowSizeManager.headerHeight,
    );

    final frameWidth = frameHeight * frameAspectRatio;

    final newFixedSize = Size(
      frameWidth,
      frameHeight + WindowSizeManager.headerHeight,
    );

    await windowManager.setSize(newFixedSize.rounded);
  }

  Future<void> onPanEnd() async {
    _initialPanPosition = null;
    _initialSize = null;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: FlutterDesktopCursors.resizeUpLeftDownRight,
      hitTestBehavior: HitTestBehavior.deferToChild,
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: (_) => onPanEnd(),
        onPanCancel: onPanEnd,
        child: widget.child,
      ),
    );
  }
}
