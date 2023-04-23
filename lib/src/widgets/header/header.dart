import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_simulator/src/imports.dart';
import 'package:window_manager/window_manager.dart';

class SimulatorHeaderWidget extends StatelessWidget {
  const SimulatorHeaderWidget({
    super.key,
    required this.params,
    required this.onChanged,
    required this.onScreenshot,
    required this.onScreenshotDeviceFrame,
    required this.onScreenshotDeviceScreen,
  });

  static double get preferredHeight => 64.0;

  final SimulatorParams params;
  final ValueChanged<SimulatorParams> onChanged;
  final VoidCallback onScreenshot;
  final VoidCallback onScreenshotDeviceFrame;
  final VoidCallback onScreenshotDeviceScreen;

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
                const SizedBox(width: 8.0),
                PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: foregroundColor,
                  ),
                  padding: const EdgeInsets.all(12.0),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: onScreenshot,
                      child: const PopupMenuItemChild(
                        icon: Icons.image_rounded,
                        label: 'Take screenshot',
                      ),
                    ),
                    PopupMenuItem(
                      onTap: onScreenshotDeviceFrame,
                      child: const PopupMenuItemChild(
                        icon: Icons.phone_iphone_rounded,
                        label: 'Capture device frame',
                      ),
                    ),
                    PopupMenuItem(
                      onTap: onScreenshotDeviceScreen,
                      child: const PopupMenuItemChild(
                        icon: Icons.image_rounded,
                        label: 'Capture device screen',
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8.0),
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
                  icon: Icon(
                    params.simulatorBrightness == Brightness.light
                        ? Icons.sunny
                        : Icons.nightlight,
                    color: foregroundColor,
                  ),
                  padding: const EdgeInsets.all(12.0),
                  onPressed: () {
                    final brightness =
                        params.simulatorBrightness == Brightness.light
                            ? Brightness.dark
                            : Brightness.light;

                    onChanged(params.copyWith(simulatorBrightness: brightness));
                  },
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
    );
  }
}

class PopupMenuItemChild extends StatelessWidget {
  const PopupMenuItemChild({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8.0),
        Text(label),
      ],
    );
  }
}
