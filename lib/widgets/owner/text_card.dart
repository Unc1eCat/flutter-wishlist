import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishlist_mobile/bloc/wishlist_bloc.dart';
import '../../utils/color.dart';

import '../../models.dart' as m;

class TextCard extends StatelessWidget {
  final int cardPk;
  final int wishPk;
  final String userPk;

  const TextCard({Key? key, required this.cardPk, required this.wishPk, required this.userPk}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var bloc = WishlistBloc.of(context);

    assert(bloc.cardOf(userPk, wishPk, cardPk) is m.TextCard, "TextCard widget was given a not text card model, the pk of the model is ${cardPk}.");

    var theme = Theme.of(context);

    final borderColor = theme.colorScheme.onSurface.withOpacity(0.025);
    final cardColor = theme.canvasColor.hsl.withClosestLerpOfLightness(0.7).rgb;

    return PhysicalModel(
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
            child: BlocBuilder<WishlistBloc, WishlistState>(
              bloc: bloc,
              buildWhen: (previous, current) => current is CardChangedState && current.newCard.pk == cardPk,
              builder: (context, state) => Text(
                (bloc.cardOf(userPk, wishPk, cardPk)! as m.TextCard).text,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
