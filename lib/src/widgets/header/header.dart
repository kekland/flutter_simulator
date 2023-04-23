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

  @override
  Widget build(BuildContext context) {
    final size = params.deviceFrame.transformSize(
      params.rawDeviceScreenOrientation.transformSize(
        params.deviceScreenSize,
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
        surfaceTintColor: Colors.transparent,
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
                HeaderOptionsMenu(
                  onScreenshot: onScreenshot,
                  onScreenshotDeviceFrame: onScreenshotDeviceFrame,
                  onScreenshotDeviceScreen: onScreenshotDeviceScreen,
                  foregroundColor: foregroundColor,
                ),
                Expanded(
                  child: HeaderTitleWidget(
                    params: params,
                    color: color,
                    foregroundColor: foregroundColor,
                    onDeviceChanged: (info) {
                      onChanged(params.copyWith(deviceInfo: info));
                    },
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
                  padding: const EdgeInsets.all(12.0),
                  icon: Icon(
                    Icons.rotate_90_degrees_cw_rounded,
                    color: foregroundColor,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    windowManager.close();
                  },
                  padding: const EdgeInsets.all(12.0),
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

class HeaderOptionsMenu extends StatelessWidget {
  const HeaderOptionsMenu({
    super.key,
    required this.onScreenshot,
    required this.onScreenshotDeviceFrame,
    required this.onScreenshotDeviceScreen,
    this.foregroundColor,
  });

  final VoidCallback onScreenshot;
  final VoidCallback onScreenshotDeviceFrame;
  final VoidCallback onScreenshotDeviceScreen;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert_rounded,
        color: foregroundColor,
      ),
      tooltip: 'Show options',
      surfaceTintColor: Colors.transparent,
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
        Opacity(opacity: 0.5, child: Icon(icon)),
        const SizedBox(width: 12.0),
        Text(label),
      ],
    );
  }
}

class HeaderTitleWidget extends StatelessWidget {
  const HeaderTitleWidget({
    super.key,
    required this.params,
    required this.color,
    required this.foregroundColor,
    required this.onDeviceChanged,
  });

  final Color? color;
  final Color? foregroundColor;
  final SimulatorParams params;
  final ValueChanged<DeviceInfo> onDeviceChanged;

  String get titleString {
    final label = params.applicationSwitcherDescription?.label;

    if (label == null) {
      return 'Emulator';
    }

    return label;
  }

  String get subtitleString {
    final size = params.deviceScreenOrientation.transformSize(
      params.phyiscalPixelsScreenSize,
    );

    return '${params.deviceInfo.name} - ${size.width.toStringAsFixed(0)} x ${size.height.toStringAsFixed(0)}';
  }

  PopupMenuItem _buildDeviceItem(DeviceInfo device) {
    return PopupMenuItem(
      value: device,
      child: Text(device.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final devices = [
      DeviceInfo.none,
      AppleDevices.iPhone14,
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(4.0),
      child: Material(
        type: MaterialType.transparency,
        child: PopupMenuButton(
          initialValue: params.deviceInfo,
          itemBuilder: (context) => devices.map(_buildDeviceItem).toList(),
          onSelected: (value) {
            onDeviceChanged(value as DeviceInfo);
          },
          tooltip: 'Show device picker',
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleString,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(height: 1.0, color: foregroundColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitleString,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.0,
                    color: foregroundColor?.withOpacity(0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
