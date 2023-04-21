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

  @override
  Widget build(BuildContext context) {
    final size = params.deviceFrame.transformSize(
      params.rawDeviceScreenOrientation.transformSize(
        params.deviceInfo.screenSize,
      ),
      params,
    );

    final theme = Theme.of(context);

    return SizedBox(
      height: SimulatorHeaderWidget.preferredHeight,
      child: Card(
        margin: EdgeInsets.zero,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
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
                          'Flutter Emulator',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(height: 1.0),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          '${params.deviceInfo.name} - ${params.deviceInfo.screenSize}',
                          style:
                              theme.textTheme.bodySmall?.copyWith(height: 1.0),
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
                    icon: const Icon(Icons.rotate_90_degrees_cw_rounded),
                  ),
                  IconButton(
                    onPressed: () {
                      windowManager.close();
                    },
                    icon: const Icon(Icons.close_rounded),
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
