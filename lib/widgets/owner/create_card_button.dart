import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:wishlist_mobile/bloc/wishlist_bloc.dart';
import 'package:wishlist_mobile/screens/falling_style_page.dart';
import 'package:wishlist_mobile/utils/color.dart';
import 'package:wishlist_mobile/widgets/heavy_touch_button.dart';
import 'package:wishlist_mobile/widgets/owner/text_card.dart';
import 'dart:math' as math;

import 'package:wishlist_mobile/widgets/pattern_aligning_rounded_dottedG_box.dart';

import '../../screens/owner/create_card.dart';

class CreateCardButton extends StatelessWidget {
  final String userPk;
  final int wishPk;

  const CreateCardButton({
    Key? key,
    required this.userPk,
    required this.wishPk,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onBackground.blendedWithRgbInversion(0.4)!;

    return HeavyTouchButton(
      // animationDuration: Duration(milliseconds: 500),
      onAnimationEnd: () => Navigator.of(context).push(
        FallingStylePage(
          fallOffset: 0.2,
          child: CreateCardScreen(),
        ),
      ),
      child: SizedBox(
        height: 140,
        child: Hero(
          tag: 'cc',
          flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: CurvedAnimation(parent: ReverseAnimation(animation), curve: Interval(0.4, 1.0)), curve: Curves.easeInCubic),
              child: FittedBox(
                fit: BoxFit.fill,
                child: SizedBox(
                  width: (context.findRenderObject() as RenderBox).constraints.biggest.width,
                  height: 140,
                  child: PatternAligningRoundedDottedBox.fitBorderWithinConstraints(
                    color: color,
                    circularRadius: 20,
                    borderPadding: const EdgeInsets.all(3),
                    strokeWidth: 6,
                    padding: EdgeInsets.all(13),
                    approximatedDashPattern: [16, 20],
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 7, spreadRadius: 5)],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add_rounded,
                          size: 68,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            // SizedBox.expand(
            //   child: Padding(
            //     padding: const EdgeInsets.all(0),
            //     child: AnimatedBuilder(
            //       animation: animation,
            //       builder: (context, child) {
            //         final flightRenderBox = flightContext.findRenderObject() as RenderBox;
            //         final l = borderLength(flightRenderBox.constraints.biggest, 6, 20)! / bottomBorderLength;
            //         return PatternAligningRoundedDottedBox(
            //           color: color,
            //           circularRadius: 20,
            //           borderPadding: const EdgeInsets.all(3),
            //           strokeWidth: 6,
            //           padding: EdgeInsets.all(13),
            //           approximatedDashPattern: [16 * l, 20 * l],
            //           child: Opacity(
            //             opacity: 1 - animation.value,
            //             child: child,
            //           ),
            //         );
            //       },
            //       child: DecoratedBox(
            //         decoration: BoxDecoration(
            //           boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8 + animation.value * 4, spreadRadius: 6 + animation.value * 9)],
            //           borderRadius: BorderRadius.circular(20),
            //         ),
            //         child: Center(
            //           child: Icon(
            //             Icons.add_rounded,
            //             size: 68,
            //             color: color,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // );
          },
          child: PatternAligningRoundedDottedBox.fitBorderWithinConstraints(
            color: color,
            circularRadius: 20,
            borderPadding: const EdgeInsets.all(3),
            strokeWidth: 6,
            padding: EdgeInsets.all(13),
            approximatedDashPattern: [16, 20],
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 7, spreadRadius: 5)],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Icon(
                  Icons.add_rounded,
                  size: 68,
                  color: color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
