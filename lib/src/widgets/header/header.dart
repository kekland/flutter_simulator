import 'package:flutter/material.dart';
import 'package:flutter_simulator/src/imports.dart';
import 'package:window_manager/window_manager.dart';

class SimulatorHeaderWidget extends StatelessWidget {
  const SimulatorHeaderWidget({super.key, required this.params});

  static double get preferredHeight => 72.0;

  final SimulatorParams params;

  @override
  Widget build(BuildContext context) {
    final size = params.deviceFrame.transformSize(
      params.deviceScreenOrientation.transformSize(
        params.deviceInfo.screenSize,
      ),
      params,
    );

    final theme = Theme.of(context);

    return SizedBox(
      height: preferredHeight,
      child: Card(
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
                        style:
                            theme.textTheme.titleMedium?.copyWith(height: 1.0),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        '${params.deviceInfo.name} - ${params.deviceInfo.screenSize}',
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.0),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    windowManager.close();
                  },
                  icon: const Icon(Icons.close),
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
