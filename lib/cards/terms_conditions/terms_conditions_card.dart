import 'package:flutter/material.dart';
import '../../models/terms_conditions.dart';
import '../../theme/app_theme.dart';

class TermsConditionsCard extends StatelessWidget {
  final TermsConditionsModel term;

  const TermsConditionsCard({super.key, required this.term});

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
            term.termHeader,
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            term.termDescription,
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
