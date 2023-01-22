import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:wishlist_mobile/utils/color.dart';
import 'package:wishlist_mobile/utils/math.dart';
import 'package:wishlist_mobile/widgets/heavy_touch_button.dart';
import 'package:wishlist_mobile/widgets/overscroll_closing.dart';
import 'dart:math';

import 'package:wishlist_mobile/widgets/owner/text_card.dart';

class CreateCardScreen extends StatefulWidget {
  const CreateCardScreen({Key? key}) : super(key: key);

  @override
  State<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends State<CreateCardScreen> {
  late final ScrollController scrollController;

  @override
  void initState() {
    scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onBg = Theme.of(context).colorScheme.onBackground;

    return OverscrollClosing(
      onClosed: () {
        scrollController.position.hold(() {});
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Stack(
          children: [
            const Positioned(
              left: 0,
              right: 0,
              top: 280,
              bottom: 0,
              child: Hero(
                tag: 'cc',
                child: SizedBox.expand(),
              ),
            ),
            CustomScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(height: 250),
                ),
                SliverToBoxAdapter(
                  child: ClosingIndicator(),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 25),
                ),
                SliverGrid.extent(
                  // shrinkWrap: true,
                  maxCrossAxisExtent: 100,
                  crossAxisSpacing: 40,
                  mainAxisSpacing: 50,
                  childAspectRatio: 1 / phi,
                  children: [
                    HeavyTouchButton(
                      onAnimationEnd: () => 1,
                      child: Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: Transform.rotate(
                                angle: pi / 15,
                                child: SizedBox(
                                  width: 100 / phi,
                                  height: 100,
                                  child: TextCardMiniature(),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Text',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
