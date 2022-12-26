

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

mixin UniversalTickerProvider implements TickerProvider {
  Set<Ticker>? _tickers;

  @override
  Ticker createTicker(TickerCallback onTick) {
    assert(_tickerModeNotifier != null);
    _tickers ??= <_DisposableTicker>{};
    final _DisposableTicker result = _DisposableTicker(onTick, this, debugLabel: kDebugMode ? 'created by ${describeIdentity(this)}' : null)
      ..muted = !_tickerModeNotifier!.value;
    _tickers!.add(result);
    return result;
  }

  void _removeTicker(_DisposableTicker ticker) {
    assert(_tickers != null);
    assert(_tickers!.contains(ticker));
    _tickers!.remove(ticker);
  }

  ValueNotifier<bool>? _tickerModeNotifier;

  set tickerModeNotifier(ValueNotifier<bool> value) {
    _tickerModeNotifier = value;
    _updateTickers();
  }

  void _updateTickers() {
    if (_tickers != null) {
      final bool muted = !_tickerModeNotifier!.value;
      for (final Ticker ticker in _tickers!) {
        ticker.muted = muted;
      }
    }
  }

  void disposeTickerProvider() {
    assert(() {
      if (_tickers != null) {
        for (final Ticker ticker in _tickers!) {
          if (ticker.isActive) {
            throw FlutterError.fromParts(<DiagnosticsNode>[
              ErrorSummary('$this was disposed with an active Ticker.'),
              ticker.describeForError('The offending ticker was'),
            ]);
          }
        }
      }
      return true;
    }());
    _tickerModeNotifier?.removeListener(_updateTickers);
    _tickerModeNotifier = null;
  }
}

class _DisposableTicker extends Ticker {
  _DisposableTicker(TickerCallback onTick, this._creator, { String? debugLabel }) : super(onTick, debugLabel: debugLabel);

  final UniversalTickerProvider _creator;

  @override
  void dispose() {
    _creator._removeTicker(this);
    super.dispose();
  }
}