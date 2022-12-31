import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../bloc/wishlist_bloc.dart';
import '../../utils/color.dart';
import '../shimmer_card.dart';
import '../../models.dart' as m;

// TODO: Beautiful aniamtion on when the text card is removed or added during edit 
// The name is suffixed with "Widget" in order to avoid clash with eponymous model class
class ImageCardWidget extends StatelessWidget {
  final String userPk;
  final int wishPk;
  final int cardPk;

  ImageCardWidget({Key? key, required this.cardPk, required this.wishPk, required this.userPk}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.onSurface.withOpacity(0.025);
    final cardColor = theme.canvasColor.hsl.withClosestLerpOfLightness(0.7).rgb;
    final text = (WishlistBloc.of(context).cardOf(userPk, wishPk, cardPk) as m.ImageCard).text;

    final imageChild = PhysicalModel(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          child: AnimatedSize(
            duration: Duration(milliseconds: 400),
            alignment: Alignment.topCenter,
            child: Image(
              image: (WishlistBloc.of(context).cardOf(userPk, wishPk, cardPk) as m.ImageCard).image,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) => AnimatedSwitcher(
                duration: Duration(milliseconds: 400),
                child: frame == null ? SizedBox(width: double.infinity, child: ShimmerCard(height: 200)) : child,
              ),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );

    if (text == null) {
      return imageChild;
    }

    final textChild = PhysicalModel(
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(7.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: cardColor,
            border: Border.all(color: borderColor, width: 3),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 5, top: 26, bottom: 25),
            child: Text(
              (WishlistBloc.of(context).cardOf(userPk, wishPk, cardPk) as m.ImageCard).text!,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: (WishlistBloc.of(context).cardOf(userPk, wishPk, cardPk) as m.ImageCard).textPosition == m.CardRelativePosition.above
          ? <Widget>[
              textChild,
              const SizedBox(height: 10),
              imageChild,
            ]
          : <Widget>[
              imageChild,
              const SizedBox(height: 10),
              textChild,
            ],
    );
  }
}
