import 'package:flutter/material.dart';

class ColoredTab extends StatefulWidget {
  final TabController controller;
  final int index;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Icon? icon;
  final String? text;

  ColoredTab({
    required this.controller,
    required this.index,
    this.icon,
    this.text,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  _ColoredTabState createState() => _ColoredTabState();
}

class _ColoredTabState extends State<ColoredTab> {
  @override
  void initState() {
    widget.controller.animation!.addListener(rebuild);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.animation!.removeListener(rebuild);
    super.dispose();
  }

  void rebuild() {
    setState(() {});
  }

  Widget build(BuildContext context) {
    Widget? child;

    if (widget.text != null && widget.icon != null) {
      child = Column(
        children: [
          widget.icon!,
          SizedBox(height: 4),
          Text(widget.text!),
        ],
      );
    } else if (widget.text != null) {
      child = Text(widget.text!);
    } else if (widget.icon != null) {
      child = widget.icon!;
    }

    return AnimatedBuilder(
      animation: widget.controller.animation!,
      builder: (ctx, ch) {
        var value = 0.0;
        var animation = widget.controller.animation!;

        if (widget.controller.indexIsChanging) {
          if (widget.controller.index == widget.index || widget.controller.previousIndex == widget.index) {
            value = 1.0 - (((animation.value - widget.index) / (widget.controller.index - widget.controller.previousIndex)).abs());
          }
        } else {
          value = 1.0 - ((animation.value - widget.index).abs());
        }

        if (value < 0.0) value = 0.0;

        var color = Color.lerp(widget.unselectedColor, widget.selectedColor, value);

        return DefaultTextStyle(
          style: Theme.of(context).textTheme.headline6?.copyWith(color: color) ?? const TextStyle(fontSize: 16),
          child: IconTheme.merge(
            data: IconThemeData(color: color),
            child: ch!,
          ),
        );
      },
      child: child ?? const SizedBox(),
    );
  }
}