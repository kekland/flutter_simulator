import 'dart:math';

import 'package:flutter/material.dart';
import '../../../../../src/imports.dart';

class SimulatorToolbarWidget extends StatelessWidget {
  const SimulatorToolbarWidget({
    super.key,
    required this.params,
    required this.onChanged,
  });

  static double get preferredHeight => 56.0;

  final SimulatorParams params;
  final ValueChanged<SimulatorParams> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: preferredHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
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
            _DeviceFrameToolbarEntryWidget(
              child: IconButton(
                icon: const Icon(Icons.rotate_90_degrees_ccw_rounded),
                padding: const EdgeInsets.all(12.0),
                onPressed: () {
                  onChanged(
                    params.copyWith(
                      deviceOrientationRad: params.deviceOrientationRad - pi / 2,
                    ),
                  );
                },
              ),
            ),
            _DeviceFrameToolbarEntryWidget(
              child: IconButton(
                icon: const Icon(Icons.rotate_90_degrees_cw_rounded),
                padding: const EdgeInsets.all(12.0),
                onPressed: () {
                  onChanged(
                    params.copyWith(
                      deviceOrientationRad: params.deviceOrientationRad + pi / 2,
                    ),
                  );
                },
              ),
            ),
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
            _DeviceFrameToolbarEntryWidget(
              child: IconButton(
                icon: const Icon(Icons.screenshot_rounded),
                padding: const EdgeInsets.all(12.0),
                onPressed: () {},
              ),
            ),
          ],
        ),
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
