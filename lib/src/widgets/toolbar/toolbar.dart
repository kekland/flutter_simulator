import 'package:flutter/material.dart';
import 'package:flutter_simulator/src/imports.dart';

class DeviceFrameToolbarWidget extends StatelessWidget {
  const DeviceFrameToolbarWidget({
    super.key,
    required this.initialDeviceInfo,
    required this.onDeviceInfoChanged,
    required this.onRotateCW,
    required this.onRotateCCW,
    required this.onScreenshot,
    required this.brightness,
    required this.onBrightnessChanged,
  });

  final DeviceInfo? initialDeviceInfo;
  final ValueChanged<DeviceInfo?> onDeviceInfoChanged;
  final VoidCallback onRotateCW;
  final VoidCallback onRotateCCW;
  final VoidCallback onScreenshot;
  final Brightness brightness;
  final ValueChanged<Brightness> onBrightnessChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _DeviceFrameToolbarEntryWidget(
            child: DropdownMenu(
              leadingIcon: const Icon(Icons.phone_android_rounded),
              onSelected: (v) => onDeviceInfoChanged(v),
              initialSelection: initialDeviceInfo,
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
          _DeviceFrameToolbarEntryWidget(
            child: IconButton(
              icon: const Icon(Icons.rotate_90_degrees_ccw_rounded),
              padding: const EdgeInsets.all(12.0),
              onPressed: onRotateCCW,
            ),
          ),
          _DeviceFrameToolbarEntryWidget(
            child: IconButton(
              icon: const Icon(Icons.rotate_90_degrees_cw_rounded),
              padding: const EdgeInsets.all(12.0),
              onPressed: onRotateCW,
            ),
          ),
          _DeviceFrameToolbarEntryWidget(
            child: IconButton(
              icon: Icon(
                brightness == Brightness.light ? Icons.sunny : Icons.nightlight,
              ),
              padding: const EdgeInsets.all(12.0),
              onPressed: () => onBrightnessChanged(
                brightness == Brightness.light
                    ? Brightness.dark
                    : Brightness.light,
              ),
            ),
          ),
          _DeviceFrameToolbarEntryWidget(
            child: IconButton(
              icon: const Icon(Icons.screenshot_rounded),
              padding: const EdgeInsets.all(12.0),
              onPressed: onScreenshot,
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
      child: SizedBox(
        height: 48.0,
        child: Center(child: child),
      ),
    );
  }
}
