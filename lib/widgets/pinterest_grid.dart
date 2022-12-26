import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// A staggered grid that positions a child of an index in this manner:
// 0 4 8
// 1 5 9
// 2 6 10
// 3 7
class PinterestGrid extends MultiChildRenderObjectWidget {
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double bottomMarginOnChildren;

  PinterestGrid({
    Key? key,
    required super.children,
    required this.crossAxisCount,
    this.crossAxisSpacing = 0,
    this.bottomMarginOnChildren = 0,
  }) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) => RenderPinterestGrid(this);

  @override
  void updateRenderObject(BuildContext context, covariant RenderPinterestGrid renderObject) {
    renderObject.configuration = this;
  }
}

class PinterestGridParentData extends ContainerBoxParentData<RenderBox> {}

class RenderPinterestGrid extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, PinterestGridParentData>, RenderBoxContainerDefaultsMixin<RenderBox, PinterestGridParentData> {
  RenderPinterestGrid(this._configuration);

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! PinterestGridParentData) {
      child.parentData = PinterestGridParentData();
    }
  }

  PinterestGrid _configuration;
  set configuration(PinterestGrid value) {
    if (_configuration.crossAxisCount != value.crossAxisCount ||
        _configuration.crossAxisSpacing != value.crossAxisSpacing ||
        _configuration.bottomMarginOnChildren != value.bottomMarginOnChildren) {
      markNeedsLayout();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void performLayout() {
    if (childCount == 0) {
      size = constraints.smallest;
      return;
    }

    var totalHeight = 0.0;
    final crossAxisExtent = (constraints.maxWidth - _configuration.crossAxisSpacing * (_configuration.crossAxisCount - 1)) / _configuration.crossAxisCount;
    final childConstraints = constraints.copyWith(maxHeight: double.infinity, minWidth: crossAxisExtent, maxWidth: crossAxisExtent);

    var ch = firstChild;
    while (ch != null) {
      ch.layout(childConstraints, parentUsesSize: true);
      totalHeight += ch.size.height + _configuration.bottomMarginOnChildren;
      ch = (ch.parentData as ContainerBoxParentData<RenderBox>).nextSibling;
    }

    final minHeightPerFirstColumns = totalHeight / _configuration.crossAxisCount;
    var column = 0;
    var vertical = 0.0;
    var maxVertical = 0.0;

    ch = firstChild;
    while (ch != null) {
      final pd = ch.parentData as ContainerBoxParentData<RenderBox>;

      pd.offset = Offset((crossAxisExtent + _configuration.crossAxisSpacing) * column, vertical);
      vertical += ch.size.height + _configuration.bottomMarginOnChildren;
      if (vertical >= minHeightPerFirstColumns) {
        if (vertical > maxVertical) {
          maxVertical = vertical;
        }
        column++;
        vertical = 0;
      }

      ch = (ch.parentData as ContainerBoxParentData<RenderBox>).nextSibling;
    }

    size = Size(constraints.maxWidth, maxVertical);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
