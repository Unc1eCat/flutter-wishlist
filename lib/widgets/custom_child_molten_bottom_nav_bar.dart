import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:molten_navigationbar_flutter/molten_navigationbar_flutter.dart';
import 'package:wishlist_mobile/utils/widget.dart';
import 'package:wishlist_mobile/widgets/heavy_touch_button.dart';

class CustomChildMoltenBottomNavigationBar extends StatefulWidget {
  /// specify a Height for the bar, Default is kBottomNavigationBarHeight
  final double barHeight;

  /// specify a Height for the Dome above tabs, Default is 15.0
  final double domeHeight;

  /// If [domeWidth] is null, it will be set to 100
  final double domeWidth;

  /// If a null value is passed, the [domeCircleColor] will be Theme.primaryColor
  final Color domeCircleColor;

  /// The size of the inner circle representing a seleted tab
  ///
  /// Note that [domeCircleSize] must be less than or equal to (barHeight + domeHeight)
  final double domeCircleSize;

  /// specify a color to be used as a background color, Default is Theme.bottomAppBarColor
  ///
  /// If the opacity is less than 1, it will automatically be 1
  final Color? barColor;

  /// List of [MoltenTab], each wil have an icon as the main widget, selcted color and unselected color
  final List<MoltenTab> tabs;

  /// Select a [Curve] value for the dome animation. Default is [Curves.linear]
  final Curve curve;

  /// How long the animation should last, Default is Duration(milliseconds: 150)
  final Duration? duration;

  /// Applied to all 4 border sides, Default is 0
  final double borderSize;

  /// Applied to all border sides
  final Color? borderColor;

  /// How much each angle is curved.
  /// Default is: (topLeft: Radius.circular(10), topRight: Radius.circular(10))
  ///
  /// Note that high raduis values may decrease the dome width.
  final BorderRadius? borderRadius;

  final TabController controller;

  final double sidePadding;

  final double barWidth;

  /// An animated bottom navigation that makes your app looks better
  /// with customizable attrinutes
  ///
  /// Give an [onTabChange] callback to specify what will happen whenever a tab is selected.
  /// [tabs] are of type MoltenTab, use them to display selectable tabs.
  CustomChildMoltenBottomNavigationBar({
    Key? key,
    this.barHeight = kBottomNavigationBarHeight,
    this.barColor,
    this.domeHeight = 15.0,
    this.domeWidth = 100,
    this.domeCircleColor = Colors.transparent,
    this.domeCircleSize = 50.0,
    required this.tabs,
    required this.controller,
    required this.barWidth,
    this.duration,
    this.curve = Curves.linear,
    this.borderColor,
    this.borderSize = 0,
    this.borderRadius,
    this.sidePadding = 30,
  }) : super(key: key);

  @override
  State<CustomChildMoltenBottomNavigationBar> createState() => _CustomChildMoltenBottomNavigationBarState();
}

class _CustomChildMoltenBottomNavigationBarState extends State<CustomChildMoltenBottomNavigationBar> {
  late int currentIndex;

  @override
  void initState() {
    widget.controller.animation!.addListener(_handleController);
    currentIndex = widget.controller.index;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CustomChildMoltenBottomNavigationBar oldWidget) {
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.animation!.removeListener(_handleController);
      widget.controller.animation!.addListener(_handleController);
      currentIndex = widget.controller.index;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleController);
    super.dispose();
  }

  void _handleController() {
    final draggedIndex = widget.controller.index + widget.controller.offset.sign.toInt();
    if (!widget.controller.indexIsChanging) {
      if (widget.controller.offset.abs() >= 0.5) {
        if (draggedIndex != currentIndex) {
          setState(() => currentIndex = widget.controller.index + widget.controller.offset.sign.toInt());
        }
      } else {
        if (widget.controller.index != currentIndex) {
          setState(() => currentIndex = widget.controller.index);
        }
      }
    } else {
      if (widget.controller.index != currentIndex) {
        setState(() => currentIndex = widget.controller.index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.domeCircleSize <= (widget.barHeight + widget.domeHeight), 'domeCircleSize must be less than or equal to (barHeight + domeHeight)');

    final borderRadius = widget.borderRadius ?? BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10));

    final barColor = (widget.barColor?.withOpacity(1)) ?? Theme.of(context).colorScheme.surface;

    // final domeCircleColor = (widget.domeCircleColor?.withOpacity(1)) ?? Theme.of(context).colorScheme.primary;

    final tabWidth = (widget.barWidth - widget.sidePadding * 2) / widget.tabs.length;

    final domeWidth = min(widget.domeWidth, tabWidth + widget.sidePadding - max(borderRadius.topLeft.x, borderRadius.topRight.x));

    final sidePadding = widget.sidePadding;

    return SizedBox(
      height: widget.barHeight + widget.domeHeight,
      width: widget.barWidth,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          // Back card
          PhysicalModel(
            color: barColor,
            clipBehavior: Clip.hardEdge,
            borderRadius: borderRadius,
            elevation: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(color: (widget.borderColor == null || widget.borderSize < 1) ? barColor : widget.borderColor!, width: widget.borderSize),
              ),
              child: SizedBox(
                height: widget.barHeight,
                width: widget.barWidth,
              ),
            ),
          ),
          // Border for the dome
          if (widget.borderSize > 0)
            _animatedPositionedDome(
              sidePadding: sidePadding,
              top: 0,
              tabWidth: tabWidth,
              domeWidth: domeWidth,
              domeHeight: widget.domeHeight + 0.5,
              domeColor: widget.borderColor ?? barColor,
            ),
          // Actual dome
          _animatedPositionedDome(
            sidePadding: sidePadding,
            top: widget.borderSize < 1 ? 1 : (widget.borderSize + 0.2),
            tabWidth: tabWidth,
            domeWidth: domeWidth - widget.borderSize * 2,
            domeHeight: widget.domeHeight,
            domeColor: barColor,
          ),
          // Colored circle
          if (widget.domeCircleColor.opacity > 0 && widget.domeCircleSize > 0)
            AnimatedPositioned(
              top: 0,
              bottom: 0,
              curve: widget.curve,
              duration: widget.duration ?? Duration(milliseconds: 150),
              left: sidePadding + tabWidth * currentIndex,
              width: tabWidth + _normalizationValueOnTheEdge(currentIndex),
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.domeCircleColor,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    height: widget.domeCircleSize,
                    width: widget.domeCircleSize,
                  ),
                ),
              ),
            ),
          // Tabs
          ...widget.tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final isSelected = index == currentIndex;
            return AnimatedPositioned(
              curve: widget.curve,
              duration: widget.duration ?? Duration(milliseconds: 150),
              top: isSelected ? 0 : widget.domeHeight,
              bottom: 0,
              left: sidePadding + tabWidth * index,
              width: tabWidth + _normalizationValueOnTheEdge(currentIndex),
              child: entry.value.buildTab(context, () => widget.controller.animateTo(index), isSelected, entry.key),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _animatedPositionedDome({
    required double sidePadding,
    required double top,
    required double domeWidth,
    required double domeHeight,
    required Color domeColor,
    required double tabWidth,
  }) {
    return AnimatedPositioned(
      curve: widget.curve,
      duration: widget.duration ?? Duration(milliseconds: 150),
      top: top,
      left: sidePadding + tabWidth * currentIndex - (domeWidth - tabWidth - _normalizationValueOnTheEdge(currentIndex)) / 2,
      width: domeWidth,
      child: CustomPaint(
        painter: _DomePainter(color: domeColor),
        size: Size(domeWidth, domeHeight),
      ),
    );
  }

  double _normalizationValueOnTheEdge(int index) {
    if (index == 0) {
      return widget.borderSize;
    } else if (index == widget.tabs.length - 1) {
      return -widget.borderSize;
    } else {
      return 0;
    }
  }
}

abstract class MoltenTab {
  Widget buildTab(BuildContext context, VoidCallback selectThisTab, bool isSelected, int index);
}

class _IconMoltenTabWidget extends StatefulWidget {
  final bool isSelected;
  final IconData icon;

  const _IconMoltenTabWidget({
    Key? key,
    required this.isSelected,
    required this.icon,
  }) : super(key: key);

  @override
  State<_IconMoltenTabWidget> createState() => __IconMoltenTabWidgetState();
}

class __IconMoltenTabWidgetState extends State<_IconMoltenTabWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _controller.addListener(rebuild);
  }

  @override
  void didUpdateWidget(covariant _IconMoltenTabWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Transform.scale(
      scale: 1.0 + _controller.value * 0.4,
      child: Icon(
        widget.icon,
        color: Color.lerp(th.bottomNavigationBarTheme.unselectedItemColor, th.bottomNavigationBarTheme.selectedItemColor, _controller.value),
      ),
    );
  }
}

class IconMoltenTab implements MoltenTab {
  final Widget _selected;
  final Widget _unselected;

  IconMoltenTab({
    required IconData icon,
  })  : _selected = _IconMoltenTabWidget(isSelected: true, icon: icon),
        _unselected = _IconMoltenTabWidget(isSelected: false, icon: icon);

  @override
  Widget buildTab(BuildContext context, VoidCallback selectThisTab, bool isSelected, int index) {
    return HeavyTouchButton(
      onPressed: selectThisTab,
      child: isSelected ? _selected : _unselected,
    );
  }
}

class _DomePainter extends CustomPainter {
  final Color color;
  _DomePainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = color;
    Path path = Path();
    path.lineTo(0, size.height);
    path.cubicTo(0, size.height, size.width, size.height, size.width, size.height);
    path.cubicTo(size.width * 0.94, size.height, size.width * 0.83, size.height * 0.65, size.width * 0.72, size.height * 0.31);
    path.cubicTo(size.width * 0.67, size.height * 0.12, size.width * 0.59, size.height * 0.01, size.width * 0.51, 0);
    path.cubicTo(size.width * 0.51, 0, size.width * 0.51, 0, size.width * 0.51, 0);
    path.cubicTo(size.width * 0.42, -0.01, size.width * 0.34, size.height * 0.11, size.width * 0.27, size.height * 0.31);
    path.cubicTo(size.width * 0.17, size.height * 0.65, size.width * 0.06, size.height, 0, size.height);
    path.cubicTo(0, size.height, 0, size.height, 0, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
