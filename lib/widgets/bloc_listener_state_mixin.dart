import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// T is the type of bloc/cubit,
/// S is the type of state of the bloc/cubit,
/// W is the type of the widget the state is for
mixin BlocListenerStateMixin<T extends StateStreamableSource<S>, S, W extends StatefulWidget> on State<W> {
  late StreamSubscription<S> _subscription;

  T? get bloc => null;

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    final b = bloc ?? BlocProvider.of<T>(context);
    _subscription = b.stream.listen((event) => blocHandler(b, event));
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void blocHandler(T bloc, S state);
}
