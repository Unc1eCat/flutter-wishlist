import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibration/vibration.dart';
import 'package:wishlist_mobile/icons.dart';
import 'package:wishlist_mobile/widgets/ancestor_route.dart';

import '../utils/math.dart';

@optionalTypeArgs
mixin _DisposeDeshadowing<T extends StatefulWidget> on State<T> {
  void _disposeWidgetState() {
    super.dispose();
  }
}

class OverscrollClosing extends StatefulWidget {
  final Widget child;
  final double armingOverscroll;
  final VoidCallback onClosed;
  final bool vibrate;

  const OverscrollClosing({
    Key? key,
    required this.child,
    required this.onClosed,
    this.armingOverscroll = 60,
    this.vibrate = true,
  }) : super(key: key);

  @override
  State<OverscrollClosing> createState() => OverscrollClosingState();
}

class OverscrollClosingState extends State<OverscrollClosing> with _DisposeDeshadowing, ChangeNotifier {
  bool _isArmed = false;

  bool get isArmed => _isArmed;

  @pragma('vm:prefer-inline')
  void _makeArmed() {
    if (!_isArmed) {
      if (widget.vibrate) {
        Vibration.vibrate(duration: 25);
      }
      _isArmed = true;
      notifyListeners();
    }
  }

  @pragma('vm:prefer-inline')
  void _unmakeArmed() {
    if (_isArmed) {
      _isArmed = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _disposeWidgetState();
  }

  bool _handleNotification(ScrollNotification notification) {
    if (notification.metrics.pixels <= notification.metrics.minScrollExtent - widget.armingOverscroll) {
      // There is enough overscroll to trigger arming
      if ((notification is ScrollStartNotification && notification.dragDetails != null) ||
          (notification is ScrollUpdateNotification && notification.dragDetails != null)) {
        // It is a user scroll, not ballistic simulation scroll and not jumpTo
        _makeArmed();
      } else if (_isArmed && notification is ScrollUpdateNotification && notification.dragDetails == null) {
        // User released the scroll
        widget.onClosed();
      }
    } else {
      _unmakeArmed();
    }

    return false;
  }

  @override
  Widget build(BuildContext context) => NotificationListener<ScrollNotification>(
        onNotification: _handleNotification,
        child: widget.child,
      );
}

class ClosingIndicator extends StatefulWidget {
  const ClosingIndicator({Key? key}) : super(key: key);

  @override
  State<ClosingIndicator> createState() => _ClosingIndicatorState();
}

class _ClosingIndicatorState extends State<ClosingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late OverscrollClosingState overscrollClosing;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _controller.addListener(() {
      setState(() {});
    });
    overscrollClosing = context.findAncestorStateOfType<OverscrollClosingState>()!;
    overscrollClosing.addListener(_handleOverscrollClosing);
  }

  void _handleOverscrollClosing() {
    if (overscrollClosing.isArmed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    overscrollClosing.removeListener(_handleOverscrollClosing);
  }

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation: Offset(0, 0.8 - 0.8 * _controller.value),
      child: Opacity(
        opacity: _controller.value,
        child: Icon(FluttericonIcons.chevronDown),
      ),
    );
  }
}

class SingleChildClosingIndicator extends StatefulWidget {
  // TODO: Allow setting duration
  final Widget child;

  const SingleChildClosingIndicator({Key? key, required this.child}) : super(key: key);

  @override
  State<SingleChildClosingIndicator> createState() => _SingleChildClosingIndicatorState();
}

class _SingleChildClosingIndicatorState extends State<SingleChildClosingIndicator> with TickerProviderStateMixin {
  final GlobalKey childKey = GlobalKey();
  late AnimationController animationController;
  late bool isCollapsed;
  late OverscrollClosingState overscrollClosing;

  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    animationController.addStatusListener((status) {
      if ((status == AnimationStatus.dismissed) != isCollapsed) {
        setState(() {
          isCollapsed = status == AnimationStatus.dismissed;
        });
      }
    });
    isCollapsed = animationController.status == AnimationStatus.dismissed;
    overscrollClosing = context.findAncestorStateOfType<OverscrollClosingState>()!;
    overscrollClosing.addListener(_handleOverscrollClosing);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    overscrollClosing.removeListener(_handleOverscrollClosing);
    super.dispose();
  }

  void _handleOverscrollClosing() {
    if (overscrollClosing.isArmed) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentOverscrollClosing = context.findAncestorStateOfType<OverscrollClosingState>()!;
    if (currentOverscrollClosing != overscrollClosing) {
      overscrollClosing.removeListener(_handleOverscrollClosing);
      overscrollClosing = currentOverscrollClosing;
      overscrollClosing.addListener(_handleOverscrollClosing);
    }

    return isCollapsed
        ? KeyedSubtree(key: childKey, child: widget.child)
        : Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransition(
                  position: offsetTween(0, 0.8, 0, 0).animate(animationController),
                  child: FadeTransition(
                    opacity: animationController,
                    child: Icon(FluttericonIcons.chevronDown),
                  ),
                ),
              ),
              SizedBox(height: 10),
              KeyedSubtree(key: childKey, child: widget.child)
            ],
          );
  }
}

class DisarmingTopPanel extends StatefulWidget {
  final Widget body;
  final Widget panel;
  final double panelExtent;
  final double panelOverlap;
  final bool addWindowTopPadding;

  const DisarmingTopPanel({
    Key? key,
    required this.body,
    required this.panel,
    required this.panelExtent,
    this.panelOverlap = 0,
    this.addWindowTopPadding = true,
  }) : super(key: key);

  @override
  State<DisarmingTopPanel> createState() => _DisarmingTopPanelState();
}

class _DisarmingTopPanelState extends State<DisarmingTopPanel> with TickerProviderStateMixin {
  final bodyKey = GlobalKey();
  late final AnimationController _panelController;
  late final Animation<Offset> _panelAnimation;
  late OverscrollClosingState overscrollClosing;
  late bool _collapsed;
  Animation? routeAnimation;

  set collapsed(bool value) {
    if (_collapsed != value) {
      setState(() => _collapsed = value);
    }
  }

  bool get revealed => !overscrollClosing.isArmed && (routeAnimation?.isCompleted ?? true);

  @override
  void initState() {
    overscrollClosing = context.findAncestorStateOfType<OverscrollClosingState>()!;
    overscrollClosing.addListener(_handlePossibleReveal);

    _panelController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _panelAnimation = offsetTween(0, -1.2, 0, 0).animate(CurvedAnimation(parent: _panelController, curve: Curves.easeOutQuad));

    _collapsed = _panelController.status == AnimationStatus.dismissed;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    final route = AncestorRoute.of(context);
    final newRouteAnimation = route is TransitionRoute ? route.animation : null;

    if (routeAnimation != newRouteAnimation) {
      routeAnimation?.removeStatusListener(_handleRouteAnimationStatus);
      newRouteAnimation?.addStatusListener(_handleRouteAnimationStatus);
      routeAnimation = newRouteAnimation;
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _panelController.dispose();
    overscrollClosing.removeListener(_handlePossibleReveal);
    super.dispose();
  }

  void _handleRouteAnimationStatus(AnimationStatus status) {
    _handlePossibleReveal();
  }

  void _handlePossibleReveal() {
    if (revealed) {
      collapsed = false;
      _panelController.forward();
    } else {
      _panelController.reverse().then((value) => collapsed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final finalPanelExtent = widget.addWindowTopPadding ? MediaQuery.of(context).padding.top + widget.panelExtent : widget.panelExtent;
    return _collapsed
        ? Padding(
            padding: EdgeInsets.only(top: finalPanelExtent - widget.panelOverlap ),
            child: KeyedSubtree(
              key: bodyKey,
              child: widget.body,
            ),
          )
        : Stack(
            children: [
              Positioned.fill(
                top: finalPanelExtent - widget.panelOverlap,
                child: KeyedSubtree(
                  key: bodyKey,
                  child: widget.body,
                ),
              ),
              SlideTransition(
                position: _panelAnimation,
                child: SizedBox(
                  height: finalPanelExtent,
                  child: widget.panel,
                ),
              ),
            ],
          );
  }
}
