import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/terms_conditions_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../cards/terms_conditions/terms_conditions_card.dart';

class TermsConditionsScreen extends ConsumerWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(termsConditionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Terms & Conditions',
        subtitle: 'LEGAL AGREEMENT',
        showBackButton: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(child: Text('Error: ${state.error}'))
          : state.termsList.isEmpty
          ? const Center(child: Text('No terms found'))
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(termsConditionsProvider.notifier).fetchTerms(),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                itemCount: state.termsList.length,
                itemBuilder: (context, index) {
                  return TermsConditionsCard(term: state.termsList[index]);
                },
              ),
            ),
    );
  }
}
