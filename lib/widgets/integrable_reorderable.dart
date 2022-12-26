// TODO: Below - LocalHero + reordering 

// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';

// typedef ContainerWidgetBuilder = Widget Function(BuildContext context, List<Widget> children);

// enum DragAxis { horizontal, vertical, both }

// DragGestureRecognizer _gestureRecognizerForAxes(DragAxis axes) {
//   switch (axes) {
//     case DragAxis.horizontal:
//       return HorizontalDragGestureRecognizer();
//     case DragAxis.vertical:
//       return VerticalDragGestureRecognizer();
//     case DragAxis.both:
//       return PanGestureRecognizer();
//   }
// }

// class IntegratedReorderingScope extends StatefulWidget {
//   final ContainerWidgetBuilder builder;
//   final DragAxis allowedDragAxes;

//   const IntegratedReorderingScope({
//     Key? key,
//     required this.builder,
//     required this.allowedDragAxes,
//   }) : super(key: key);

//   @override
//   State<IntegratedReorderingScope> createState() => _IntegratedReorderingScopeState();
// }

// class _IntegratedReorderingScopeState extends State<IntegratedReorderingScope> {
//   DragGestureRecognizer gestureRecognizer;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {}
// }

// // "integrable" because this widget adds (integrates) reordering functionality into already existing container widgets
// class IntegrableReorderable extends StatefulWidget {
//   final Widget child;

//   const IntegrableReorderable({
//     Key? key,
//     required this.child,
//   }) : super(key: key);

//   @override
//   State<IntegrableReorderable> createState() => _IntegrableReorderableState();
// }

// class _IntegrableReorderableState extends State<IntegrableReorderable> {
//   @override
//   Widget build(BuildContext context) {}
// }
