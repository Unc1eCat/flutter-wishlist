import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:wishlist_mobile/utils/color.dart';
import 'package:wishlist_mobile/utils/math.dart';
import 'package:wishlist_mobile/widgets/heavy_touch_button.dart';
import 'package:wishlist_mobile/widgets/simple_card.dart';

// mixin _TransitionRouteAnimationDeshadowing on TransitionRoute {
//   Animation<double>? get transitionRouteAnimation => super.animation;
// }

class ActionButtonDialogPage extends PageRoute {
  final IconData icon;
  final Color iconColor;
  final Widget body;
  final List<Widget> underBody;
  final Object tag;
  final BorderRadius dialogBorderRadius;
  final EdgeInsets dialogMargin;
  final Color? dialogColor;
  final EdgeInsets dialogPadding;
  final double dialogIconSize;
  final double dialogElevation;
  final double bodyIndent;

  ActionButtonDialogPage({
    required this.bodyIndent,
    required this.dialogBorderRadius,
    required this.dialogMargin,
    required this.dialogPadding,
    required this.dialogIconSize,
    required this.dialogElevation,
    required this.tag,
    required this.icon,
    required this.iconColor,
    required this.body,
    this.dialogColor,
    this.underBody = const [],
  });

  // late Animation<double> _curvedAnimation;

  // @override
  // Animation<double> get animation => _curvedAnimation;

  @override
  Color? get barrierColor => Colors.black54;

  @override
  bool get opaque => false;

  @override
  String? get barrierLabel => '';

  // @override
  // void install() {
  //   super.install();
  //   _curvedAnimation = CurvedAnimation(parent: transitionRouteAnimation!, curve: Curves.easeOutQuad);
  // }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final th = Theme.of(context);

    return DefaultTextStyle(
      style: th.textTheme.bodyText2!,
      child: Padding(
        padding: dialogMargin,
        child: Column(
          children: [
            Hero(
              tag: tag,
              child: SimpleCard(
                shape: RoundedRectangleBorder(borderRadius: dialogBorderRadius),
                color: dialogColor,
                elevation: dialogElevation,
                child: Padding(
                  padding: dialogPadding,
                  child: Column(
                    children: [
                      Icon(
                        icon,
                        color: iconColor,
                        size: dialogIconSize,
                      ),
                      SizedBox(height: bodyIndent),
                      body,
                    ],
                  ),
                ),
              ),
            ),
            ...underBody,
          ],
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    animation = CurvedAnimation(parent: animation, curve: Interval(0.6, 1.0));
    return SlideTransition(
      position: offsetTween(0, -0.05, 0, 0).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  @override
  bool get maintainState => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 400);
}

class DialogActionButton extends StatelessWidget {
  final Color buttonColor;
  final Color iconColor;
  final IconData icon;
  final EdgeInsets buttonPadding;
  final BorderRadius buttonBorderRadius;
  final BorderRadius dialogBorderRadius;
  final EdgeInsets dialogMargin;
  final Color? dialogColor;
  final EdgeInsets dialogPadding;
  final double dialogIconSize;
  final Widget body;
  final List<Widget> underBody;
  final Object tag;
  final double dialogElevation;
  final double bodyIndent;

  DialogActionButton({
    Key? key,
    required this.tag,
    required this.buttonColor,
    required this.icon,
    required this.body,
    this.underBody = const [],
    Color? iconColor,
    this.buttonPadding = const EdgeInsets.all(5),
    this.buttonBorderRadius = const BorderRadius.all(Radius.circular(10)),
    this.dialogBorderRadius = const BorderRadius.all(Radius.circular(30)),
    this.dialogMargin = const EdgeInsets.fromLTRB(40, 200, 40, 0),
    this.dialogPadding = const EdgeInsets.all(20),
    this.dialogIconSize = 50,
    this.dialogColor,
    this.dialogElevation = 6,
    this.bodyIndent = 20,
  })  : iconColor = iconColor ?? buttonColor.hsl.withRoundedLightness.rgb.rgbInverted,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
        final topContext = flightDirection == HeroFlightDirection.push ? toHeroContext : fromHeroContext;
        final buildDialogColor = dialogColor ?? Theme.of(context).cardColor;
        final topSize = (topContext.findRenderObject() as RenderBox).size;

        return DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyText2!,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return PhysicalModel(
                elevation: animation.value * dialogElevation,
                borderRadius: BorderRadius.lerp(buttonBorderRadius, dialogBorderRadius, animation.value)!,
                color: Color.lerp(buttonColor, buildDialogColor, pow(animation.value, 1/3).toDouble())!,
                child: Padding(
                  padding: EdgeInsets.lerp(buttonPadding, dialogPadding, animation.value)!,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Icon(
                        icon,
                        color: iconColor,
                        size: lerpDouble(24, dialogIconSize, animation.value),
                      ),
                      Positioned(
                        top: (dialogIconSize + bodyIndent) * pow(animation.value, 1.5).toDouble(),
                        child: Opacity(
                          opacity: pow(animation.value, 3).toDouble(),
                          child: SizedBox.fromSize(
                            size: topSize - Offset(dialogPadding.horizontal, 0) as Size,
                            child: body,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      child: HeavyTouchButton(
        onAnimationEnd: () => Navigator.of(context).push(ActionButtonDialogPage(
          tag: tag,
          icon: icon,
          body: body,
          iconColor: iconColor,
          underBody: underBody,
          dialogBorderRadius: dialogBorderRadius,
          dialogElevation: dialogElevation,
          dialogIconSize: dialogIconSize,
          dialogMargin: dialogMargin,
          dialogPadding: dialogPadding,
          dialogColor: dialogColor,
          bodyIndent: bodyIndent,
        )),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ColoredBox(
            color: buttonColor,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Icon(icon, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildActionButtonDialogOption(BuildContext context, String text, IconData icon, Color? color, VoidCallback onPressed) => HeavyTouchButton(
      onAnimationEnd: () => onPressed(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
            ),
            SizedBox(width: 10),
            Text(
              text,
              style: Theme.of(context).textTheme.button!.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
