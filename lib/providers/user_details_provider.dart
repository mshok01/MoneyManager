import 'package:riverpod/riverpod.dart';
import '../models/user.dart';
import '../services/user_service.dart';

/// Provider for UserService singleton
final userServiceProvider = Provider<UserService>((ref) {
  return UserService.instance;
});

/// Provider to get the current user details
/// Usage: ref.watch(currentUserProvider)
/// Returns the current user if logged in, null otherwise
final currentUserProvider = Provider<User?>((ref) {
  final userService = ref.watch(userServiceProvider);
  return userService.currentUser;
});

/// Provider to check if a user is logged in
/// Usage: ref.watch(isUserLoggedInProvider)
final isUserLoggedInProvider = Provider<bool>((ref) {
  final userService = ref.watch(userServiceProvider);
  return userService.hasUser;
});

/// Provider to get the current user's ID
/// Usage: ref.watch(userIdProvider)
final userIdProvider = Provider<String?>((ref) {
  final userService = ref.watch(userServiceProvider);
  return userService.getUserId();
});

/// Provider to get the current user's email
/// Usage: ref.watch(userEmailProvider)
final userEmailProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.email ?? '';
});

/// Provider to get the current user's name
/// Usage: ref.watch(userNameProvider)
final userNameProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.name ?? '';
});

/// Provider to get the current user's profile picture
/// Usage: ref.watch(userProfilePicProvider)
final userProfilePicProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.profilePic ?? '';
});

/// Provider to get the current user's currency code
/// Usage: ref.watch(userCurrencyCodeProvider)
final userCurrencyCodeProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.currencyCode ?? '';
});

/// Provider to get the current user's currency name
/// Usage: ref.watch(userCurrencyNameProvider)
final userCurrencyNameProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.currencyName ?? '';
});

/// Provider to check if user is active
/// Usage: ref.watch(isUserActiveProvider)
final isUserActiveProvider = Provider<bool>((ref) {
  final userService = ref.watch(userServiceProvider);
  return userService.isUserActive();
});

/// Provider to check if user has valid email
/// Usage: ref.watch(hasValidEmailProvider)
final hasValidEmailProvider = Provider<bool>((ref) {
  final userService = ref.watch(userServiceProvider);
  return userService.hasValidEmail();
});

/// Provider to check if user has name
/// Usage: ref.watch(hasUserNameProvider)
final hasUserNameProvider = Provider<bool>((ref) {
  final userService = ref.watch(userServiceProvider);
  return userService.hasUserName();
});

/// Provider to check if current user is valid
/// Usage: ref.watch(isCurrentUserValidProvider)
final isCurrentUserValidProvider = Provider<bool>((ref) {
  final userService = ref.watch(userServiceProvider);
  return userService.isCurrentUserValid();
});

/// Provider to check if user has currency set
/// Usage: ref.watch(hasUserCurrencyProvider)
final hasUserCurrencyProvider = Provider<bool>((ref) {
  final userService = ref.watch(userServiceProvider);
  return userService.hasUserCurrency();
});

/// Provider to create a new user
/// This is a method provider - call it to create a user
/// Usage: await ref.read(createUserProvider(params).future)
final createUserProvider = FutureProvider.family<
    User,
    ({
      String email,
      String name,
      String profilePic,
      String? currencyCode,
      String? currencyName,
    })>((ref, params) async {
  final userService = ref.watch(userServiceProvider);
  final user = await userService.createUser(
    email: params.email,
    name: params.name,
    profilePic: params.profilePic,
    currencyCode: params.currencyCode,
    currencyName: params.currencyName,
  );

  // Invalidate current user provider to refresh data
  ref.invalidate(currentUserProvider);

  return user;
});

/// Provider to update the current user
/// Usage: await ref.read(updateUserProvider(params).future)
final updateUserProvider = FutureProvider.family<
    User,
    ({
      String? email,
      String? name,
      String? profilePic,
      int? isActive,
      String? currencyCode,
      String? currencyName,
    })>((ref, params) async {
  final userService = ref.watch(userServiceProvider);
  final user = await userService.updateUser(
    email: params.email,
    name: params.name,
    profilePic: params.profilePic,
    isActive: params.isActive,
    currencyCode: params.currencyCode,
    currencyName: params.currencyName,
  );

  // Invalidate current user provider to refresh data
  ref.invalidate(currentUserProvider);

  return user;
});

/// Provider to delete the current user
/// Usage: await ref.read(deleteUserProvider.future)
final deleteUserProvider = FutureProvider<void>((ref) async {
  final userService = ref.watch(userServiceProvider);
  await userService.deleteUser();

  // Invalidate current user provider to refresh data
  ref.invalidate(currentUserProvider);
});

/// Provider to refresh user data from database
/// Usage: await ref.read(refreshUserProvider.future)
final refreshUserProvider = FutureProvider<void>((ref) async {
  final userService = ref.watch(userServiceProvider);
  await userService.refreshUser();

  // Invalidate current user provider to refresh data
  ref.invalidate(currentUserProvider);
});

/// Provider to save user from API response
/// Usage: await ref.read(saveUserFromResponseProvider(user).future)
final saveUserFromResponseProvider =
    FutureProvider.family<void, User>((ref, user) async {
  final userService = ref.watch(userServiceProvider);
  await userService.saveUserFromResponse(user);

  // Invalidate current user provider to refresh data
  ref.invalidate(currentUserProvider);
});

/// Provider to update current user from API response
/// Usage: await ref.read(updateCurrentUserProvider(user).future)
final updateCurrentUserProvider =
    FutureProvider.family<void, User>((ref, user) async {
  final userService = ref.watch(userServiceProvider);
  await userService.updateCurrentUser(user);

  // Invalidate current user provider to refresh data
  ref.invalidate(currentUserProvider);
});

