import 'dart:math';

import 'package:flutter/widgets.dart';

class ShiftedBouncingScrollPhysics extends BouncingScrollPhysics {
  final double minExtentShift;
  final double maxExtentShift;

  ShiftedBouncingScrollPhysics(this.minExtentShift, this.maxExtentShift, {super.parent});

  ScrollMetrics applyShiftToPosition(ScrollMetrics position) {
    final newMinScrollExtent = position.minScrollExtent + minExtentShift;
    final newMaxScrollExtent = position.maxScrollExtent + maxExtentShift;
    return position.copyWith(minScrollExtent: min(newMinScrollExtent, newMaxScrollExtent), maxScrollExtent: newMaxScrollExtent);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // if (value < position.pixels && position.pixels <= position.minScrollExtent) {
    //   return value - position.pixels;
    // }
    // if (value < position.minScrollExtent && position.minScrollExtent < position.pixels) {
    //   return value - position.minScrollExtent;
    // }
    return 0.0;
  }

  @override
  ShiftedBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) => ShiftedBouncingScrollPhysics(minExtentShift, maxExtentShift, parent: buildParent(parent));

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return super.applyPhysicsToUserOffset(applyShiftToPosition(position), offset);
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    return super.createBallisticSimulation(applyShiftToPosition(position), velocity);
  }
}
