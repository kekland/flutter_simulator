import 'dart:math';

import 'package:flutter/material.dart';
import '../../../../../src/imports.dart';

class SimulatorToolbarWidget extends StatelessWidget {
  const SimulatorToolbarWidget({
    super.key,
    required this.params,
    required this.onChanged,
    required this.onScreenshot,
    required this.onScreenshotDeviceFrame,
    required this.onScreenshotDeviceScreen,
  });

  static double get preferredWidth => 279.0;
  static double get preferredHeight => 56.0;

  final SimulatorParams params;
  final ValueChanged<SimulatorParams> onChanged;
  final VoidCallback onScreenshot;
  final VoidCallback onScreenshotDeviceFrame;
  final VoidCallback onScreenshotDeviceScreen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: preferredHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DeviceFrameToolbarEntryWidget(
            child: DropdownMenu(
              leadingIcon: const Icon(Icons.phone_android_rounded),
              onSelected: (v) {
                return onChanged(params.copyWith(deviceInfo: v));
              },
              initialSelection: params.deviceInfo,
              dropdownMenuEntries: [
                const DropdownMenuEntry(label: 'none', value: null),
                ...AppleDevices.devices.map((v) => DropdownMenuEntry(
                      label: v.name,
                      value: v,
                    )),
              ],
              inputDecorationTheme: const InputDecorationTheme(
                border: InputBorder.none,
              ),
            ),
          ),
          // _DeviceFrameToolbarEntryWidget(
          //   child: IconButton(
          //     icon: const Icon(Icons.rotate_90_degrees_ccw_rounded),
          //     padding: const EdgeInsets.all(12.0),
          //     onPressed: () {
          //       onChanged(
          //         params.copyWith(
          //           deviceOrientationRad: params.deviceOrientationRad - pi / 2,
          //         ),
          //       );
          //     },
          //   ),
          // ),
          // _DeviceFrameToolbarEntryWidget(
          //   child: IconButton(
          //     icon: const Icon(Icons.rotate_90_degrees_cw_rounded),
          //     padding: const EdgeInsets.all(12.0),
          //     onPressed: () {
          //       onChanged(
          //         params.copyWith(
          //           deviceOrientationRad:
          //               params.deviceOrientationRad + pi / 2,
          //         ),
          //       );
          //     },
          //   ),
          // ),
          _DeviceFrameToolbarEntryWidget(
            child: IconButton(
              icon: Icon(
                params.simulatorBrightness == Brightness.light
                    ? Icons.sunny
                    : Icons.nightlight,
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
          ),
          // _DeviceFrameToolbarEntryWidget(
          //   child: IconButton(
          //     icon: const Icon(Icons.screenshot_rounded),
          //     padding: const EdgeInsets.all(12.0),
          //     onPressed: () {},
          //   ),
          // ),
          _DeviceFrameToolbarEntryWidget(
            child: PopupMenuButton(
              child: const SizedBox(
                width: 32.0,
                height: 48.0,
                child: Icon(Icons.more_vert_rounded),
              ),
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
          ),
        ],
      ),
    );
  }
}

class _DeviceFrameToolbarEntryWidget extends StatelessWidget {
  const _DeviceFrameToolbarEntryWidget({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: SizedBox(
        height: 48.0,
        child: Center(child: child),
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
