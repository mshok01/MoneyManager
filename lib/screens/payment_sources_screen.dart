import 'package:flutter/material.dart';
import 'package:money_manager/utils/utils.dart';
import '../models/payment_source.dart';
import '../services/data_service.dart';
import '../l10n/app_localizations.dart';

class PaymentSourcesScreen extends StatefulWidget {
  const PaymentSourcesScreen({super.key});

  @override
  State<PaymentSourcesScreen> createState() => _PaymentSourcesScreenState();
}

class _PaymentSourcesScreenState extends State<PaymentSourcesScreen> {
  // Payment sources loaded from DataService
  List<PaymentSource> _defaultSources = [];
  final List<PaymentSource> _customSources = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentSources();
  }

  Future<void> _loadPaymentSources() async {
    try {
      // Ensure DataService is initialized
      if (!DataService.instance.isInitialized) {
        await DataService.instance.initialize();
      }

      final defaultSources = await DataService.instance.getPaymentSources();

      setState(() {
        _defaultSources = defaultSources;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.failedToLoadPaymentSources(e.toString()),
            ),
          ),
        );
      }
    }
  }

  void _addNewPaymentSource() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _AddPaymentSourceDialog(
          onAdd: (PaymentSource source) {
            setState(() {
              _customSources.add(source);
            });
          },
        );
      },
    );
  }

  void _editPaymentSource(PaymentSource source) {
    if (source.isDefault) return; // Cannot edit default sources

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _AddPaymentSourceDialog(
          existingSource: source,
          onAdd: (PaymentSource updatedSource) {
            setState(() {
              final index = _customSources.indexWhere((s) => s.id == source.id);
              if (index != -1) {
                _customSources[index] = updatedSource;
              }
            });
          },
        );
      },
    );
  }

  void _deletePaymentSource(PaymentSource source) {
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
              onPressed: () {
                setState(() {
                  _customSources.removeWhere((s) => s.id == source.id);
                });
                Navigator.of(context).pop();
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final allSources = [..._defaultSources, ..._customSources];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.paymentSources),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : allSources.isEmpty
          ? Center(child: Text(l10n.noPaymentSourcesAvailable))
          : ListView.builder(
              itemCount: allSources.length,
              itemBuilder: (context, index) {
                final source = allSources[index];
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
                        ? Chip(
                            label: Text(l10n.defaultSource),
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                          )
                        : PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editPaymentSource(source);
                              } else if (value == 'delete') {
                                _deletePaymentSource(source);
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
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewPaymentSource,
        tooltip: l10n.addPaymentSource,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddPaymentSourceDialog extends StatefulWidget {
  final PaymentSource? existingSource;
  final Function(PaymentSource) onAdd;

  const _AddPaymentSourceDialog({this.existingSource, required this.onAdd});

  @override
  State<_AddPaymentSourceDialog> createState() =>
      _AddPaymentSourceDialogState();
}

class _AddPaymentSourceDialogState extends State<_AddPaymentSourceDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingSource != null) {
      _nameController.text = widget.existingSource!.name;
      _descriptionController.text = widget.existingSource!.description;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _savePaymentSource() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseEnterName)),
      );
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final isEditing = widget.existingSource != null;

    final source = PaymentSource(
      id: isEditing ? widget.existingSource!.id : getUniqueId(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      icon: Icons.payment,
      color: Colors.blue,
      isDefault: false,
      createdBy: isEditing
          ? widget.existingSource!.createdBy
          : 'user', // Default user identifier for custom sources
      createdAt: isEditing ? widget.existingSource!.createdAt : now,
      updatedAt: now,
      accessTo: isEditing
          ? widget.existingSource!.accessTo
          : ['user'], // Default access list for custom sources
    );

    widget.onAdd(source);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingSource != null;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(isEditing ? l10n.editPaymentSource : l10n.addPaymentSource),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.name,
                hintText: l10n.nameHint,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.description,
                hintText: l10n.descriptionHint,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _savePaymentSource,
          child: Text(isEditing ? l10n.update : l10n.add),
        ),
      ],
    );
  }
}
