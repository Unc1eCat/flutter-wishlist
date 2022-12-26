import 'package:flutter/cupertino.dart';
import 'package:flutter/src/animation/animation_controller.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/ticker_provider.dart';
import 'package:wishlist_mobile/utils/math.dart';

// TODO: Finish this. It appears at the top of the screen when a card is dragged when the card is released over it, the card gets deleted
class CardDeletion extends StatefulWidget {
  const CardDeletion({Key? key}) : super(key: key);

  @override
  State<CardDeletion> createState() => _CardDeletionState();
}

class _CardDeletionState extends State<CardDeletion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    slideAnimation = offsetTween(0.0, -1.0, 0.0, 0.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(top: 40), );
  }
}