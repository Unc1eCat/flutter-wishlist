import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';

const phi = 1.618033988749894848204586834;

extension DoubleUtilExtension on double {
  // https://www.desmos.com/calculator/hxbfpaolue
  double zeroStretch(double stretch, double upper) {
    assert(stretch >= 0.0 && stretch <= 2.0);

    return stretch <= 1.0 ? this * stretch : (this + (stretch - 1.0) * (upper - this));
  }

  /// Lerp this value to [a] or [b] whatever is the farthest from this value
  double farthestLerp(double amount, double a, double b) => ((this - a).abs() > (this - b).abs()) ? this + amount * (a - this) : this + amount * (b - this);

  /// Lerp this value to [a] or [b] whatever is the closest to this value
  double closestLerp(double amount, double a, double b) => ((this - a).abs() > (this - b).abs()) ? this + amount * (b - this) : this + amount * (a - this);

  double zeroOneFarthestLerp(double amount) => this <= 0.5 ? this + amount * (1.0 - this) : this - amount * this;
  double zeroOneClosestLerp(double amount) => this <= 0.5 ? this - amount * this : this + amount * (1.0 - this);

  /// Pushes the value out of the range between [from] and [to] i.e. if this is between [from] and [to] then return [from] or [to] whatever is closest to this value else return this value.
  /// 
  /// If [from] is greater than [to] than returns the value unmodified
  double reverseClamp(double from, double to) {
    final middle = (from + to) / 2;
    if (from < this && this < middle) {
      return from;
    } else if (middle <= this && this < to) {
      return to;
    } else {
      return this;
    }
  }

  /// If this value is not between [mustBeFrom] and [mustBeTo] or is between [mustNotBeFrom] and [mustNotBeTo] than snap it to the closest value that matches the constraints
  double? biclamp(double mustBeFrom, double mustBeTo, double mustNotBeFrom, double mustNotBeTo) {
    if (mustNotBeFrom < mustBeFrom && mustBeTo < mustNotBeTo) {
      return null;
    } else if (mustBeTo < mustNotBeTo) {
      // ignore: unnecessary_this
      return this.clamp(mustBeFrom, mustNotBeFrom);
    } else if (mustNotBeFrom < mustBeFrom) {
      // ignore: unnecessary_this
      return this.clamp(mustNotBeTo, mustBeTo);
    } else {
      if (this <= mustBeFrom) {
        return mustBeFrom;
      } else if (this <= mustNotBeFrom) {
        return this;
      } else if (this < mustNotBeTo) {
        return reverseClamp(mustNotBeFrom, mustNotBeTo);
      } else if (this <= mustBeTo) {
        return this;
      } else {
        return mustBeTo;
      }
    }
  }
}

Tween<Offset> offsetTween(double beginX, double beginY, double endX, double endY) => Tween(begin: Offset(beginX, beginY), end: Offset(endX, endY));
