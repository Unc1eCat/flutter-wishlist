import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wishlist_mobile/widgets/heavy_touch_button.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? color;
  final EdgeInsets margin;

  ActionButton({
    required this.onPressed,
    required this.icon,
    this.margin = const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 10.0),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Padding(
      padding: margin,
      child: HeavyTouchButton(
        onPressed: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color ?? theme.buttonTheme.colorScheme!.primary,
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Icon(
              icon,
              color: theme.buttonTheme.colorScheme!.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
