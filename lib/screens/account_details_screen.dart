import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';
import '../services/transaction_service.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../l10n/app_localizations.dart';
import '../utils/currency_utils.dart';
import '../providers/account_providers.dart';
import 'transaction_list_screen.dart';
import 'add_edit_transaction_screen.dart';

class AccountDetailsScreen extends ConsumerStatefulWidget {
  final Account account;

  const AccountDetailsScreen({super.key, required this.account});

  @override
  ConsumerState<AccountDetailsScreen> createState() =>
      _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends ConsumerState<AccountDetailsScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isEditing = false;
  bool _isLoading = false;
  String? _currentUserId;
  bool _hasChanges = false;

  // Transaction-related state
  double _accountBalance = 0.0;
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  List<Transaction> _recentTransactions = [];
  bool _isLoadingTransactions = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.account.name;
    _descriptionController.text = widget.account.description;
    _currentUserId = UserService.instance.currentUser?.id;

    // Listen for changes
    _nameController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);

    // Load transaction data
    _loadTransactionData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Format amount with user's preferred currency symbol
  String _formatAmount(double amount, Account account) {
    final currentUser = UserService.instance.currentUser;
    final userCurrency = currentUser?.currencyCode ?? account.baseCurrency;
    final currencySymbol = CurrencyUtils.getCurrencySymbol(userCurrency);

    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  void _onFieldChanged() {
    // We defer the check to logic using the account data from provider
  }

  bool _hasAccountSettings() {
    return false;
  }

  bool _hasActions(Account account) {
    if (_currentUserId == null) return false;

    final hasMultipleMembers = account.memberCount > 1;
    final hasOtherAdmins =
        account.adminCount > 1 ||
        (account.adminCount == 1 && !account.isAdmin(_currentUserId!));
    
    // Only show actions if there are actions to display
    return hasMultipleMembers && hasOtherAdmins;
  }

  void _toggleEdit(Account account) {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        // Start editing: set controllers to current account values
        _nameController.text = account.name;
        _descriptionController.text = account.description;
      } else {
        // Cancel edit: reset checks
        _hasChanges = false;
      }
    });
  }

  Future<void> _saveChanges(Account account) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(
        updateAccountProvider((
          accountId: account.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          pic: null,
          isActive: null,
          members: null,
          admins: null,
          baseCurrency: null,
          baseCurrencyName: null,
        )).future,
      );

      setState(() {
        _isEditing = false;
        _hasChanges = false;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.accountUpdatedSuccessfully,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToUpdateAccount(e.toString()),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.deleteAccount),
            content: Text(
              AppLocalizations.of(
                context,
              )!.deleteAccountConfirmation(widget.account.name),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(AppLocalizations.of(context)!.delete),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ref.read(deleteAccountProvider(widget.account.id).future);

        if (mounted) {
          Navigator.of(context).pop(); // Perform pop before snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.accountDeletedSuccessfully,
              ),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                )!.failedToDeleteAccount(e.toString()),
              ),
            ),
          );
        }
      }
    }
  }

  List<Widget> _buildActionButtons(Account account) {
    if (_currentUserId == null) return [];

    final isAdmin = account.hasAdminPrivileges(_currentUserId!);
    final isOnlyMember = account.memberCount == 1;
    final hasMultipleMembers = account.memberCount > 1;
    final hasOtherAdmins =
        account.adminCount > 1 ||
        (account.adminCount == 1 && !account.isAdmin(_currentUserId!));

    List<Widget> actions = [];

    // Show exit option if multiple members and there are other admins
    if (hasMultipleMembers && hasOtherAdmins) {
      actions.add(
        IconButton(
          onPressed: () => _exitAccount(account),
          icon: const Icon(Icons.exit_to_app),
          tooltip: AppLocalizations.of(context)!.exitAccount,
        ),
      );
    }

    // Show delete option only for admins and not if only one member
    if (isAdmin && !isOnlyMember) {
      actions.add(
        IconButton(
          onPressed: _deleteAccount,
          icon: const Icon(Icons.delete),
          tooltip: AppLocalizations.of(context)!.deleteAccount,
        ),
      );
    }

    return actions;
  }

  Future<void> _exitAccount(Account account) async {
    if (_currentUserId == null) return;

    final isAdmin = account.isAdmin(_currentUserId!);
    final hasOtherAdmins =
        account.adminCount > 1 ||
        (account.adminCount == 1 && !account.isAdmin(_currentUserId!));

    // Check if admin is trying to exit without other admins
    if (isAdmin && !hasOtherAdmins) {
      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.cannotExitAccount),
              content: Text(
                AppLocalizations.of(context)!.cannotExitAccountMessage,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.ok),
                ),
              ],
            ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.exitAccount),
            content: Text(
              AppLocalizations.of(
                context,
              )!.exitAccountConfirmation(account.name),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(AppLocalizations.of(context)!.exit),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ref
            .read(accountServiceProvider)
            .removeMemberFromAccount(account.id, _currentUserId!);

        ref.invalidate(accountDetailsProvider(account.id));
        ref.invalidate(accountsProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.successfullyExitedAccount,
              ),
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.failedToExitAccount(e.toString()),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = UserService.instance.currentUser;
    final accountAsync = ref.watch(accountDetailsProvider(widget.account.id));

    return accountAsync.when(
      data: (account) {
        if (account == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Account Not Found')),
            body: const Center(child: Text('Account has been deleted')),
          );
        }

        // Check for changes whenever build runs (if editing)
        if (_isEditing) {
          final hasChanges =
              _nameController.text != account.name ||
              _descriptionController.text != account.description;
          if (hasChanges != _hasChanges) {
             WidgetsBinding.instance.addPostFrameCallback((_) {
               if (mounted) {
                 setState(() {
                   _hasChanges = hasChanges;
                 });
               }
             });
          }
        }

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            ),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  child: Text(
                    account.name.isNotEmpty
                        ? account.name.substring(0, 2).toUpperCase()
                        : 'AC',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    account.name,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              if (_isEditing) ...[
                IconButton(
                  onPressed: _isLoading ? null : () => _saveChanges(account),
                  icon:
                      _isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          )
                          : Icon(Icons.check, color: theme.colorScheme.primary),
                  tooltip: AppLocalizations.of(context)!.save,
                ),
                IconButton(
                  onPressed:
                      _isLoading ? null : () => _toggleEdit(account),
                  icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                  tooltip: AppLocalizations.of(context)!.cancel,
                ),
              ] else ...[
                IconButton(
                  onPressed: () => _toggleEdit(account),
                  icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                  tooltip: AppLocalizations.of(context)!.edit,
                ),
                ..._buildActionButtons(account),
              ],
            ],
          ),
          body:
              _isEditing
                  ? _buildEditForm(theme)
                  : _buildViewContent(theme, currentUser, account),
        );
      },
      loading:
          () => Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (error, stack) => Scaffold(
            appBar: AppBar(),
            body: Center(child: Text('Error: $error')),
          ),
    );
  }

  Widget _buildEditForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.accountName,
              border: const OutlineInputBorder(),
              prefixIcon: Icon(
                Icons.account_balance_wallet,
                color: theme.colorScheme.primary,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppLocalizations.of(context)!.accountNameRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.descriptionOptional,
              border: const OutlineInputBorder(),
              prefixIcon: Icon(
                Icons.description,
                color: theme.colorScheme.primary,
              ),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewContent(ThemeData theme, currentUser, Account account) {
    return ListView(
      children: [
        _buildAccountProfileSection(theme, account),
        _buildTransactionSummarySection(theme, account),
        _buildQuickActionsSection(theme, account),
        _buildRecentTransactionsSection(theme, account),
        _buildMembersSection(theme, currentUser, account),
        _buildAddMemberSection(theme),
        if (_hasAccountSettings()) _buildAccountSettingsSection(theme),
        if (_hasActions(account))
          _buildActionsSection(theme, currentUser, account),
      ],
    );
  }

  Widget _buildAccountProfileSection(ThemeData theme, Account account) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              account.name.isNotEmpty
                  ? account.name.substring(0, 2).toUpperCase()
                  : 'AC',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            account.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (account.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              account.description,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMembersSection(
    ThemeData theme,
    currentUser,
    Account account,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            AppLocalizations.of(context)!.members(account.memberCount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children:
                    account.members.map((memberId) {
                      final isCurrentUser = memberId == _currentUserId;
                      final isCreator = account.isCreator(memberId);
                      final isAdmin = account.isAdmin(memberId);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              child: Icon(
                                Icons.person,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    isCurrentUser
                                        ? AppLocalizations.of(context)!.you
                                        : AppLocalizations.of(context)!.member,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (isCreator) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.creator,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (isAdmin && !isCreator) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.admin,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddMemberSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.person_add,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.addMember,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.addMemberComingSoon),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccountSettingsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            AppLocalizations.of(context)!.accountSettings,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection(
    ThemeData theme,
    currentUser,
    Account account,
  ) {
    if (_currentUserId == null) return const SizedBox.shrink();

    final hasMultipleMembers = account.memberCount > 1;
    final hasOtherAdmins =
        account.adminCount > 1 ||
        (account.adminCount == 1 && !account.isAdmin(_currentUserId!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            AppLocalizations.of(context)!.actions,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        if (hasMultipleMembers && hasOtherAdmins)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Icon(
                Icons.exit_to_app,
                color: theme.colorScheme.error,
                size: 24,
              ),
              title: Text(
                AppLocalizations.of(context)!.exitAccountAction,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              onTap: () => _exitAccount(account),
            ),
          ),
      ],
    );
  }

  Future<void> _loadTransactionData() async {
    if (!mounted) return;

    try {
      await TransactionService.instance.initialize();

      final balance = await TransactionService.instance.getAccountBalance(
        widget.account.id,
      );
      final income = await TransactionService.instance.getAccountIncome(
        widget.account.id,
      );
      final expenses = await TransactionService.instance.getAccountExpenses(
        widget.account.id,
      );
      final recentTransactions = await TransactionService.instance
          .getRecentAccountTransactions(widget.account.id, limit: 5);

      if (mounted) {
        setState(() {
          _accountBalance = balance;
          _totalIncome = income;
          _totalExpenses = expenses;
          _recentTransactions = recentTransactions;
          _isLoadingTransactions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTransactions = false;
        });
        debugPrint('Error loading transaction data: $e');
      }
    }
  }

  Widget _buildTransactionSummarySection(ThemeData theme, Account account) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.balance,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              if (_isLoadingTransactions)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Text(
                  _formatAmount(_accountBalance, account),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color:
                        _accountBalance >= 0
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                  ),
                ),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_downward,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context)!.income,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatAmount(_totalIncome, account),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outlineVariant,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.expense,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_upward, size: 16, color: Colors.red),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatAmount(_totalExpenses, account),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(ThemeData theme, Account account) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildQuickActionButton(
            theme,
            icon: Icons.add,
            label: AppLocalizations.of(context)!.addTransaction,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => AddEditTransactionScreen(account: account),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          _buildQuickActionButton(
            theme,
            icon: Icons.list,
            label: AppLocalizations.of(context)!.transactions,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TransactionListScreen(account: account),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          _buildQuickActionButton(
            theme,
            icon: Icons.pie_chart,
            label: AppLocalizations.of(context)!.analytics,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.analyticsComingSoon,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsSection(ThemeData theme, Account account) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.recentTransactions,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => TransactionListScreen(account: account),
                    ),
                  );
                },
                child: Text(AppLocalizations.of(context)!.viewAll),
              ),
            ],
          ),
        ),
        if (_isLoadingTransactions)
          const Center(child: CircularProgressIndicator())
        else if (_recentTransactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.noTransactions,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentTransactions.length,
            itemBuilder: (context, index) {
              final transaction = _recentTransactions[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      transaction.type == 'income'
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                  child: Icon(
                    transaction.type == 'income'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: transaction.type == 'income' ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ),
                title: Text(transaction.description),
                subtitle: Text(
                  transaction.transactionDate.toString().split(' ')[0],
                ),
                trailing: Text(
                  _formatAmount(transaction.amount, account),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        transaction.type == 'income' ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
