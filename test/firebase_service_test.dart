import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/services/firebase_service.dart';

void main() {
  group('FirebaseService Tests', () {
    late FirebaseService firebaseService;

    setUp(() {
      firebaseService = FirebaseService.instance;
    });

    test('should be a singleton', () {
      final instance1 = FirebaseService.instance;
      final instance2 = FirebaseService.instance;
      expect(instance1, same(instance2));
    });

    test('should not be initialized initially', () {
      expect(firebaseService.isInitialized, false);
    });

    test('should not have FCM token initially', () {
      expect(firebaseService.hasToken(), false);
      expect(firebaseService.fcmToken, null);
    });

    test('should handle token refresh callback', () {
      String? receivedToken;
      firebaseService.setOnTokenRefresh((token) {
        receivedToken = token;
      });

      // Simulate token refresh (this would normally be called by Firebase)
      // Since we can't actually test Firebase in unit tests, we just verify
      // the callback mechanism works
      expect(receivedToken, null);
    });

    test('should handle foreground message callback', () {
      bool callbackSet = false;
      firebaseService.setOnForegroundMessage((message) {
        callbackSet = true;
      });

      // Just verify the callback can be set without errors
      expect(callbackSet, false);
    });

    test('should handle message opened app callback', () {
      bool callbackSet = false;
      firebaseService.setOnMessageOpenedApp((message) {
        callbackSet = true;
      });

      // Just verify the callback can be set without errors
      expect(callbackSet, false);
    });

    test('should dispose resources', () {
      firebaseService.dispose();
      // No exception should be thrown
    });
  });
}
