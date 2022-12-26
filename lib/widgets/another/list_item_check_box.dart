import 'package:flutter/material.dart';
import 'dart:math' as math;

// Copied from grocery list and adapted to null safety
class ListItemCheckBox extends StatefulWidget {
  final bool checked;

  const ListItemCheckBox({Key? key, this.checked = false}) : super(key: key);

  @override
  _ListItemCheckBoxState createState() => _ListItemCheckBoxState();
}

class _ListItemCheckBoxState extends State<ListItemCheckBox> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: CurvedAnimation(curve: Curves.easeOutSine, parent: animation),
        child: RotationTransition(
          turns: Tween(begin: child is Icon ? -0.5 : 0.0, end: child is Icon ? 0.0 : -0.5).animate(animation),
          child: ScaleTransition(scale: child is Icon ? animation : Tween(begin: 2.0, end: 1.0).animate(animation), child: child),
        ),
      ),
      duration: Duration(milliseconds: 200),
      child: widget.checked
          ? Icon(
              Icons.check_rounded,
              color: Colors.green[600],
              size: 28,
            )
          : Padding(
              padding: const EdgeInsets.all(4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.onBackground, width: 1.5),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: SizedBox(
                  width: 20,
                  height: 20,
                ),
              ),
            ),
    );
  }
}
