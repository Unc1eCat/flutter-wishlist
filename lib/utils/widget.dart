import 'package:flutter/cupertino.dart';

extension StateExtension<T extends StatefulWidget> on State<T> {
  @protected
  // ignore: invalid_use_of_protected_member
  void rebuild() => setState(() {});
}