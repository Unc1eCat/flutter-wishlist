import 'package:flutter/material.dart';

class HeavyTouchButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onTapUp;
  final VoidCallback? onLongPress;
  final Duration animationDuration;
  final Alignment scaleAlignment;
  final VoidCallback? onAnimationEnd;

  /// Scale when the button is pressed. Unpressed is 1.0
  final double pressedScale;

  /// Whether to trigger full animation even on short press
  final bool fullAnimation;

  const HeavyTouchButton({
    required this.child,
    this.animationDuration = const Duration(milliseconds: 100),
    this.onPressed,
    Key? key,
    this.pressedScale = 0.85,
    this.fullAnimation = true,
    this.scaleAlignment = Alignment.center,
    this.onLongPress,
    this.onTapUp,
    this.onAnimationEnd,
  }) : super(key: key);

  @override
  _HeavyTouchButtonState createState() => _HeavyTouchButtonState();
}

class _HeavyTouchButtonState extends State<HeavyTouchButton> with TickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    _anim = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      lowerBound: widget.pressedScale,
      value: 1.0,
    );

    super.initState();
  }

  @override
  void dispose() {
    _anim.dispose();

    super.dispose();
  }

  void _onTapUp(AnimationStatus status) {
    if (!_anim.isAnimating && _anim.value <= widget.pressedScale) {
      _anim.removeStatusListener(_onTapUp);
      _anim.forward().then((value) => widget.onAnimationEnd?.call());
      // Future.delayed(widget.animationDuration).then((value) => widget.onAnimationEnd?.call());
      widget.onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _anim.reverse(),
      onTapCancel: () => _anim.forward(),
      // onLongPressStart: widget.onLongPress == null ? null : (_) => widget.onLongPress?.call(),
      // onLongPressEnd: widget.onUp == null ? null : (_) => widget.onUp?.call(),
      onTapUp: (_) {
        widget.onTapUp?.call();
        if (widget.fullAnimation) {
          if (!_anim.isAnimating && _anim.value <= widget.pressedScale) {
            _anim.forward().then((value) {
              widget.onAnimationEnd?.call();
            });
            widget.onPressed?.call();
          } else {
            _anim.addStatusListener(_onTapUp);
          }
        } else {
          _anim.forward().then((value) => widget.onAnimationEnd?.call());
          // Future.delayed(widget.animationDuration).then((value) => widget.onAnimationEnd?.call());
          widget.onPressed?.call();
        }
      },
      child: ScaleTransition(
        alignment: widget.scaleAlignment,
        scale: _anim,
        child: DefaultTextStyle(
          child: widget.child,
          style: Theme.of(context).textTheme.button ?? context.dependOnInheritedWidgetOfExactType<DefaultTextStyle>()!.style,
        ),
      ),
    );
  }
}
// TODO: COMPLETE IT!! ITS VERY BEAUTIFUL. MAKE IT WORK ON RENDERING LAYER
