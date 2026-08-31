import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/user_details_provider.dart';
import '../theme/app_theme.dart';

class EditUserProfileScreen extends ConsumerStatefulWidget {
  const EditUserProfileScreen({super.key});

  @override
  ConsumerState<EditUserProfileScreen> createState() =>
      _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends ConsumerState<EditUserProfileScreen> {
  late TextEditingController _nameController;
  late FocusNode _nameFocusNode;
  late String _selectedProfilePic;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize with empty values, will be populated from provider in build
    _nameController = TextEditingController();
    _nameFocusNode = FocusNode();
    _selectedProfilePic = '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(
        updateUserProvider((
          email: null,
          name: _nameController.text.trim(),
          profilePic: _selectedProfilePic,
          isActive: null,
          currencyCode: null,
          currencyName: null,
        )).future,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileUpdatedSuccessfully)),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _selectProfilePicture() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildProfilePictureSelector(),
    );
  }

  Widget _buildProfilePictureSelector() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final profilePicOptions = [
      {
        'icon': Icons.account_balance_wallet,
        'color': Colors.blue,
        'name': l10n.wallet,
      },
      {'icon': Icons.home, 'color': Colors.green, 'name': l10n.home},
      {'icon': Icons.business, 'color': Colors.orange, 'name': l10n.business},
      {'icon': Icons.savings, 'color': Colors.purple, 'name': l10n.savings},
      {'icon': Icons.credit_card, 'color': Colors.red, 'name': l10n.credit},
      {'icon': Icons.account_balance, 'color': Colors.teal, 'name': l10n.bank},
      {
        'icon': Icons.shopping_cart,
        'color': Colors.pink,
        'name': l10n.shopping,
      },
      {'icon': Icons.car_rental, 'color': Colors.indigo, 'name': l10n.vehicle},
      {'icon': Icons.person, 'color': Colors.amber, 'name': 'Avatar'},
      {'icon': Icons.star, 'color': Colors.yellow, 'name': 'Star'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.chooseProfilePicture,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: profilePicOptions.length,
            itemBuilder: (context, index) {
              final option = profilePicOptions[index];
              final isSelected = _selectedProfilePic == option['name'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedProfilePic = option['name'] as String;
                  });
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: theme.colorScheme.primary, width: 3)
                        : null,
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: (option['color'] as Color).withValues(
                      alpha: 0.2,
                    ),
                    child: Icon(
                      option['icon'] as IconData,
                      color: option['color'] as Color,
                      size: 30,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedProfilePic = '';
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.remove),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.done),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePictureDisplay(ThemeData theme) {
    if (_selectedProfilePic.isEmpty) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.add_a_photo,
          size: 40,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final profilePicMap = {
      l10n.wallet: {'icon': Icons.account_balance_wallet, 'color': Colors.blue},
      l10n.home: {'icon': Icons.home, 'color': Colors.green},
      l10n.business: {'icon': Icons.business, 'color': Colors.orange},
      l10n.savings: {'icon': Icons.savings, 'color': Colors.purple},
      l10n.credit: {'icon': Icons.credit_card, 'color': Colors.red},
      l10n.bank: {'icon': Icons.account_balance, 'color': Colors.teal},
      l10n.shopping: {'icon': Icons.shopping_cart, 'color': Colors.pink},
      l10n.vehicle: {'icon': Icons.car_rental, 'color': Colors.indigo},
      'Avatar': {'icon': Icons.person, 'color': Colors.amber},
      'Star': {'icon': Icons.star, 'color': Colors.yellow},
    };

    final option = profilePicMap[_selectedProfilePic];
    if (option == null) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.account_circle,
          size: 40,
          color: theme.colorScheme.primary,
        ),
      );
    }

    return CircleAvatar(
      radius: 60,
      backgroundColor: (option['color'] as Color).withValues(alpha: 0.2),
      child: Icon(
        option['icon'] as IconData,
        size: 50,
        color: option['color'] as Color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Fetch current user from provider
    final currentUser = ref.watch(currentUserProvider);

    // Initialize form fields from provider data on first build
    if (currentUser != null && _nameController.text.isEmpty) {
      _nameController.text = currentUser.name;
      _selectedProfilePic = currentUser.profilePic;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editUserProfile), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppTheme.spacingMd),

                // Profile Picture Section
                GestureDetector(
                  onTap: _selectProfilePicture,
                  child: Stack(
                    children: [
                      _buildProfilePictureDisplay(theme),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  l10n.tapToSelectPicture,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),

                // Name Input Field
                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    _nameFocusNode.unfocus();
                  },
                  decoration: InputDecoration(
                    labelText: l10n.name,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingLg),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveChanges,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isLoading ? l10n.saving : l10n.save),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingMd,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
