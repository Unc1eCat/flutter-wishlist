import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibration/vibration.dart';
import 'package:wishlist_mobile/icons.dart';

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
    this.armingOverscroll = 70,
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
    if (notification is ScrollEndNotification) {
      print(notification.metrics.pixels);
    }
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
  // TODO: Allow setting duration
  final Widget child;

  const ClosingIndicator({Key? key, required this.child}) : super(key: key);

  @override
  State<ClosingIndicator> createState() => _ClosingIndicatorState();
}

class _ClosingIndicatorState extends State<ClosingIndicator> with TickerProviderStateMixin {
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
