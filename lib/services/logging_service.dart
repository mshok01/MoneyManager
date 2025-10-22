import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Centralized logging service for the Money Manager app
///
/// This service provides structured logging with different levels and
/// automatic filtering based on build mode (debug/release).
///
/// Usage:
/// ```dart
/// final log = LoggingService.getLogger('ClassName');
/// log.info('This is an info message');
/// log.error('Error occurred', error: exception);
/// ```
class LoggingService {
  static final Map<String, Logger> _loggers = {};
  static bool _isInitialized = false;

  /// Initialize the logging service
  /// This should be called once during app startup
  static void initialize() {
    if (_isInitialized) return;

    // Set global log level based on build mode
    Logger.level = kDebugMode ? Level.trace : Level.warning;

    _isInitialized = true;
  }

  /// Get a logger instance for a specific class or module
  ///
  /// [name] - Usually the class name or module identifier
  /// Returns a configured Logger instance
  static Logger getLogger(String name) {
    if (!_isInitialized) {
      initialize();
    }

    // Return existing logger if already created
    if (_loggers.containsKey(name)) {
      return _loggers[name]!;
    }

    // Create new logger with custom configuration
    final logger = Logger(
      filter: _CustomLogFilter(),
      printer: _createPrinter(name),
      output: _CustomLogOutput(),
    );

    _loggers[name] = logger;
    return logger;
  }

  /// Create a printer with appropriate configuration
  static LogPrinter _createPrinter(String name) {
    if (kDebugMode) {
      // Beautiful output for debug mode
      return PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        excludeBox: {Level.trace: true, Level.debug: true},
        noBoxingByDefault: true,
      );
    } else {
      // Simple output for release mode
      return SimplePrinter(colors: false, printTime: true);
    }
  }

  /// Get all active loggers (for debugging)
  static Map<String, Logger> getActiveLoggers() {
    return Map.unmodifiable(_loggers);
  }

  /// Clear all loggers (useful for testing)
  static void clearLoggers() {
    _loggers.clear();
    _isInitialized = false;
  }
}

/// Custom log filter that respects build mode and log levels
class _CustomLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // In release mode, only log warnings and above
    if (kReleaseMode) {
      return event.level.index >= Level.warning.index;
    }

    // In debug mode, respect the global log level
    return event.level.index >= Logger.level.index;
  }
}

/// Custom log output that handles different destinations
class _CustomLogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    // In debug mode, output to console
    if (kDebugMode) {
      for (final line in event.lines) {
        debugPrint(line);
      }
    } else {
      // In release mode, you might want to send logs to a service
      // For now, we'll use print for critical logs only
      if (event.level.index >= Level.error.index) {
        for (final line in event.lines) {
          print(line);
        }
      }
    }
  }
}

/// Extension methods for common logging patterns
extension LoggerExtensions on Logger {
  /// Log a method entry
  void entering(String methodName, [Map<String, dynamic>? parameters]) {
    if (parameters != null && parameters.isNotEmpty) {
      t('→ $methodName($parameters)');
    } else {
      t('→ $methodName()');
    }
  }

  /// Log a method exit
  void exiting(String methodName, [dynamic result]) {
    if (result != null) {
      t('← $methodName() → $result');
    } else {
      t('← $methodName()');
    }
  }

  /// Log an API call
  void apiCall(String endpoint, {Map<String, dynamic>? data}) {
    if (data != null) {
      d('API Call: $endpoint with data: $data');
    } else {
      d('API Call: $endpoint');
    }
  }

  /// Log an API response
  void apiResponse(String endpoint, {dynamic response, int? statusCode}) {
    if (statusCode != null) {
      d('API Response: $endpoint [$statusCode] → $response');
    } else {
      d('API Response: $endpoint → $response');
    }
  }

  /// Log a database operation
  void dbOperation(String operation, {Map<String, dynamic>? data}) {
    if (data != null) {
      d('DB Operation: $operation with data: $data');
    } else {
      d('DB Operation: $operation');
    }
  }

  /// Log user action
  void userAction(String action, {Map<String, dynamic>? context}) {
    if (context != null) {
      i('User Action: $action with context: $context');
    } else {
      i('User Action: $action');
    }
  }

  /// Log performance metrics
  void performance(
    String operation,
    Duration duration, {
    Map<String, dynamic>? metrics,
  }) {
    final message = 'Performance: $operation took ${duration.inMilliseconds}ms';
    if (metrics != null) {
      d('$message, metrics: $metrics');
    } else {
      d(message);
    }
  }
}
