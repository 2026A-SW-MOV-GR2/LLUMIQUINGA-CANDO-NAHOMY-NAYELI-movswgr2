import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, error }

/// Logger estructurado con niveles DEBUG, INFO, ERROR
/// Cumple requisito: "Logs Estructurados"
class AppLogger {
  static const String _reset = '\x1B[0m';
  static const String _cyan = '\x1B[36m';
  static const String _green = '\x1B[32m';
  static const String _red = '\x1B[31m';
  static const String _yellow = '\x1B[33m';

  static void debug(String tag, String message) {
    _log(LogLevel.debug, tag, message);
  }

  static void info(String tag, String message) {
    _log(LogLevel.info, tag, message);
  }

  static void error(String tag, String message, [Object? error]) {
    _log(LogLevel.error, tag, message, error);
  }

  static void _log(LogLevel level, String tag, String message, [Object? error]) {
    if (!kDebugMode) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase().padRight(5);
    final color = _colorFor(level);

    final log = '$color[$levelStr]$_reset ${_yellow}[$tag]$_reset $timestamp - $message';
    debugPrint(log);

    if (error != null) {
      debugPrint('$_red  └─ Error: $error$_reset');
    }
  }

  static String _colorFor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return _cyan;
      case LogLevel.info:
        return _green;
      case LogLevel.error:
        return _red;
    }
  }
}
