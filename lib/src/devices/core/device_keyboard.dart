import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/imports.dart';

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

typedef ViewInsetsTransformer = EdgeInsets Function(
  BuildContext context,
  SimulatorParams params,
  SimulatedIME? ime,
);

class DeviceKeyboard {
  const DeviceKeyboard({
    required this.builder,
    required this.computeViewInsets,
    this.animationBuilder = _buildDefaultKeyboardAnimation,
    this.keyboardRevealAnimationDuration = const Duration(milliseconds: 275),
    this.keyboardRevealAnimationCurve = Curves.fastLinearToSlowEaseIn,
  });

  final DeviceKeyboardAnimationBuilder animationBuilder;
  final DeviceKeyboardBuilder builder;
  final ViewInsetsTransformer computeViewInsets;
  final Duration keyboardRevealAnimationDuration;
  final Curve keyboardRevealAnimationCurve;

  static const DeviceKeyboard none = DeviceKeyboard(
    builder: _buildNoKeyboard,
    computeViewInsets: _computeNoInsets,
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

EdgeInsets _computeNoInsets(
  BuildContext context,
  SimulatorParams params,
  SimulatedIME? ime,
) {
  return EdgeInsets.zero;
}

Widget _buildDefaultKeyboardAnimation(
  BuildContext context,
  Size screenSize,
  SimulatorParams params,
  bool isVisible,
  PreferredSizeWidget keyboardWidget,
) {
  final keyboard = params.deviceInfo.deviceKeyboard;

  return AnimatedPositioned(
    duration: keyboard.keyboardRevealAnimationDuration,
    curve: keyboard.keyboardRevealAnimationCurve,
    width: keyboardWidget.preferredSize.width,
    height: keyboardWidget.preferredSize.height,
    bottom: isVisible ? 0.0 : -keyboardWidget.preferredSize.height,
    child: keyboardWidget,
  );
}
