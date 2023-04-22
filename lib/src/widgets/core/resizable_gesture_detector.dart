import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class ResizableGestureDetectorWidget extends StatelessWidget {
  const ResizableGestureDetectorWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
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
