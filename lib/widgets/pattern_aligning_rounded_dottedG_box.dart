import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

double? borderLength(Size size, double strokeWidth, double circularRadius) {
  if (size.width >= circularRadius * 2 && size.height >= circularRadius * 2) {
    return size.width * 2 + size.height * 2 - circularRadius * 8 + 2 * math.pi * circularRadius;
  } else {
    return null;
  }
}

/// A [DottedBorder] that stretches the pattern length automatically so that it repeats a whole number of times.
///
/// Limitations:
///
/// - Only rounded rect is supported.
///
/// - Only circular radius is supported
///
/// - The widget occupies as much space as the parent allows
// TODO: Get rid of limitations
class PatternAligningRoundedDottedBox extends StatelessWidget {
  final Widget? child;
  final Color color;
  final double circularRadius;
  final double strokeWidth;
  final EdgeInsets padding;
  final EdgeInsets borderPadding;
  final StrokeCap strokeCap;
  final Iterable<double> approximatedDashPattern;

  PatternAligningRoundedDottedBox({
    this.child,
    this.color = Colors.black,
    this.circularRadius = 0,
    this.strokeWidth = 1,
    this.padding = const EdgeInsets.all(2),
    this.strokeCap = StrokeCap.round,
    this.approximatedDashPattern = const <double>[3, 1],
    Key? key,
    this.borderPadding = EdgeInsets.zero,
  })  : assert(approximatedDashPattern.length > 1 && approximatedDashPattern.any((e) => e > 0)),
        super(key: key);

  factory PatternAligningRoundedDottedBox.fitBorderWithinConstraints({
    Widget? child,
    Color color = Colors.black,
    double circularRadius = 0,
    double strokeWidth = 1,
    EdgeInsets padding = const EdgeInsets.all(2),
    StrokeCap strokeCap = StrokeCap.round,
    Iterable<double> approximatedDashPattern = const <double>[3, 1],
    Key? key,
    EdgeInsets borderPadding = EdgeInsets.zero,
  }) {
    var additionalPadding = EdgeInsets.all(strokeWidth / 2);
    return PatternAligningRoundedDottedBox(
      child: child,
      color: color,
      circularRadius: (circularRadius - strokeWidth / 2).clamp(0.0, double.infinity),
      strokeWidth: strokeWidth,
      padding: padding,
      borderPadding: borderPadding + additionalPadding,
      strokeCap: strokeCap,
      approximatedDashPattern: approximatedDashPattern,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = borderPadding.deflateSize(constraints.biggest);

        var patternScaling = 1.0;

        if (size.width >= circularRadius * 2 && size.height >= circularRadius * 2) {
          final borderLength = size.width * 2 + size.height * 2 - circularRadius * 8 + 2 * math.pi * circularRadius;

          assert(borderLength > 0);

          final patternLength = approximatedDashPattern.fold<double>(0, (v, e) => v + e);
          var closestPatternRepeatsAmount = (borderLength / patternLength).round();
          if (closestPatternRepeatsAmount == 0) {
            closestPatternRepeatsAmount = (borderLength / patternLength).ceil();
          }
          patternScaling = borderLength / closestPatternRepeatsAmount / patternLength;
        }

        return DottedBorder(
          padding: padding,
          borderPadding: borderPadding,
          color: color,
          radius: Radius.circular(circularRadius), // I would allow for any radius if I knew ellipse perimeter formula
          strokeWidth: strokeWidth,
          borderType: BorderType.RRect,
          strokeCap: strokeCap,
          dashPattern: approximatedDashPattern.map((e) => e * patternScaling).toList(),
          child: SizedBox.expand(child: child),
        );
      },
    );
  }
}
