import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../notifiers/terms_conditions_notifier.dart';
import '../services/terms_conditions_services.dart';

final termsConditionsServicesProvider = Provider<TermsConditionsServices>((ref) {
  return TermsConditionsServices();
});

final termsConditionsProvider = StateNotifierProvider<TermsConditionsNotifier, TermsConditionsState>((ref) {
  final services = ref.watch(termsConditionsServicesProvider);
  return TermsConditionsNotifier(services);
});
