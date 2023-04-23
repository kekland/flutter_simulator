import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

// See: https://github.com/drogel/keyboard_attachable

class IOSKeyboardAnimationController {
  IOSKeyboardAnimationController({required TickerProvider vsync})
      : _spring = const SpringDescription(mass: 8, stiffness: 1, damping: 4.5),
        _springVelocity = 10,
        _controller = AnimationController(vsync: vsync);

  final SpringDescription _spring;
  final double _springVelocity;
  final AnimationController _controller;

  Animation<double> get animation => _controller;

  TickerFuture forward() {
    final forwardSimulation = SpringSimulation(_spring, 0, 1, _springVelocity);
    return _controller.animateWith(forwardSimulation);
  }

  TickerFuture reverse() {
    final reverseSimulation = SpringSimulation(_spring, 1, 0, -_springVelocity);
    return _controller.animateWith(reverseSimulation);
  }

  void dispose() => _controller.dispose();
}

class IOSKeyboardAnimatedBuilder extends StatefulWidget {
  const IOSKeyboardAnimatedBuilder({
    super.key,
    required this.builder,
    required this.isVisible,
  });

  final bool isVisible;
  final Widget Function(BuildContext context, double value) builder;

  @override
  State<IOSKeyboardAnimatedBuilder> createState() =>
      _IOSKeyboardAnimatedBuilderState();
}

class _IOSKeyboardAnimatedBuilderState extends State<IOSKeyboardAnimatedBuilder>
    with SingleTickerProviderStateMixin {
  late final IOSKeyboardAnimationController _controller =
      IOSKeyboardAnimationController(vsync: this);

  @override
  void didUpdateWidget(covariant IOSKeyboardAnimatedBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isVisible != widget.isVisible) {
      _animate(widget.isVisible);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = _controller.animation;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => widget.builder(context, animation.value),
    );
  }

  void _animate(bool isKeyboardVisible) =>
      isKeyboardVisible ? _controller.forward() : _controller.reverse();
}
