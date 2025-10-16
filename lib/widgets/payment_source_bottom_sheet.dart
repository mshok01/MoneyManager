import 'package:flutter/material.dart';
import '../models/payment_source.dart';
import '../l10n/app_localizations.dart';

class PaymentSourceBottomSheet extends StatelessWidget {
  final List<PaymentSource> paymentSources;
  final PaymentSource? selectedPaymentSource;
  final Function(PaymentSource) onPaymentSourceSelected;

  const PaymentSourceBottomSheet({
    super.key,
    required this.paymentSources,
    required this.selectedPaymentSource,
    required this.onPaymentSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  l10n.selectPaymentSource,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Payment sources list
          Flexible(
            child: paymentSources.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.payment_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noPaymentSourcesAvailable,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: paymentSources.length,
                    itemBuilder: (context, index) {
                      final paymentSource = paymentSources[index];
                      final isSelected =
                          paymentSource.id == selectedPaymentSource?.id;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: paymentSource.color.withValues(
                            alpha: 0.2,
                          ),
                          child: Icon(
                            paymentSource.icon,
                            color: paymentSource.color,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          paymentSource.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                        ),
                        subtitle: paymentSource.description.isNotEmpty
                            ? Text(
                                paymentSource.description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              )
                            : null,
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                        onTap: () => onPaymentSourceSelected(paymentSource),
                      );
                    },
                  ),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}
