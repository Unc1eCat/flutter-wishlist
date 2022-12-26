import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCard extends StatelessWidget {
  final double height;
  final BorderRadius borderRadius;

  const ShimmerCard({
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Shimmer(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.centerRight, colors: <Color>[
          Colors.grey.shade600,
          Colors.grey.shade500,
          Colors.grey.shade600,
        ], stops: const <double>[
          0.3,
          0.5,
          0.7
        ]),
        child: ColoredBox(
          color: Colors.grey.shade400,
          child: SizedBox(height: height),
        ),
      ),
    );
  }
}
