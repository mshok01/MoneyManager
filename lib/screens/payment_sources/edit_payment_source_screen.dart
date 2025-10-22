import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/payment_source.dart';
import '../../providers/payment_source_providers.dart';
import '../../services/payment_source_service.dart';

class EditPaymentSourceScreen extends ConsumerStatefulWidget {
  final PaymentSource paymentSource;

  const EditPaymentSourceScreen({
    super.key,
    required this.paymentSource,
  });

  @override
  ConsumerState<EditPaymentSourceScreen> createState() =>
      _EditPaymentSourceScreenState();
}

class _EditPaymentSourceScreenState
    extends ConsumerState<EditPaymentSourceScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.paymentSource.name);
    _descriptionController =
        TextEditingController(text: widget.paymentSource.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updatePaymentSource() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseEnterName)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update payment source via service (offline-first)
      await PaymentSourceService.instance.updatePaymentSource(
        widget.paymentSource.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      // Invalidate the providers to refresh data
      ref.invalidate(paymentSourcesProvider);
      ref.invalidate(customPaymentSourcesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment source \'${_nameController.text.trim()}\' updated successfully',
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
        title: Text(l10n.editPaymentSource),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
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
                    onPressed: _isLoading ? null : _updatePaymentSource,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    child: Text(
                      l10n.update,
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

