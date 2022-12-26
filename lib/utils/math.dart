import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';

extension DoubleUtilExtension on double {
  // https://www.desmos.com/calculator/hxbfpaolue
  double zeroStretch(double stretch, double upper) {
    assert(stretch >= 0.0 && stretch <= 2.0);

    return stretch <= 1.0 ? this * stretch : (this + (stretch - 1.0) * (upper - this));
  }

  double farthestLerp(double amount, double a, double b) => ((this - a).abs() > (this - b).abs()) ? this + amount * (a - this) : this + amount * (b - this);
  double closestLerp(double amount, double a, double b) => ((this - a).abs() > (this - b).abs()) ? this + amount * (b - this) : this + amount * (a - this);
  double zeroOneFarthestLerp(double amount) => this <= 0.5 ? this + amount * (1.0 - this) : this - amount * this;
  double zeroOneClosestLerp(double amount) => this <= 0.5 ? this - amount * this : this + amount * (1.0 - this);
}

Tween<Offset> offsetTween(double beginX, double beginY, double endX, double endY) => Tween(begin: Offset(beginX, beginY), end: Offset(endX, endY));

