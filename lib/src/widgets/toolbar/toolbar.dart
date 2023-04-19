import 'package:flutter/material.dart';
import 'package:flutter_simulator/src/imports.dart';

class DeviceFrameToolbarWidget extends StatelessWidget {
  const DeviceFrameToolbarWidget({
    super.key,
    required this.initialDeviceInfo,
    required this.onDeviceInfoChanged,
    required this.onRotateCW,
    required this.onRotateCCW,
  });

  final DeviceInfo? initialDeviceInfo;
  final ValueChanged<DeviceInfo?> onDeviceInfoChanged;
  final VoidCallback onRotateCW;
  final VoidCallback onRotateCCW;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _DeviceFrameToolbarEntryWidget(
            child: DropdownMenu(
              leadingIcon: const Icon(Icons.phone_android),
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
              icon: const Icon(Icons.rotate_90_degrees_ccw),
              padding: const EdgeInsets.all(12.0),
              onPressed: onRotateCCW,
            ),
          ),
          _DeviceFrameToolbarEntryWidget(
            child: IconButton(
              icon: const Icon(Icons.rotate_90_degrees_cw),
              padding: const EdgeInsets.all(12.0),
              onPressed: onRotateCW,
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