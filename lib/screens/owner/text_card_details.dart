import 'package:bloc/src/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:wishlist_mobile/bloc/wishlist_bloc.dart';
import 'package:wishlist_mobile/models.dart';
import 'package:wishlist_mobile/utils/color.dart';
import 'package:wishlist_mobile/utils/math.dart';
import 'package:wishlist_mobile/widgets/bloc_listener_state_mixin.dart';
import 'package:wishlist_mobile/widgets/overscroll_closing.dart';
import 'package:wishlist_mobile/widgets/owner/text_card.dart' show buildCardForTextCard;
import 'package:wishlist_mobile/widgets/owner/wish_details.dart';

class TextCardDetails extends StatefulWidget {
  final String userPk;
  final int wishPk;
  final int cardPk;

  const TextCardDetails({
    Key? key,
    required this.userPk,
    required this.wishPk,
    required this.cardPk,
  }) : super(key: key);

  @override
  State<TextCardDetails> createState() => _TextCardDetailsState();
}

class _TextCardDetailsState extends State<TextCardDetails> with TickerProviderStateMixin, BlocListenerStateMixin<WishlistBloc, WishlistState, TextCardDetails> {
  late final TextEditingController _textEditingController;
  late final AnimationController _actionButtonsAnimationController;
  late final Animation<Offset> _actionButtonsAnimation;
  late final ScrollController _scrollController;

  @override
  void initState() {
    final model = bloc.cardOf(widget.userPk, widget.wishPk, widget.cardPk) as TextCard;
    _textEditingController = TextEditingController(text: model.text);
    _actionButtonsAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150), value: 1);
    _actionButtonsAnimation = Tween<Offset>(begin: Offset(0, 0.5), end: Offset(0, 0)).animate(_actionButtonsAnimationController);
    _scrollController = ScrollController()..addListener(_handleScroll);

    super.initState();
  }

  @override
  void dispose() {
    _actionButtonsAnimationController.dispose();
    _scrollController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void blocHandler(WishlistBloc bloc, WishlistState state) {
    if (state is CardChangedState<TextCard> &&
        state.cardPk == widget.cardPk &&
        state.userPk == widget.userPk &&
        state.wishPk == widget.wishPk &&
        _textEditingController.text != state.newCard.text) {
      _textEditingController.text = state.newCard.text;
    }
  }

  void _handleScroll() {
    if (_scrollController.offset > 0.1) {
      if (_actionButtonsAnimationController.status == AnimationStatus.completed || _actionButtonsAnimationController.status == AnimationStatus.forward) {
        _actionButtonsAnimationController.reverse();
      }
    } else {
      if (_actionButtonsAnimationController.status == AnimationStatus.dismissed || _actionButtonsAnimationController.status == AnimationStatus.reverse) {
        _actionButtonsAnimationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    final borderColor = theme.colorScheme.onSurface.withOpacity(0.025);
    final cardColor = theme.canvasColor.hsl.withClosestLerpOfLightness(0.7).rgb;

    return GestureDetector(
      onTapUp: (details) => FocusManager.instance.primaryFocus?.unfocus(),
      child: Material(
        type: MaterialType.transparency,
        child: OverscrollClosing(
          onClosed: () {
            _scrollController.position.hold(() {});
            Navigator.of(context).pop();
          },
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            controller: _scrollController,
            child: Column(
              children: [
                SizedBox(height: 200),
                ClosingIndicator(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(50, 0, 50, 15),
                  child: FadeTransition(
                    opacity: _actionButtonsAnimationController,
                    child: SlideTransition(
                      position: _actionButtonsAnimation,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildActionButton(
                            onPressed: () {},
                            color: Colors.red.shade400,
                            icon: Icons.delete_rounded,
                          ),
                          buildActionButton(
                            onPressed: () {},
                            color: Colors.amber[600]!,
                            icon: Icons.copy_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 300),
                    child: Hero(
                      tag: '${widget.cardPk}tc',
                      child: buildCardForTextCard(
                        context,
                        TextField(
                          textCapitalization: TextCapitalization.sentences,
                          scrollPadding: EdgeInsets.zero,
                          maxLines: null,
                          decoration: InputDecoration.collapsed(
                            border: InputBorder.none,
                            hintText: 'I want it to...',
                            hintStyle: Theme.of(context).textTheme.button,
                          ),
                          onChanged: (value) => bloc.setTextCard(widget.userPk, widget.wishPk, widget.cardPk,
                              bloc.cardOf<TextCard>(widget.userPk, widget.wishPk, widget.cardPk)!.copyWith(text: value)),
                          cursorRadius: Radius.circular(2),
                          controller: _textEditingController,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
