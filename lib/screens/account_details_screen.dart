import 'package:flutter/material.dart';
import '../services/account_service.dart';
import '../services/user_service.dart';
import '../services/transaction_service.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../l10n/app_localizations.dart';
import '../utils/currency_utils.dart';
import 'transaction_list_screen.dart';
import 'add_edit_transaction_screen.dart';

class AccountDetailsScreen extends StatefulWidget {
  final Account account;

  const AccountDetailsScreen({super.key, required this.account});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
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
  String _formatAmount(double amount) {
    final currentUser = UserService.instance.currentUser;
    final userCurrency =
        currentUser?.currencyCode ?? widget.account.baseCurrency;
    final currencySymbol = CurrencyUtils.getCurrencySymbol(userCurrency);

    // For now, we're storing amounts in account currency, so we show them as-is
    // In the future, this would convert from account currency to user currency
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  void _onFieldChanged() {
    final hasChanges =
        _nameController.text != widget.account.name ||
        _descriptionController.text != widget.account.description;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  bool _hasAccountSettings() {
    // Currently no account settings are implemented
    return false;
  }

  bool _hasActions() {
    if (_currentUserId == null) return false;

    final hasMultipleMembers = widget.account.memberCount > 1;
    final hasOtherAdmins =
        widget.account.adminCount > 1 ||
        (widget.account.adminCount == 1 &&
            !widget.account.isAdmin(_currentUserId!));

    // Only show actions if there are actions to display
    return hasMultipleMembers && hasOtherAdmins;
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset fields if canceling edit
        _nameController.text = widget.account.name;
        _descriptionController.text = widget.account.description;
        _hasChanges = false;
      }
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AccountService.instance.updateAccount(
        widget.account.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
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
      builder: (context) => AlertDialog(
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
        await AccountService.instance.deleteAccount(widget.account.id);

        if (mounted) {
          Navigator.of(context).pop();
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

  List<Widget> _buildActionButtons() {
    if (_currentUserId == null) return [];

    final isAdmin = widget.account.hasAdminPrivileges(_currentUserId!);
    final isOnlyMember = widget.account.memberCount == 1;
    final hasMultipleMembers = widget.account.memberCount > 1;
    final hasOtherAdmins =
        widget.account.adminCount > 1 ||
        (widget.account.adminCount == 1 &&
            !widget.account.isAdmin(_currentUserId!));

    List<Widget> actions = [];

    // Show exit option if multiple members and there are other admins
    if (hasMultipleMembers && hasOtherAdmins) {
      actions.add(
        IconButton(
          onPressed: _exitAccount,
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

  Future<void> _exitAccount() async {
    if (_currentUserId == null) return;

    final isAdmin = widget.account.isAdmin(_currentUserId!);
    final hasOtherAdmins =
        widget.account.adminCount > 1 ||
        (widget.account.adminCount == 1 &&
            !widget.account.isAdmin(_currentUserId!));

    // Check if admin is trying to exit without other admins
    if (isAdmin && !hasOtherAdmins) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.cannotExitAccount),
          content: Text(AppLocalizations.of(context)!.cannotExitAccountMessage),
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
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.exitAccount),
        content: Text(
          AppLocalizations.of(
            context,
          )!.exitAccountConfirmation(widget.account.name),
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
        await AccountService.instance.removeMemberFromAccount(
          widget.account.id,
          _currentUserId!,
        );

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
            // Account Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Text(
                widget.account.name.isNotEmpty
                    ? widget.account.name.substring(0, 2).toUpperCase()
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
                widget.account.name,
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
              onPressed: _isLoading ? null : _saveChanges,
              icon: _isLoading
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
              onPressed: _isLoading ? null : _toggleEdit,
              icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
              tooltip: AppLocalizations.of(context)!.cancel,
            ),
          ] else ...[
            IconButton(
              onPressed: _toggleEdit,
              icon: Icon(Icons.edit, color: theme.colorScheme.primary),
              tooltip: AppLocalizations.of(context)!.edit,
            ),
            ..._buildActionButtons(),
          ],
        ],
      ),
      body: _isEditing
          ? _buildEditForm(theme)
          : _buildViewContent(theme, currentUser),
    );
  }

  Widget _buildEditForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Name
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
          // Account Description
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

  Widget _buildViewContent(ThemeData theme, currentUser) {
    return ListView(
      children: [
        // Account Profile Section
        _buildAccountProfileSection(theme),

        // Transaction Summary Section
        _buildTransactionSummarySection(theme),

        // Quick Actions Section
        _buildQuickActionsSection(theme),

        // Recent Transactions Section
        _buildRecentTransactionsSection(theme),

        // Members Section
        _buildMembersSection(theme, currentUser),

        // Add Member Section
        _buildAddMemberSection(theme),

        // Account Settings Section (only show if has content)
        if (_hasAccountSettings()) _buildAccountSettingsSection(theme),

        // Actions Section (only show if has content)
        if (_hasActions()) _buildActionsSection(theme),
      ],
    );
  }

  Widget _buildAccountProfileSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Large Account Avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              widget.account.name.isNotEmpty
                  ? widget.account.name.substring(0, 2).toUpperCase()
                  : 'AC',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Account Name
          Text(
            widget.account.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),

          // Account Description
          if (widget.account.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.account.description,
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

  Widget _buildMembersSection(ThemeData theme, currentUser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            AppLocalizations.of(context)!.members(widget.account.memberCount),
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
                children: widget.account.members.map((memberId) {
                  final isCurrentUser = memberId == _currentUserId;
                  final isCreator = widget.account.isCreator(memberId);
                  final isAdmin = widget.account.isAdmin(memberId);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
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
          // TODO: Implement add member functionality
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
        // Section Header
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

        // Settings items would go here if needed
        // For now, we'll keep it minimal
      ],
    );
  }

  Widget _buildActionsSection(ThemeData theme) {
    if (_currentUserId == null) return const SizedBox.shrink();

    final hasMultipleMembers = widget.account.memberCount > 1;
    final hasOtherAdmins =
        widget.account.adminCount > 1 ||
        (widget.account.adminCount == 1 &&
            !widget.account.isAdmin(_currentUserId!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Actions Header
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

        // Exit Account (if conditions are met)
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
              onTap: _exitAccount,
            ),
          ),
      ],
    );
  }

  // Transaction-related methods
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
      }
    }
  }

  Widget _buildTransactionSummarySection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Account Balance',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isLoadingTransactions)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    // Balance
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _accountBalance >= 0
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Current Balance',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatAmount(_accountBalance),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _accountBalance >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Income and Expenses
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.trending_up, color: Colors.green),
                                const SizedBox(height: 4),
                                Text(
                                  'Income',
                                  style: theme.textTheme.bodySmall,
                                ),
                                Text(
                                  _formatAmount(_totalIncome),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.trending_down, color: Colors.red),
                                const SizedBox(height: 4),
                                Text(
                                  'Expenses',
                                  style: theme.textTheme.bodySmall,
                                ),
                                Text(
                                  _formatAmount(_totalExpenses),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _addTransaction(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Transaction'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewAllTransactions(),
                      icon: const Icon(Icons.list),
                      label: const Text('View All'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_recentTransactions.isNotEmpty)
                    TextButton(
                      onPressed: () => _viewAllTransactions(),
                      child: const Text('View All'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isLoadingTransactions)
                const Center(child: CircularProgressIndicator())
              else if (_recentTransactions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 48,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No transactions yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add your first transaction to get started',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: _recentTransactions.map((transaction) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: transaction.isIncome
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        child: Icon(
                          transaction.isIncome
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 16,
                          color: transaction.isIncome
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      title: Text(
                        transaction.description.isNotEmpty
                            ? transaction.description
                            : 'Transaction',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '${transaction.transactionDateTime.day}/${transaction.transactionDateTime.month}/${transaction.transactionDateTime.year}',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      trailing: Text(
                        '${transaction.isIncome ? '+' : '-'}${_formatAmount(transaction.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: transaction.isIncome
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addTransaction() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddEditTransactionScreen(account: widget.account),
      ),
    );

    if (result == true) {
      _loadTransactionData(); // Reload transaction data
    }
  }

  Future<void> _viewAllTransactions() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionListScreen(account: widget.account),
      ),
    );
    _loadTransactionData(); // Reload transaction data when returning
  }
}
