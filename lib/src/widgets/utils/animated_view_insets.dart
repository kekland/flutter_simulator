import 'package:flutter/material.dart';

class AnimatedViewInsets extends ImplicitlyAnimatedWidget {
  const AnimatedViewInsets({
    super.key,
    required super.duration,
    required super.curve,
    required this.viewInsets,
    required this.builder,
  });

  final EdgeInsetsGeometry viewInsets;
  final Widget Function(BuildContext context, EdgeInsets viewInsets) builder;

  @override
  ImplicitlyAnimatedWidgetState<AnimatedViewInsets> createState() =>
      _AnimatedViewInsetsState();
}

class _AnimatedViewInsetsState
    extends ImplicitlyAnimatedWidgetState<AnimatedViewInsets> {
  EdgeInsetsGeometryTween? _padding;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _padding = visitor(
            _padding,
            widget.viewInsets,
            (dynamic value) =>
                EdgeInsetsGeometryTween(begin: value as EdgeInsetsGeometry))
        as EdgeInsetsGeometryTween?;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _padding!.evaluate(animation).resolve(Directionality.of(context)),
    );
  }
}
