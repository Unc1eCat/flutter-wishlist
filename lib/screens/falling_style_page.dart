import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wishlist_mobile/screens/delay_page_transition.dart';

import '../utils/math.dart';
import '../widgets/ancestor_route.dart';
import '../widgets/overscroll_closing.dart';

class FallingStylePage<T> extends PageRoute<T> {
  final Widget child;
  final double fallOffset;

  late final CurvedAnimation transitionAnimation;

  FallingStylePage({
    required this.child,
    RouteSettings? settings,
    this.fallOffset = 0.6,
  }) : super(fullscreenDialog: false, settings: settings);

  @override
  void install() {
    super.install();
    transitionAnimation = CurvedAnimation(parent: animation!, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    transitionAnimation.dispose();
    super.dispose();
  }

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
    return AncestorRoute(
      route: this,
      child: child,
    );
  }

  // @override
  // Animation<double> createAnimation() {
  //   return CurvedAnimation(parent: super.createAnimation(), curve: Curves.easeOutCubic);
  // }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: offsetTween(0, fallOffset, 0.0, 0.0).animate(transitionAnimation),
      child: FadeTransition(
        opacity: transitionAnimation,
        child: child,
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 600);
}
