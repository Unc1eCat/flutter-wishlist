import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class SimpleCard extends StatelessWidget {
  final Widget child;
  final ShapeBorder? shape;
  final Color? color;
  const SimpleCard({
    Key? key,
    required this.child,
    this.color,
    this.shape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CardTheme th = CardTheme.of(context);
    final theme = Theme.of(context);
    final shp = shape ?? th.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));

    return Semantics(
      container: true,
      child: PhysicalShape(
        clipper: ShapeBorderClipper(shape: shp),
        color: color ?? th.color ?? theme.cardColor,
        clipBehavior: th.clipBehavior ?? Clip.none,
        elevation: th.elevation ?? 4,
        shadowColor: color == null ? th.shadowColor ?? theme.shadowColor : Color.lerp(color, th.shadowColor ?? theme.shadowColor, 0.4)!,
        child: _ShapeBorderPaint(
          shape: shp,
          child: child,
        ),
      ),
    );
  }
}

class _ShapeBorderPaint extends StatelessWidget {
  const _ShapeBorderPaint({
    required this.child,
    required this.shape,
  });

  final Widget child;
  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _ShapeBorderPainter(shape, Directionality.maybeOf(context)),
      child: child,
    );
  }
}

class _ShapeBorderPainter extends CustomPainter {
  _ShapeBorderPainter(this.border, this.textDirection);
  final ShapeBorder border;
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    border.paint(canvas, Offset.zero & size, textDirection: textDirection);
  }

  @override
  bool shouldRepaint(_ShapeBorderPainter oldDelegate) {
    return oldDelegate.border != border;
  }
}
