import 'package:flutter/material.dart';
import '../../models/privacy_policy.dart';
import '../../theme/app_theme.dart';

class PrivacyPolicyCard extends StatelessWidget {
  final PrivacyPolicyModel policy;

  const PrivacyPolicyCard({super.key, required this.policy});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: AppCardStyles.sleekCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            policy.privacyHeader,
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            policy.privacyDescription,
            style: AppTextStyles.description.copyWith(
              height: 1.6,
              color: AppColors.textPrimary.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }
}
