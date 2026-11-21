import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:micro_lending_app/core/network/api_client.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/features/analytics/domain/entities/analytics_status.dart';

class _Entry {
  final DateTime at;
  final Map<String, dynamic> data;
  _Entry(this.data, [DateTime? at]) : at = at ?? DateTime.now();
}

/// Runs at most [max] tasks at once; the rest wait in order.
class _Gate {
  final int max;
  int _running = 0;
  final _queue = <Completer<void>>[];
  _Gate(this.max);

  Future<T> run<T>(Future<T> Function() task) async {
    if (_running < max) {
      _running++;
    } else {
      final c = Completer<void>();
      _queue.add(c);
      await c.future; // the finishing task hands its slot over
    }
    try {
      return await task();
    } finally {
      if (_queue.isNotEmpty) {
        _queue.removeAt(0).complete();
      } else {
        _running--;
      }
    }
  }
}

/// Every analytics GET: flat responses, a 2-minute cache, shared in-flight
/// requests, at most 3 requests at a time, and the last good answer when
/// the phone is offline.
class AnalyticsGateway {
  AnalyticsGateway(this._api);

  final ApiClient _api;
  static const _ttl = Duration(minutes: 2);
  final _cache = <String, _Entry>{};
  final _inflight = <String, Future<Map<String, dynamic>>>{};
  final _gate = _Gate(3);

  /// Read by the screens for the offline banner and "Updated ... ago".
  final connection = ValueNotifier<AnalyticsStatus>(const AnalyticsStatus());

  void _mark({required bool offline, DateTime? at}) {
    final cur = connection.value;
    connection.value = AnalyticsStatus(
      offline: offline,
      updatedAt: at ?? cur.updatedAt,
    );
  }

  /// Everything goes (sign-out: the next user must not see these numbers).
  void clearCache() {
    _cache.clear();
    connection.value = const AnalyticsStatus();
  }

  /// Entries count as old, but stay as a fallback for when the phone is offline.
  void expireAll() => _cache.updateAll(
    (_, e) => _Entry(e.data, DateTime.fromMillisecondsSinceEpoch(0)),
  );

  /// Completes when the requests started by a refresh have finished.
  Future<void> settled() async {
    await Future<void>.delayed(
      const Duration(milliseconds: 150),
    ); // cards refetch next frame
    final deadline = DateTime.now().add(const Duration(seconds: 12));
    while (_inflight.isNotEmpty && DateTime.now().isBefore(deadline)) {
      await Future.wait([
        for (final f in _inflight.values.toList())
          f.then<void>((_) {}, onError: (_) {}),
      ]);
    }
  }

  /// Accepts both shapes: { success, message, ...fields } and
  /// { success, message, data: { ...fields } }.
  static Map<String, dynamic> _body(dynamic res) {
    if (res is! Map) return <String, dynamic>{};
    final body = Map<String, dynamic>.from(res);
    final inner = body['data'];
    return inner is Map ? {...body, ...Map<String, dynamic>.from(inner)} : body;
  }

  Future<Map<String, dynamic>> get(String path, Map<String, dynamic> query) {
    final sorted = query.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final key = '$path?${sorted.map((e) => '${e.key}=${e.value}').join('&')}';

    final hit = _cache[key];
    if (hit != null && DateTime.now().difference(hit.at) < _ttl) {
      return Future.value(hit.data);
    }
    return _inflight[key] ??= _gate.run(() async {
      try {
        final res = await _api.get(path, query: query);
        final data = _body(res);
        if (kDebugMode) {
          debugPrint('[Analytics] $path -> ${data.keys.toList()}');
        }
        _cache[key] = _Entry(data);
        _mark(offline: false, at: DateTime.now());
        return data;
      } on ApiException catch (e) {
        if (e.isNetworkError) {
          _mark(offline: true);
          final old = _cache[key];
          if (old != null) return old.data; // an old answer beats an error card
        }
        rethrow;
      } finally {
        _inflight.remove(key);
      }
    });
  }
}
