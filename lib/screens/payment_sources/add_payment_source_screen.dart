import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/payment_source_providers.dart';
import '../../services/payment_source_service.dart';
import '../../services/user_service.dart';

class AddPaymentSourceScreen extends ConsumerStatefulWidget {
  const AddPaymentSourceScreen({super.key});

  @override
  ConsumerState<AddPaymentSourceScreen> createState() =>
      _AddPaymentSourceScreenState();
}

class _AddPaymentSourceScreenState
    extends ConsumerState<AddPaymentSourceScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  late FocusNode _nameFocusNode;
  late FocusNode _descriptionFocusNode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _savePaymentSource() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseEnterName)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = UserService.instance.currentUser?.id ?? 'user';

      // Create new payment source (offline-first)
      await PaymentSourceService.instance.createPaymentSource(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        icon: Icons.payment,
        color: Colors.blue,
        createdBy: userId,
        accessTo: [userId],
      );

      // Invalidate the providers to refresh data
      ref.invalidate(paymentSourcesProvider);
      ref.invalidate(customPaymentSourcesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.paymentSourceCreatedSuccessfully,
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        // Pop back to payment sources screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addPaymentSource),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) {
                _nameFocusNode.unfocus();
                FocusScope.of(context).requestFocus(_descriptionFocusNode);
              },
              decoration: InputDecoration(
                labelText: l10n.name,
                hintText: l10n.nameHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              focusNode: _descriptionFocusNode,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                _descriptionFocusNode.unfocus();
              },
              decoration: InputDecoration(
                labelText: l10n.description,
                hintText: l10n.descriptionHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
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
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _savePaymentSource,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    child: Text(
                      l10n.add,
                      style: TextStyle(color: theme.colorScheme.onPrimary),
                    ),
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
