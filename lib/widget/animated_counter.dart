import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../style.dart';

class AnimatedCount extends ImplicitlyAnimatedWidget {
  final int? count;
  final TextStyle textStyle;

  AnimatedCount(
      {Key? key,
      required this.count,
      required Duration duration,
      required this.textStyle,
      Curve curve = Curves.linear})
      : super(duration: duration, curve: curve, key: key);

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() =>
      _AnimatedCountState();
}

class _AnimatedCountState extends AnimatedWidgetBaseState<AnimatedCount> {
  IntTween? _count;

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      _count!.evaluate(animation).toString(),
      maxLines: 1,
      minFontSize: 12,
      overflow: TextOverflow.ellipsis,
      style: widget.textStyle,
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _count = visitor(_count, widget.count!,
        (dynamic value) => new IntTween(begin: value)) as IntTween?;
  }
}
