import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wishlist_mobile/screens/delay_page_transition.dart';

import '../utils/math.dart';
import '../widgets/overscroll_closing.dart';

class FallingStylePage<T> extends PageRoute<T> {
  final Widget child;

  FallingStylePage({
    required this.child,
    RouteSettings? settings,
  }) : super(fullscreenDialog: false, settings: settings);

  @override
  Color? get barrierColor => Colors.black54;

  @override
  bool get opaque => false;

  @override
  ImageFilter get filter => ImageFilter.blur(sigmaX: 3, sigmaY: 3);

  @override
  String? get barrierLabel => "";

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  Animation<double> createAnimation() {
    return CurvedAnimation(parent: super.createAnimation(), curve: Curves.easeOutCubic) ;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: offsetTween(0, 0.6, 0.0, 0.0).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  @override
  bool get maintainState => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);
}
