import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:wishlist_mobile/screens/owner/wishlist.dart';

import '../../widgets/heavy_touch_button.dart';
import '../../widgets/custom_child_molten_bottom_nav_bar.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({Key? key}) : super(key: key);

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              WishlistScreen(),
              Container(
                color: Colors.blueGrey,
                height: double.infinity,
                width: double.infinity,
              ),
              SizedBox(),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: CustomChildMoltenBottomNavigationBar(
                borderRadius: BorderRadius.circular(kBottomNavigationBarHeight / 2),
                curve: Curves.easeOutSine,
                sidePadding: 40,
                domeCircleColor: Colors.transparent,
                barWidth: MediaQuery.of(context).size.width - 100,
                controller: _tabController,
                domeHeight: 15,
                tabs: [
                  IconMoltenTab(icon: Icons.star_rounded),
                  IconMoltenTab(icon: Icons.waving_hand_outlined),
                  IconMoltenTab(icon: Icons.person_outline_rounded),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
