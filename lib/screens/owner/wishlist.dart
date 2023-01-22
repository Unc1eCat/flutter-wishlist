import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:wishlist_mobile/screens/owner/wish_details.dart';
import 'package:wishlist_mobile/widgets/heavy_touch_button.dart';
import 'package:wishlist_mobile/widgets/custom_child_molten_bottom_nav_bar.dart';
import 'package:wishlist_mobile/widgets/owner/list_iitem.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 100), () => showWishDetailScreen(context, 'abc', 0));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemBuilder: (context, index) => index == 0
          ? SizedBox(height: 200)
          : Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: ListItem(permanentName: "abc", wishPk: index - 1),
            ),
      itemCount: 5,
    );
  }
}
