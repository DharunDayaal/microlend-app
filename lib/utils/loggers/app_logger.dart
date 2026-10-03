import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:micro_lending_app/utils/loggers/log_redactor.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  AppLogger._();

  /// Hook for a crash reporter later (Crashlytics, Sentry). Set it once
  /// in main(). It receives errors only.
  static void Function(Object error, StackTrace? stack, String? tag)? onError;

  static const Map<LogLevel, int> _levelValue = {
    LogLevel.debug: 500,
    LogLevel.info: 800,
    LogLevel.warning: 900,
    LogLevel.error: 1000,
  };

  static const Map<LogLevel, String> _emoji = {
    LogLevel.debug: '🐛',
    LogLevel.info: '💡',
    LogLevel.warning: '⚠️',
    LogLevel.error: '⛔',
  };

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stack,
  }) {
    // Release builds: warnings and errors only.
    if (!kDebugMode && level.index < LogLevel.warning.index) return;

    developer.log(
      '${_emoji[level]} $message',
      name: tag ?? 'App',
      level: _levelValue[level]!,
      error: error,
      stackTrace: stack,
    );
  }

  static void debug(String message, {String? tag}) =>
      _log(LogLevel.debug, message, tag: tag);

  static void info(String message, {String? tag}) =>
      _log(LogLevel.info, message, tag: tag);

  static void warning(String message, {String? tag, Object? error}) =>
      _log(LogLevel.warning, message, tag: tag, error: error);

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stack,
  }) {
    _log(LogLevel.error, message, tag: tag, error: error, stack: stack);
    if (error != null) onError?.call(error, stack, tag);
  }

  // ---------- API ----------

  /// Log an outgoing request. The body is cleaned before printing.
  static void request(String method, String path, {Map<String, dynamic>? body}) {
    final b = body == null ? '' : ' body=${LogRedactor.clean(body)}';
    _log(LogLevel.debug, '→ $method $path$b', tag: 'API');
  }

  /// Log a response with status code and how long it took.
  static void response(
    String method,
    String path,
    int statusCode,
    Duration elapsed,
  ) {
    final ok = statusCode >= 200 && statusCode < 300;
    _log(
      ok ? LogLevel.debug : LogLevel.warning,
      '← $statusCode $method $path (${elapsed.inMilliseconds} ms)',
      tag: 'API',
    );
  }

  // ---------- UI / NAVIGATION ----------

  static void screen(String name) =>
      _log(LogLevel.info, 'Screen: $name', tag: 'Nav');

  /// Times an async operation and logs how long it took.
  static Future<T> timed<T>(String label, Future<T> Function() action) async {
    final sw = Stopwatch()..start();
    try {
      return await action();
    } finally {
      sw.stop();
      _log(LogLevel.debug, '$label took ${sw.elapsedMilliseconds} ms',
          tag: 'Perf');
    }
  }
}