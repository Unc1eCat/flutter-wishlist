import 'dart:async';
import 'dart:ui';
import 'dart:math';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:local_hero/local_hero.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibration/vibration.dart';
import 'package:wishlist_mobile/main.dart';
import 'package:wishlist_mobile/screens/falling_style_page.dart';
import 'package:wishlist_mobile/utils/provider.dart';
import 'package:wishlist_mobile/widgets/action_button.dart';
import 'package:wishlist_mobile/widgets/bloc_listener_state_mixin.dart';
import 'package:wishlist_mobile/widgets/heavy_touch_button.dart';
import 'package:wishlist_mobile/widgets/owner/create_card_button.dart';
import 'package:wishlist_mobile/widgets/owner/image_card.dart';
import 'package:wishlist_mobile/widgets/pinterest_grid.dart';
import 'package:wishlist_mobile/widgets/reorderable_item.dart';
import 'package:wishlist_mobile/widgets/shifted_bouncing_scroll_physics.dart';
import 'package:wishlist_mobile/widgets/shimmer_card.dart';
import 'package:wishlist_mobile/widgets/simple_card.dart';
import '../../utils/math.dart';
import '../../utils/color.dart';

import 'dart:math';
import '../../bloc/wishlist_bloc.dart';
import '../../models.dart' as m;
import '../../widgets/overscroll_closing.dart';
import '../../widgets/owner/text_card.dart';

class _GlobalWishCardKey<T extends State<StatefulWidget>> extends GlobalKey<T> {
  _GlobalWishCardKey({
    required this.userPk,
    required this.wishPk,
    required this.cardPk,
  }) : super.constructor();

  final String userPk;
  final int wishPk;
  final int cardPk;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType == runtimeType) {
      var castOther = other as _GlobalWishCardKey;
      return castOther.cardPk == cardPk && castOther.userPk == userPk && castOther.wishPk == wishPk;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(userPk, wishPk, cardPk);
}

// FIXME: The context is not rebuild when mediaquery updates
int cardColumnsCount(BuildContext context) => context.selectMediaQuery((data) => (data.size.width / 250).ceil());
double cardWidth(BuildContext context, double horizontalSpacing, double totalHorizontalPadding) {
  final cols = cardColumnsCount(context);
  return (context.selectMediaQuery((data) => (data.size.width - totalHorizontalPadding - (cols - 1) * horizontalSpacing) / cols));
}

Widget _createCardFor(String userPk, int wishPk, m.Card card, {Key? key}) {
  if (card is m.TextCard) {
    return TextCardWidget(wishPk: wishPk, userPk: userPk, cardPk: card.pk, key: key);
  } else if (card is m.ImageCard) {
    return ImageCardWidget(wishPk: wishPk, userPk: userPk, cardPk: card.pk, key: key);
  } else {
    throw TypeError();
  }
  // Later more types will be made
}
class WishDetailsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color gradientColor;
  final bool
      hasCheckedPanel; // If there is this big checked panel above the persistent header than we need to decrease the extents so that the title appears to be in the same place as it is without title

  WishDetailsHeaderDelegate({
    required this.hasCheckedPanel,
    required this.child,
    required this.gradientColor,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final ratio = shrinkOffset / maxExtent;
    return DecoratedBox(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gradientColor.withOpacity(ratio),
          gradientColor.withOpacity(ratio * 0.7),
          gradientColor.withOpacity(0.1 * pow(ratio, 2)),
          gradientColor.transparent
        ],
        stops: [0.0, ratio / 3, 0.85, 1.0],
      )),
      child: Align(
        alignment: Alignment(ratio - 1, -2 * ratio + 1),
        child: Transform.scale(scale: 0.4 * ratio + 1, child: child),
      ),
    );
  }

  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration => OverScrollHeaderStretchConfiguration();

  @override
  bool shouldRebuild(covariant WishDetailsHeaderDelegate oldDelegate) => oldDelegate.gradientColor != gradientColor || oldDelegate.maxExtent != maxExtent;

  @override
  double get maxExtent => 140;

  @override
  double get minExtent => 130;
}

class WishDetails extends StatefulWidget {
  final String userPk;
  final int wishPk;

  const WishDetails({Key? key, required this.userPk, required this.wishPk}) : super(key: key);

  @override
  State<WishDetails> createState() => WishDetailsState();
}

class WishDetailsState extends State<WishDetails> with TickerProviderStateMixin<WishDetails>, BlocListenerStateMixin<WishlistBloc, WishlistState, WishDetails> {
  static List<Widget> _generateLoadingCards() {
    Random random = Random();
    var minimumTotalHeight = 1000 + 500 * random.nextDouble();
    var currentTotalHeight = 0.0;
    var loadingCardWidgets = <Widget>[];

    while (true) {
      if (currentTotalHeight < minimumTotalHeight) {
        var height = 100 + 100 * random.nextDouble();
        loadingCardWidgets.add(ShimmerCard(height: height));
        currentTotalHeight += height;
      } else {
        break;
      }
      if (currentTotalHeight < minimumTotalHeight) {
        var height = 200 + 100 * random.nextDouble();
        loadingCardWidgets.add(ShimmerCard(height: height));
        currentTotalHeight += height;
      } else {
        break;
      }
    }

    return loadingCardWidgets;
  }

  final GlobalKey titleKey = GlobalKey();
  final GlobalKey body = GlobalKey();
  final loadingCardWidgets = _generateLoadingCards();
  final _enableTitleEditing = ValueNotifier<bool>(true);
  late final ScrollController scrollController;
  late final AnimationController _actionButtonsController;
  late final TextEditingController _titleEditingController;
  late final ReorderableItemsController cardReorderingController;

  // Listenable get willClose => _willClose;

  @override
  void initState() {
    final bloc = WishlistBloc.of(context);
    scrollController = ScrollController();
    _actionButtonsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150), value: 1);
    _titleEditingController = TextEditingController(text: bloc.wishOfUser(widget.userPk, widget.wishPk)!.title);
    cardReorderingController = ReorderableItemsController();

    super.initState();
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    cardReorderingController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  @override
  void blocHandler(WishlistBloc bloc, WishlistState state) {
    if (state is WishTitleChangedState && state.newWish.pk == widget.wishPk && state.newWish.title != _titleEditingController.text) {
      _titleEditingController.text = state.newWish.title;
    } else if (state is CardsListLengthChangedState &&
        (state as CardsListLengthChangedState).userPk == widget.userPk &&
        (state as CardsListLengthChangedState).wishPk == widget.wishPk) {}
  }

  @override
  Widget build(BuildContext context) {
    final bloc = WishlistBloc.of(context);
    final th = Theme.of(context);
    final windowTopPadding = context.selectMediaQuery((data) => data.padding.top);
    final buildModel = bloc.wishOfUser(widget.userPk, widget.wishPk)!;

    print('asdasd');

    final scrollView = CustomScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverPersistentHeader(
            delegate: WishDetailsHeaderDelegate(
              hasCheckedPanel: buildModel.isChecked,
              gradientColor: Color.lerp(th.colorScheme.onSurface.rgbInverted, Colors.black, 0.7)!,
              child: Padding(
                padding: EdgeInsets.only(top: 10 + (buildModel.isChecked ? 0 : windowTopPadding), right: 20, bottom: 10, left: 25),
                child: SingleChildClosingIndicator(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _enableTitleEditing,
                    builder: (context, value, child) {
                      print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
                      return value
                          ? TextField(
                              textCapitalization: TextCapitalization.sentences,
                              scrollPadding: EdgeInsets.zero,
                              cursorWidth: 1.5,
                              cursorRadius: Radius.circular(2),
                              decoration: InputDecoration.collapsed(border: InputBorder.none, hintText: ''),
                              controller: _titleEditingController,
                              onChanged: (value) => bloc.setTitleForWish(widget.userPk, widget.wishPk, value),
                              style: th.textTheme.titleMedium!,
                            )
                          : GestureDetector(
                              onTapUp: (_) => scrollController.animateTo(0, duration: const Duration(milliseconds: 700), curve: Curves.easeOutBack),
                              child: ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _titleEditingController,
                                builder: (context, value, child) => Text(value.text, style: th.textTheme.titleMedium!),
                              ),
                            );
                    },
                  ),
                ),
              ),
            ),
            pinned: true),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: FadeTransition(
              opacity: _actionButtonsController,
              child: SlideTransition(
                position: Tween<Offset>(begin: Offset(0, 0.5), end: Offset(0, 0)).animate(_actionButtonsController),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ActionButton(
                      onPressed: () {},
                      icon: Icons.archive_rounded,
                    ),
                    ActionButton(
                      onPressed: () {},
                      icon: Icons.delete_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: BlocBuilder<WishlistBloc, WishlistState>(
                bloc: bloc,
                buildWhen: (previous, current) =>
                    (current is CardsListLengthChangedState || current is CardMovedState) &&
                    (current as WithUserPk).userPk == widget.userPk &&
                    (current as WithWishPk).wishPk == widget.wishPk,
                builder: (context, state) {
                  var width = cardWidth(context, 8, 30);
                  final w = bloc.wishOfUser(widget.userPk, widget.wishPk)!;
                  final children = <Widget>[
                    CreateCardButton(
                      userPk: widget.userPk,
                      wishPk: widget.wishPk,
                    )
                  ];

                  for (var i = 0; i < w.cards.length; i++) {
                    final e = w.cards[i];

                    children.add(ReorderableItem<int>(
                      key: ValueKey(e.pk),
                      tag: e.pk,
                      onAccept: (data) {
                        bloc.moveCard(widget.userPk, widget.wishPk, data.itemIdentifier, i);
                      },
                      controller: cardReorderingController,
                      child: SizedBox(
                        width: width,
                        child: _createCardFor(widget.userPk, widget.wishPk, e),
                      ),
                    ));
                  }

                  return PinterestGrid(
                    crossAxisCount: cardColumnsCount(context),
                    crossAxisSpacing: 6,
                    bottomMarginOnChildren: 10,
                    children: children,
                  );
                }),
          ),
        ),
      ],
    );

    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        if (scrollController.offset > 0.1) {
          if (_actionButtonsController.status == AnimationStatus.completed || _actionButtonsController.status == AnimationStatus.forward) {
            _actionButtonsController.reverse();
            _enableTitleEditing.value = false;
          }
        } else {
          if (_actionButtonsController.status == AnimationStatus.dismissed || _actionButtonsController.status == AnimationStatus.reverse) {
            _actionButtonsController.forward();
            _enableTitleEditing.value = true;
          }
        }
        return false;
      },
      child: OverscrollClosing(
        onClosed: () {
          scrollController.position.hold(() {});
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
          final n = Navigator.of(context);
          n.pop();
          // Future.delayed(const Duration(milliseconds: 3000)).then((value) => showWishDetailScreen(n.context, 'abc', 0));
        },
        child: buildModel
                .isChecked // This data is not in a bloc builder because it changes rarely and will probably require user to explicitly request a refresh of information on the client
            ? DisarmingTopPanel(
                panelExtent: 50,
                panelOverlap: 7,
                panel: DecoratedBox(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
                      color: Colors.green[400],
                      boxShadow: [BoxShadow(color: Colors.green[400]!.hsv.withSaturationStretched(0.8).rgb.withOpacity(0.5), blurRadius: 10, spreadRadius: 5)]),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_rounded),
                          const SizedBox(width: 8),
                          Text(
                            'Someone has accepted the wish',
                            style: th.textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                body: scrollView,
              )
            : scrollView,
      ),
    );
  }
}

void showWishDetailScreen(BuildContext context, String permanentName, int wishPk) {
  Navigator.of(context).push(
    FallingStylePage(
      child: Builder(builder: (context) {
        return GestureDetector(
          onTapUp: (details) => FocusManager.instance.primaryFocus?.unfocus(),
          child: Material(
            color: Colors.transparent,
            child: WishDetails(
              wishPk: wishPk,
              userPk: permanentName,
            ),
          ),
        );
      }),
    ),
  );
}
