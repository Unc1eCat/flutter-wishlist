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
import 'package:shimmer/shimmer.dart';
import 'package:vibration/vibration.dart';
import 'package:wishlist_mobile/main.dart';
import 'package:wishlist_mobile/screens/falling_style_page.dart';
import 'package:wishlist_mobile/widgets/bloc_listener_state_mixin.dart';
import 'package:wishlist_mobile/widgets/heavy_touch_button.dart';
import 'package:wishlist_mobile/widgets/owner/image_card.dart';
import 'package:wishlist_mobile/widgets/pinterest_grid.dart';
import 'package:wishlist_mobile/widgets/reorderable_item.dart';
import 'package:wishlist_mobile/widgets/shifted_bouncing_scroll_physics.dart';
import 'package:wishlist_mobile/widgets/shimmer_card.dart';
import '../../utils/math.dart';
import '../../utils/color.dart';

import 'dart:math';
import '../../bloc/wishlist_bloc.dart';
import '../../models.dart' as m;
import '../overscroll_closing.dart';
import 'text_card.dart';

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

int get _cardCrossAxisCount => (WidgetsBinding.instance.window.physicalSize.width / WidgetsBinding.instance.window.devicePixelRatio / 170).floor();

Widget _createCardFor(String userPk, int wishPk, m.Card card, {Key? key}) {
  if (card is m.TextCard) {
    return TextCard(wishPk: wishPk, userPk: userPk, cardPk: card.pk, key: key);
  } else if (card is m.ImageCard) {
    return ImageCard(wishPk: wishPk, userPk: userPk, cardPk: card.pk, key: key);
  } else {
    throw TypeError();
  }
  // Later more types will be made
}

Widget _buildActionButton({
  required VoidCallback onPressed,
  required Color color,
  required IconData icon,
  String tooltip = '',
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 15.0),
    child: Tooltip(
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.all(10.0),
      message: tooltip,
      child: HeavyTouchButton(
        onPressed: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: color),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Icon(icon),
          ),
        ),
      ),
    ),
  );
}

class WishDetailsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color gradientColor;

  WishDetailsHeaderDelegate({required this.child, required this.gradientColor});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    var ratio = shrinkOffset / maxExtent;
    return DecoratedBox(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gradientColor.withOpacity(ratio * 0.9),
          gradientColor.withOpacity(ratio * 0.8),
          gradientColor.withOpacity(0.07 * pow(ratio, 5)),
          gradientColor.transparent
        ],
        stops: [0.0, ratio / 3, 0.8, 1.0],
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
  double get maxExtent => 150;

  @override
  double get minExtent => 120;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
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
  final _willClose = ValueNotifier<bool>(false);
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
    _willClose.addListener(() {
      if (_willClose.value) {
        Vibration.vibrate(duration: 70);
      } else {}
    });

    super.initState();
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    _willClose.dispose();
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
    var bloc = WishlistBloc.of(context);
    final cardExtent = (MediaQuery.of(context).size.width - 30 - (_cardCrossAxisCount - 1) * 10) / _cardCrossAxisCount;

    print('asdasd');

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
          Future.delayed(const Duration(milliseconds: 3000)).then((value) => showWishDetailScreen(n.context, 'abc', 0));
        },
        child: CustomScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverPersistentHeader(
                delegate: WishDetailsHeaderDelegate(
                  gradientColor: Color.lerp(Theme.of(context).colorScheme.onSurface.rgbInverted, Colors.black, 0.7)!,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 10 + MediaQuery.of(context).viewPadding.top,
                      right: 20,
                      bottom: 10,
                      left: 25,
                    ),
                    child: ClosingIndicator(
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _enableTitleEditing,
                        builder: (context, value, child) {
                          print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
                          return value
                              ? TextField(
                                  scrollPadding: EdgeInsets.zero,
                                  decoration: InputDecoration.collapsed(border: InputBorder.none, hintText: ''),
                                  controller: _titleEditingController,
                                  onChanged: (value) => bloc.setTitleForWish(widget.userPk, widget.wishPk, value),
                                  cursorRadius: Radius.circular(2),
                                  style: Theme.of(context).textTheme.titleMedium!,
                                )
                              : GestureDetector(
                                  onTapUp: (_) => scrollController.animateTo(0, duration: const Duration(milliseconds: 700), curve: Curves.easeOutBack),
                                  child: ValueListenableBuilder<TextEditingValue>(
                                    valueListenable: _titleEditingController,
                                    builder: (context, value, child) => Text(value.text, style: Theme.of(context).textTheme.titleMedium!),
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
                        _buildActionButton(
                          onPressed: () {},
                          color: Colors.indigo.shade400,
                          icon: Icons.archive_rounded,
                          tooltip: 'Archive',
                        ),
                        _buildActionButton(
                          onPressed: () {},
                          color: Colors.red.shade400,
                          icon: Icons.delete_rounded,
                          tooltip: 'Delete',
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: HeavyTouchButton(
                            onPressed: () {},
                            child: DecoratedBox(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.purple.shade400),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(children: [
                                  const Icon(Icons.add_box_rounded),
                                  Text('  ADD NEW CARD!', style: Theme.of(context).textTheme.button),
                                ]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: BlocBuilder<WishlistBloc, WishlistState>(
                      bloc: bloc,
                      buildWhen: (previous, current) =>
                          (current is CardsListLengthChangedState || current is CardMovedState) &&
                          (current as WithUserPk).userPk == widget.userPk &&
                          (current as WithWishPk).wishPk == widget.wishPk,
                      builder: (context, state) {
                        final w = bloc.wishOfUser(widget.userPk, widget.wishPk)!;
                        final children = <Widget>[];
                        for (var i = 0; i < w.cards.length; i++) {
                          final e = w.cards[i];
                          children.add(ReorderableItem<int>(
                            key: ValueKey(e.pk),
                            tag: e.pk,
                            onAccept: (data) {
                              bloc.moveCard(widget.userPk, widget.wishPk, data.itemIdentifier, i);
                            },
                            controller: cardReorderingController,
                            child: SizedBox(width: cardExtent, child: _createCardFor(widget.userPk, widget.wishPk, e)),
                          ));
                        }
                        return PinterestGrid(
                          crossAxisCount: _cardCrossAxisCount,
                          crossAxisSpacing: 10,
                          bottomMarginOnChildren: 16,
                          children: children,
                        );
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showWishDetailScreen(BuildContext context, String permanentName, int wishPk) {
  Navigator.of(context).push(
    FallingStylePage(
      child: GestureDetector(
        onTapUp: (details) => FocusManager.instance.primaryFocus?.unfocus(),
        child: Material(
          color: Colors.transparent,
          child: WishDetails(
            wishPk: wishPk,
            userPk: permanentName,
          ),
        ),
      ),
    ),
  );
}
