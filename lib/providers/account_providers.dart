import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../services/account_service.dart';

/// Provider for AccountService singleton
final accountServiceProvider = Provider<AccountService>((ref) {
  return AccountService.instance;
});

/// Provider to fetch all active accounts
/// Usage: ref.watch(accountsProvider)
final accountsProvider = FutureProvider<List<Account>>((ref) async {
  final accountService = ref.watch(accountServiceProvider);
  return accountService.activeAccounts;
});

/// Provider to fetch a specific account by ID
/// Usage: ref.watch(accountDetailsProvider(accountId))
final accountDetailsProvider =
    FutureProvider.family<Account?, String>((ref, accountId) async {
  final accountService = ref.watch(accountServiceProvider);
  return accountService.getAccountById(accountId);
});

/// Provider to create a new account
final createAccountProvider = FutureProvider.family<
  Account,
  ({
    String name,
    String description,
    String pic,
    String? createdBy,
    List<String>? members,
    List<String>? admins,
    String? baseCurrency,
    String? baseCurrencyName,
  })
>((ref, params) async {
  final accountService = ref.watch(accountServiceProvider);
  final account = await accountService.createAccount(
    name: params.name,
    description: params.description,
    pic: params.pic,
    createdBy: params.createdBy,
    members: params.members,
    admins: params.admins,
    baseCurrency: params.baseCurrency,
    baseCurrencyName: params.baseCurrencyName,
  );

  // Invalidate accounts list to refresh UI
  ref.invalidate(accountsProvider);

  return account;
});

/// Provider to update an existing account
final updateAccountProvider = FutureProvider.family<
  Account,
  ({
    String accountId,
    String? name,
    String? description,
    String? pic,
    int? isActive,
    List<String>? members,
    List<String>? admins,
    String? baseCurrency,
    String? baseCurrencyName,
  })
>((ref, params) async {
  final accountService = ref.watch(accountServiceProvider);
  final updatedAccount = await accountService.updateAccount(
    params.accountId,
    name: params.name,
    description: params.description,
    pic: params.pic,
    isActive: params.isActive,
    members: params.members,
    admins: params.admins,
    baseCurrency: params.baseCurrency,
    baseCurrencyName: params.baseCurrencyName,
  );

  // Invalidate specific account details and list
  ref.invalidate(accountDetailsProvider(params.accountId));
  ref.invalidate(accountsProvider);

  return updatedAccount;
});

/// Provider to delete (soft delete) an account
final deleteAccountProvider = FutureProvider.family<void, String>((
  ref,
  accountId,
) async {
  final accountService = ref.watch(accountServiceProvider);
  await accountService.deleteAccount(accountId);

  // Invalidate specific account details and list
  ref.invalidate(accountDetailsProvider(accountId));
  ref.invalidate(accountsProvider);
});
