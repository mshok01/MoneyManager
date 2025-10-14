import 'package:flutter/material.dart';
import '../services/account_service.dart';
import '../services/user_service.dart';
import '../models/account.dart';

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

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.account.name;
    _descriptionController.text = widget.account.description;
    _currentUserId = UserService.instance.currentUser?.id;

    // Listen for changes
    _nameController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
          const SnackBar(content: Text('Account updated successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update account: $e')));
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete "${widget.account.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
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
            const SnackBar(content: Text('Account deleted successfully')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete account: $e')),
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
          tooltip: 'Exit Account',
        ),
      );
    }

    // Show delete option only for admins and not if only one member
    if (isAdmin && !isOnlyMember) {
      actions.add(
        IconButton(
          onPressed: _deleteAccount,
          icon: const Icon(Icons.delete),
          tooltip: 'Delete Account',
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
          title: const Text('Cannot Exit Account'),
          content: const Text(
            'You are the only admin of this account. Please make another member an admin before exiting.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Account'),
        content: Text(
          'Are you sure you want to exit "${widget.account.name}"? You will no longer have access to this account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Exit'),
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
            const SnackBar(content: Text('Successfully exited account')),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to exit account: $e')));
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
              tooltip: 'Save',
            ),
            IconButton(
              onPressed: _isLoading ? null : _toggleEdit,
              icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
              tooltip: 'Cancel',
            ),
          ] else ...[
            IconButton(
              onPressed: _toggleEdit,
              icon: Icon(Icons.edit, color: theme.colorScheme.primary),
              tooltip: 'Edit',
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
              labelText: 'Account Name',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(
                Icons.account_balance_wallet,
                color: theme.colorScheme.primary,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Account name is required';
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
              labelText: 'Description (Optional)',
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

        // Members Section
        _buildMembersSection(theme, currentUser),

        // Add Member Section
        _buildAddMemberSection(theme),

        // Account Settings Section
        _buildAccountSettingsSection(theme),

        // Actions Section
        _buildActionsSection(theme),
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
        Text(
          'Members (${widget.account.memberCount})',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Card(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  isCurrentUser ? 'You' : 'Member',
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
                                      'CREATOR',
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
                                      'ADMIN',
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
                            Text(
                              memberId,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
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
          'Add member',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        onTap: () {
          // TODO: Implement add member functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add member functionality coming soon!'),
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
            'Account Settings',
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
            'Actions',
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
                'EXIT ACCOUNT',
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
}
