import 'package:riverpod/riverpod.dart';
import '../models/payment_source.dart';
import '../services/payment_source_service.dart';

/// Provider for PaymentSourceService singleton
final paymentSourceServiceProvider = Provider<PaymentSourceService>((ref) {
  return PaymentSourceService.instance;
});

/// Provider to fetch all payment sources
/// Usage: ref.watch(paymentSourcesProvider)
final paymentSourcesProvider = FutureProvider<List<PaymentSource>>((ref) async {
  final paymentSourceService = ref.watch(paymentSourceServiceProvider);
  return paymentSourceService.getAllPaymentSources();
});

/// Provider to fetch default payment sources
/// Usage: ref.watch(defaultPaymentSourcesProvider)
final defaultPaymentSourcesProvider =
    FutureProvider<List<PaymentSource>>((ref) async {
  final paymentSourceService = ref.watch(paymentSourceServiceProvider);
  return paymentSourceService.getDefaultPaymentSources();
});

/// Provider to fetch custom payment sources (non-default)
/// Usage: ref.watch(customPaymentSourcesProvider)
final customPaymentSourcesProvider =
    FutureProvider<List<PaymentSource>>((ref) async {
  final paymentSourceService = ref.watch(paymentSourceServiceProvider);
  return paymentSourceService.getCustomPaymentSources();
});

