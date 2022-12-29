import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

extension MediaQuerySelectExtension on BuildContext {
  R selectMediaQuery<R>(R Function(MediaQueryData data) selector) => select<MediaQueryData, R>(selector);
}