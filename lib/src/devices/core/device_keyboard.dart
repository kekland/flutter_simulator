import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/imports.dart';

mixin ViewInsettingWidget on Widget {
  EdgeInsets get viewInsets;
}

typedef DeviceKeyboardAnimationBuilder = Widget Function(
  BuildContext context,
  Size screenSize,
  SimulatorParams params,
  bool isVisible,
  PreferredSizeWidget keyboardWidget,
);

typedef DeviceKeyboardBuilder = PreferredSizeWidget Function(
  BuildContext context,
  SimulatorParams params,
  SimulatedIME? ime,
);

typedef ViewInsetsBuilder = Widget Function(
  BuildContext context,
  SimulatorParams params,
  SimulatedIME? ime,
  bool isVisible,
  Widget Function(BuildContext context, EdgeInsets viewInsets) builder,
);

class DeviceKeyboard {
  const DeviceKeyboard({
    required this.builder,
    required this.viewInsetsBuilder,
    this.animationBuilder = _buildDefaultKeyboardAnimation,
  });

  final DeviceKeyboardAnimationBuilder animationBuilder;
  final DeviceKeyboardBuilder builder;
  final ViewInsetsBuilder viewInsetsBuilder;

  static const DeviceKeyboard none = DeviceKeyboard(
    builder: _buildNoKeyboard,
    viewInsetsBuilder: _buildNoInsets,
  );
}

PreferredSizeWidget _buildNoKeyboard(
  BuildContext context,
  SimulatorParams params,
  SimulatedIME? ime,
) {
  return const PreferredSize(
    preferredSize: Size.zero,
    child: SizedBox.shrink(),
  );
}

Widget _buildNoInsets(
  BuildContext context,
  SimulatorParams params,
  SimulatedIME? ime,
  bool isVisible,
  Widget Function(BuildContext context, EdgeInsets viewInsets) builder,
) {
  return builder(context, EdgeInsets.zero);
}

Widget _buildDefaultKeyboardAnimation(
  BuildContext context,
  Size screenSize,
  SimulatorParams params,
  bool isVisible,
  PreferredSizeWidget keyboardWidget,
) {
  return Positioned(
    width: keyboardWidget.preferredSize.width,
    height: keyboardWidget.preferredSize.height,
    bottom: 0.0,
    child: Visibility(
      visible: isVisible,
      child: RepaintBoundary(child: keyboardWidget),
    ),
  );
}
