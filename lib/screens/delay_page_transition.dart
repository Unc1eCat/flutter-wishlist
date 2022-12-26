import 'package:flutter/widgets.dart';

// Does not work

// As of my beliefs, keeping the page widget fully faded out for a short time right after the page is pushed helps make the animation more smooth. Because 
// when the page is pushed its widget is first-built, this takes some time and creates a lag spike, and if you have an animation running at the same time
// then the transition is gonna be laggy.
// mixin DelayTransitionAnimationMixin<T> on TransitionRoute<T> {
//   @protected
//   Duration get transitionStartDelay => const Duration(milliseconds: 90);

//   @override
//   Animation<double> createAnimation() {
//     final begin = transitionStartDelay.inMicroseconds / controller!.duration!.inMicroseconds;
//     assert(begin >= 0.0 && begin <= 1.0, 'The transition delay is too big or too small. It does not fit the bounds.');
//     return CurvedAnimation(parent: super.createAnimation(), curve: Interval(controller!.duration!.inMicroseconds / transitionStartDelay.inMicroseconds, 1.0));
//   }
// }
