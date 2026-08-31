import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/services/user_api_service.dart';

void main() {
  group('UserApiService Tests', () {
    test('UserApiService singleton is accessible', () {
      final userApiService = UserApiService.instance;
      expect(userApiService, isNotNull);
    });

    test('UserApiService singleton returns same instance', () {
      final instance1 = UserApiService.instance;
      final instance2 = UserApiService.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    // Note: The following tests require a running backend server and valid JWT token
    // They are commented out for CI/CD environments but can be run locally
    
    // test('should update user name successfully', () async {
    //   final userApiService = UserApiService.instance;
    //   final userId = 'test_user_id';
    //   final newName = 'Updated Name';
    //
    //   final updatedUser = await userApiService.updateUserName(
    //     userId: userId,
    //     name: newName,
    //   );
    //
    //   expect(updatedUser, isNotNull);
    //   expect(updatedUser.name, newName);
    // });
    //
    // test('should update user email successfully', () async {
    //   final userApiService = UserApiService.instance;
    //   final userId = 'test_user_id';
    //   final newEmail = 'newemail@example.com';
    //
    //   final updatedUser = await userApiService.updateUserEmail(
    //     userId: userId,
    //     email: newEmail,
    //   );
    //
    //   expect(updatedUser, isNotNull);
    //   expect(updatedUser.email, newEmail);
    // });
    //
    // test('should update user profile picture successfully', () async {
    //   final userApiService = UserApiService.instance;
    //   final userId = 'test_user_id';
    //   final newProfilePic = 'https://example.com/newpic.jpg';
    //
    //   final updatedUser = await userApiService.updateUserProfilePic(
    //     userId: userId,
    //     profilePic: newProfilePic,
    //   );
    //
    //   expect(updatedUser, isNotNull);
    //   expect(updatedUser.profilePic, newProfilePic);
    // });
    //
    // test('should update user currency successfully', () async {
    //   final userApiService = UserApiService.instance;
    //   final userId = 'test_user_id';
    //   final newCurrencyCode = 'EUR';
    //   final newCurrencyName = 'Euro';
    //
    //   final updatedUser = await userApiService.updateUserCurrency(
    //     userId: userId,
    //     currencyCode: newCurrencyCode,
    //     currencyName: newCurrencyName,
    //   );
    //
    //   expect(updatedUser, isNotNull);
    //   expect(updatedUser.currencyCode, newCurrencyCode);
    //   expect(updatedUser.currencyName, newCurrencyName);
    // });
  });
}

