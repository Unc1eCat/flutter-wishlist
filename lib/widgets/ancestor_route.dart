import 'package:flutter/widgets.dart';

class AncestorRoute extends InheritedWidget {
  static Route? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AncestorRoute>()?.route;

  final Route route;

  const AncestorRoute({
    required this.route,
    required super.child,
    super.key,
  });

  @override
  bool updateShouldNotify(covariant AncestorRoute oldWidget) => route != oldWidget.route;
}
