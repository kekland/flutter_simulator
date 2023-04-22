import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_simulator/src/imports.dart';
import 'package:window_manager/window_manager.dart';

class SimulatorHeaderWidget extends StatelessWidget {
  const SimulatorHeaderWidget({
    super.key,
    required this.params,
    required this.onChanged,
  });

  static double get preferredHeight => 64.0;

  final SimulatorParams params;
  final ValueChanged<SimulatorParams> onChanged;

  String get titleString {
    final label = params.applicationSwitcherDescription?.label;

    if (label == null) {
      return 'Emulator';
    }

    return label;
  }

  String get screenSizeString {
    final size = params.deviceScreenOrientation.transformSize(
      params.deviceInfo.phyiscalPixelsScreenSize,
    );

    return '${size.width.toStringAsFixed(0)} x ${size.height.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final size = params.deviceFrame.transformSize(
      params.rawDeviceScreenOrientation.transformSize(
        params.deviceInfo.screenSize,
      ),
      params,
    );

    final theme = Theme.of(context);
    final colorValue = params.applicationSwitcherDescription?.primaryColor;
    final color = colorValue != null ? Color(colorValue) : null;

    late final Color? foregroundColor;

    if (color != null) {
      final brightness = ThemeData.estimateBrightnessForColor(color);
      foregroundColor =
          brightness == Brightness.dark ? Colors.white : Colors.black;
    } else {
      foregroundColor = theme.appBarTheme.foregroundColor;
    }

    return SizedBox(
      height: SimulatorHeaderWidget.preferredHeight,
      child: Card(
        color: color,
        margin: EdgeInsets.zero,
        elevation: 4.0,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onPanStart: (_) {
              windowManager.startDragging();
            },
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: size.width,
              height: double.infinity,
              child: Row(
                children: [
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titleString,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(height: 1.0, color: foregroundColor),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          '${params.deviceInfo.name} - $screenSizeString',
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.0,
                            color: foregroundColor?.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      onChanged(
                        params.copyWith(
                          deviceOrientationRad:
                              params.deviceOrientationRad + pi / 2,
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.rotate_90_degrees_cw_rounded,
                      color: foregroundColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      windowManager.close();
                    },
                    icon: Icon(Icons.close_rounded, color: foregroundColor),
                  ),
                  const SizedBox(width: 8.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
