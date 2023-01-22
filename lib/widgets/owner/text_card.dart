import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scale_button/scale_button.dart';
import 'package:wishlist_mobile/bloc/wishlist_bloc.dart';
import 'package:wishlist_mobile/screens/falling_style_page.dart';
import 'package:wishlist_mobile/widgets/heavy_touch_button.dart';
import '../../screens/owner/text_card_details.dart';
import '../../utils/color.dart';

import '../../models.dart' as m;
import '../../utils/math.dart';

Widget buildCardForTextCard(
  BuildContext context,
  Widget? child, {
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(20)),
  double scale = 1.0,
}) {
  var theme = Theme.of(context);
  final borderColor = theme.colorScheme.onBackground.withOpacity(0.02);
  final cardColor = theme.canvasColor.hsl.withClosestLerpOfLightness(0.7).rgb;

  return PhysicalModel(
    borderRadius: borderRadius,
    elevation: 4,
    color: cardColor,
    child: Padding(
      padding: EdgeInsets.all(scale * 4.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius - BorderRadius.circular(scale * 6.0),
          color: cardColor,
          border: Border.all(color: borderColor, width: pow(scale, 1/2) * 4),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 10, top: 15, bottom: 15) * pow(scale, 1/3).toDouble(),
          child: child,
        ),
      ),
    ),
  );
}

Widget _buildFlightShuttle(BuildContext flightContext, Animation<double> animation, HeroFlightDirection flightDirection, BuildContext fromHeroContext,
    BuildContext toHeroContext, String userPk, int wishPk, int cardPk) {
  var bottomRouteSize = (fromHeroContext.findRenderObject() as RenderBox).size;
  var topRouteSize = (toHeroContext.findRenderObject() as RenderBox).size;

  if (flightDirection == HeroFlightDirection.pop) {
    final t = bottomRouteSize;
    bottomRouteSize = topRouteSize;
    topRouteSize = t;
  }

  var th = Theme.of(flightContext);
  var bloc = WishlistBloc.of(flightContext);

  return buildCardForTextCard(
    flightContext,
    Stack(
      children: [
        FittedBox(
          // Card details card replica
          fit: BoxFit.scaleDown,
          child: FadeTransition(
            opacity: CurvedAnimation(curve: Interval(0.1, 1.0), parent: (animation)),
            child: SizedBox(
              // The total padding that [buildCardForTextCard] adds to its child
              width: topRouteSize.width - 34,
              height: topRouteSize.height - 38,
              child: Text(
                (bloc.cardOf(userPk, wishPk, cardPk)! as m.TextCard).text,
                style: th.textTheme.bodyMedium,
              ),
            ),
          ),
        ),
        FittedBox(
          // Wish details card replica
          fit: BoxFit.scaleDown,
          child: FadeTransition(
            opacity: CurvedAnimation(curve: Interval(0.1, 1.0), parent: ReverseAnimation(animation)),
            child: SizedBox(
              // The total padding that [buildCardForTextCard] adds to its child
              width: bottomRouteSize.width - 34,
              height: bottomRouteSize.height - 38,
              child: Text(
                (bloc.cardOf(userPk, wishPk, cardPk)! as m.TextCard).text,
                style: th.textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// The name is suffixed with "Widget" in order to avoid clash with eponymous model class
class TextCardWidget extends StatelessWidget {
  final int cardPk;
  final int wishPk;
  final String userPk;

  const TextCardWidget({Key? key, required this.cardPk, required this.wishPk, required this.userPk}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var bloc = WishlistBloc.of(context);

    assert(bloc.cardOf(userPk, wishPk, cardPk) is m.TextCard, "TextCard widget was given a not text card model, the pk of the model is $cardPk.");

    return HeavyTouchButton(
      animationDuration: const Duration(milliseconds: 120),
      onAnimationEnd: () => Navigator.of(context).push(FallingStylePage(
        fallOffset: 0.1,
        child: TextCardDetails(userPk: userPk, wishPk: wishPk, cardPk: cardPk),
      )),
      child: Hero(
        tag: '${cardPk}tc',
        flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) =>
            _buildFlightShuttle(flightContext, animation, flightDirection, fromHeroContext, toHeroContext, userPk, wishPk, cardPk),
        child: buildCardForTextCard(
          context,
          BlocBuilder<WishlistBloc, WishlistState>(
            bloc: bloc,
            buildWhen: (previous, current) => current is CardChangedState && current.newCard.pk == cardPk,
            builder: (context, state) => Text(
              (bloc.cardOf(userPk, wishPk, cardPk)! as m.TextCard).text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}

class TextCardMiniature extends StatelessWidget {
  const TextCardMiniature({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildCardForTextCard(
      context,
      CustomPaint(
        foregroundPainter: _TextCardMiniaturePainter(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        child: const SizedBox.expand(),
      ),
      borderRadius: BorderRadius.circular(10),
      scale: 0.6,
    );
  }
}

class _TextCardMiniaturePainter extends CustomPainter {
  final Color color;
  final EdgeInsets padding;

  final Paint defaultPaint;

  _TextCardMiniaturePainter({required this.color, this.padding = const EdgeInsets.fromLTRB(0, 0, 2, 0)})
      : defaultPaint = Paint()
          ..color = color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    var d = 0.0;
    size = padding.deflateSize(size);

    while (d < size.height / 2.3) {
      canvas.drawLine(Offset(padding.left, padding.bottom + d), Offset(size.width - padding.right, padding.bottom + d), defaultPaint);
      d += 7;
    }
    canvas.drawLine(Offset(padding.left, padding.bottom + d), Offset(0.6 * size.width, padding.bottom + d), defaultPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
