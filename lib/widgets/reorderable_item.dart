import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:local_hero/local_hero.dart';
import 'package:vibration/vibration.dart';

class ReorderableItemsController extends ChangeNotifier {
  bool _heroesEnabled = false;
  bool get heroesEnabled => _heroesEnabled;

  void _onDragStart() {
    _heroesEnabled = true;
    notifyListeners();
  }

  void _onDragEnd() {
    _heroesEnabled = true;
    notifyListeners();
    Future.delayed(Duration(milliseconds: 500)).then((value) {
      _heroesEnabled = false;
      notifyListeners();
    });
  }
}

class ReorderableItemData<T> extends Equatable {
  final ReorderableItemsController groupIdentifyingController;
  final T itemIdentifier;

  ReorderableItemData(this.groupIdentifyingController, this.itemIdentifier);

  @override
  List<Object?> get props => [groupIdentifyingController, itemIdentifier];
}

class ReorderableItem<T extends Object> extends StatefulWidget {
  final Widget child;
  final T tag;
  final DragTargetWillAccept<ReorderableItemData<T>>? onWillAccept;
  final DragTargetAccept<ReorderableItemData<T>> onAccept;
  final ReorderableItemsController controller;

  const ReorderableItem({
    Key? key,
    required this.child,
    required this.tag,
    this.onWillAccept,
    required this.onAccept,
    required this.controller,
  }) : super(key: key);

  @override
  State<ReorderableItem<T>> createState() => _ReorderableItemState<T>();
}

class _ReorderableItemState<T extends Object> extends State<ReorderableItem<T>> with TickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250), lowerBound: 0.7, value: 1.0);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ReorderableItemData<T>(widget.controller, widget.tag);
    final result = LongPressDraggable<ReorderableItemData<T>>(
      data: data,
      hapticFeedbackOnStart: false,
      onDragStarted: () {
        animationController.reverse();
        Vibration.vibrate(duration: 25);
        widget.controller._onDragStart();
      },
      onDragEnd: (details) {
        animationController.forward();
        widget.controller._onDragEnd();
      },
      feedback: ScaleTransition(
        scale: animationController,
        child: widget.child,
      ),
      childWhenDragging: Opacity(opacity: 0, child: widget.child),
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) => widget.controller.heroesEnabled
            ? LocalHero(
                tag: data,
                child: child!,
              )
            : child!,
        child: ScaleTransition(
          scale: animationController,
          child: widget.child,
        ),
      ),
    );

    return DragTarget<ReorderableItemData<T>>(
      onWillAccept: (data) {
        return data?.itemIdentifier != widget.tag && data?.groupIdentifyingController == widget.controller && (widget.onWillAccept?.call(data) ?? true);
      },
      onAccept: widget.onAccept,
      builder: (context, candidateData, rejectedData) => AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: candidateData.isEmpty ? 1.0 : 0.9,
        child: result,
      ),
    );
  }
}
