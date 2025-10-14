import 'package:flutter/material.dart';
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
        throw Exception('No user logged in');
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
          const SnackBar(content: Text('Account created successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create account: $e')));
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
    final profilePicOptions = [
      {
        'icon': Icons.account_balance_wallet,
        'color': Colors.blue,
        'name': 'Wallet',
      },
      {'icon': Icons.home, 'color': Colors.green, 'name': 'Home'},
      {'icon': Icons.business, 'color': Colors.orange, 'name': 'Business'},
      {'icon': Icons.savings, 'color': Colors.purple, 'name': 'Savings'},
      {'icon': Icons.credit_card, 'color': Colors.red, 'name': 'Credit'},
      {'icon': Icons.account_balance, 'color': Colors.teal, 'name': 'Bank'},
      {'icon': Icons.shopping_cart, 'color': Colors.pink, 'name': 'Shopping'},
      {'icon': Icons.car_rental, 'color': Colors.indigo, 'name': 'Vehicle'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Choose Profile Picture',
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
                  child: const Text('Remove'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
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
    final profilePicMap = {
      'Wallet': {'icon': Icons.account_balance_wallet, 'color': Colors.blue},
      'Home': {'icon': Icons.home, 'color': Colors.green},
      'Business': {'icon': Icons.business, 'color': Colors.orange},
      'Savings': {'icon': Icons.savings, 'color': Colors.purple},
      'Credit': {'icon': Icons.credit_card, 'color': Colors.red},
      'Bank': {'icon': Icons.account_balance, 'color': Colors.teal},
      'Shopping': {'icon': Icons.shopping_cart, 'color': Colors.pink},
      'Vehicle': {'icon': Icons.car_rental, 'color': Colors.indigo},
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Account'),
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
                    'Tap to select picture',
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
              decoration: const InputDecoration(
                labelText: 'Account Name *',
                border: OutlineInputBorder(),
                helperText: 'Required',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Account name is required';
                }
                if (value.trim().length < 2) {
                  return 'Account name must be at least 2 characters';
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
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                helperText: 'Optional - Add a brief description',
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
                    child: const Text('Cancel'),
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
                        : const Text('Create'),
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
