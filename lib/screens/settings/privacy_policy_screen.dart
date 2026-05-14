import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/privacy_policy_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../cards/settings/privacy_policy_card.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(privacyPolicyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Privacy Policy',
        subtitle: 'DATA PROTECTION',
        showBackButton: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text('Error: ${state.error}'))
              : state.policiesList.isEmpty
                  ? const Center(child: Text('No policies found'))
                  : RefreshIndicator(
                      onRefresh: () => ref.read(privacyPolicyProvider.notifier).fetchPolicies(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.screenPadding),
                        itemCount: state.policiesList.length,
                        itemBuilder: (context, index) {
                          return PrivacyPolicyCard(policy: state.policiesList[index]);
                        },
                      ),
                    ),
    );
  }
}
