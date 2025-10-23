import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/payment_source.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/payment_source_providers.dart';
import '../../services/payment_source_service.dart';
import 'add_payment_source_screen.dart';
import 'edit_payment_source_screen.dart';

class PaymentSourcesScreen extends ConsumerStatefulWidget {
  const PaymentSourcesScreen({super.key});

  @override
  ConsumerState<PaymentSourcesScreen> createState() =>
      _PaymentSourcesScreenState();
}

class _PaymentSourcesScreenState extends ConsumerState<PaymentSourcesScreen> {
  bool _isSyncing = false;

  Future<void> _handleSync() async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);

    try {
      // Fetch payment sources from backend
      await PaymentSourceService.instance.fetchPaymentSourcesFromBackend();

      // Refresh the provider
      // ignore: unused_result
      ref.refresh(paymentSourcesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.paymentSourcesSyncCompleted,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.failedToSyncPaymentSources(e.toString()),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  void _addNewPaymentSource(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddPaymentSourceScreen()),
    );
  }

  void _editPaymentSource(BuildContext context, PaymentSource source) {
    if (source.isDefault) return; // Cannot edit default sources

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditPaymentSourceScreen(paymentSource: source),
      ),
    );
  }

  void _deletePaymentSource(
    BuildContext context,
    PaymentSource source,
    WidgetRef ref,
  ) {
    if (source.isDefault) return; // Cannot delete default sources

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.deletePaymentSource),
          content: Text(l10n.deletePaymentSourceConfirmation(source.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                final dialogContext = context;
                try {
                  // Delete from backend asynchronously (offline-first)
                  await PaymentSourceService.instance.deletePaymentSource(
                    source.id,
                  );

                  // Invalidate providers to refresh data
                  ref.invalidate(paymentSourcesProvider);
                  ref.invalidate(customPaymentSourcesProvider);

                  if (context.mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text(l10n.paymentSourceDeleted)),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentSourcesAsync = ref.watch(paymentSourcesProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.paymentSources),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          if (_isSyncing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: _handleSync,
              tooltip: l10n.syncPaymentSources,
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addNewPaymentSource(context),
            tooltip: l10n.addPaymentSource,
          ),
        ],
      ),
      body: paymentSourcesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(l10n.failedToLoadPaymentSources(error.toString())),
        ),
        data: (paymentSources) {
          return paymentSources.isEmpty
              ? Center(child: Text(l10n.noPaymentSourcesAvailable))
              : ListView.builder(
                  itemCount: paymentSources.length,
                  itemBuilder: (context, index) {
                    final source = paymentSources[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: source.color.withValues(alpha: 0.2),
                          child: Icon(source.icon, color: source.color),
                        ),
                        title: Text(source.name),
                        subtitle: Text(source.description),
                        trailing: source.isDefault
                            ? null
                            : PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _editPaymentSource(context, source);
                                  } else if (value == 'delete') {
                                    _deletePaymentSource(context, source, ref);
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Text(l10n.edit),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text(l10n.delete),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}

