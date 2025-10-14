import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/account_service.dart';
import '../services/user_service.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _selectedProfilePic = '';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = UserService.instance.currentUser;
      if (currentUser == null) {
        throw Exception(AppLocalizations.of(context)!.noUserLoggedIn);
      }

      await AccountService.instance.createAccount(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        pic: _selectedProfilePic,
        createdBy: currentUser.id,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.accountCreatedSuccessfully,
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
              AppLocalizations.of(context)!.failedToCreateAccount(e.toString()),
            ),
          ),
        );
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

    // Predefined profile picture options
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

  Widget _buildSelectedProfilePic(ThemeData theme) {
    if (_selectedProfilePic.isEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.add_a_photo,
          size: 30,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    }

    // Map profile pic name to icon and color
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
    };

    final option = profilePicMap[_selectedProfilePic];
    if (option == null) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.account_balance_wallet,
          size: 30,
          color: theme.colorScheme.primary,
        ),
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundColor: (option['color'] as Color).withValues(alpha: 0.2),
      child: Icon(
        option['icon'] as IconData,
        size: 40,
        color: option['color'] as Color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addNewAccount),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Picture Section
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _selectProfilePicture,
                    child: Stack(
                      children: [
                        _buildSelectedProfilePic(theme),
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
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tapToSelectPicture,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Account Name (Required)
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.accountNameStar,
                border: const OutlineInputBorder(),
                helperText: l10n.required,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.accountNameRequired;
                }
                if (value.trim().length < 2) {
                  return l10n.accountNameMinLength;
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            // Account Description (Optional)
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.description,
                border: const OutlineInputBorder(),
                helperText: l10n.optionalDescription,
                alignLabelWithHint: true,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createAccount,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.create),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
