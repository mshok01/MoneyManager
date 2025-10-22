import 'package:flutter_test/flutter_test.dart';
import '../lib/services/logging_service.dart';

void main() {
  group('LoggingService Tests', () {
    setUp(() {
      // Clear any existing loggers before each test
      LoggingService.clearLoggers();
    });

    test('should initialize logging service', () {
      LoggingService.initialize();
      expect(LoggingService.getActiveLoggers(), isEmpty);
    });

    test('should create logger instances', () {
      final logger1 = LoggingService.getLogger('TestClass1');
      final logger2 = LoggingService.getLogger('TestClass2');
      
      expect(logger1, isNotNull);
      expect(logger2, isNotNull);
      expect(LoggingService.getActiveLoggers().length, equals(2));
    });

    test('should return same logger instance for same name', () {
      final logger1 = LoggingService.getLogger('TestClass');
      final logger2 = LoggingService.getLogger('TestClass');
      
      expect(identical(logger1, logger2), isTrue);
      expect(LoggingService.getActiveLoggers().length, equals(1));
    });

    test('should log different levels', () {
      final logger = LoggingService.getLogger('TestLogger');
      
      // These should not throw exceptions
      expect(() => logger.t('Trace message'), returnsNormally);
      expect(() => logger.d('Debug message'), returnsNormally);
      expect(() => logger.i('Info message'), returnsNormally);
      expect(() => logger.w('Warning message'), returnsNormally);
      expect(() => logger.e('Error message'), returnsNormally);
      expect(() => logger.f('Fatal message'), returnsNormally);
    });

    test('should use extension methods', () {
      final logger = LoggingService.getLogger('TestLogger');
      
      // These should not throw exceptions
      expect(() => logger.entering('testMethod'), returnsNormally);
      expect(() => logger.exiting('testMethod'), returnsNormally);
      expect(() => logger.apiCall('/api/test'), returnsNormally);
      expect(() => logger.apiResponse('/api/test', statusCode: 200), returnsNormally);
      expect(() => logger.dbOperation('SELECT'), returnsNormally);
      expect(() => logger.userAction('button_click'), returnsNormally);
      expect(() => logger.performance('operation', Duration(milliseconds: 100)), returnsNormally);
    });

    test('should clear loggers', () {
      LoggingService.getLogger('TestClass1');
      LoggingService.getLogger('TestClass2');
      
      expect(LoggingService.getActiveLoggers().length, equals(2));
      
      LoggingService.clearLoggers();
      
      expect(LoggingService.getActiveLoggers(), isEmpty);
    });
  });
}
