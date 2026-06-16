import 'package:flutter/material.dart';
import '../../models/about_us.dart';
import '../../theme/app_theme.dart';
import '../../services/api_url.dart';

class CompanyHeaderCard extends StatelessWidget {
  final AboutUsModel aboutUs;

  const CompanyHeaderCard({super.key, required this.aboutUs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: aboutUs.companyPhoto != null
                ? Image.network(
                    ApiUrl.imageUrl(aboutUs.companyPhoto!),
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/logo/naiyo_black_nobg.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  )
                : Image.asset(
                    'assets/logo/naiyo_black_nobg.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            aboutUs.companyName,
            style: AppTextStyles.header.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          if (aboutUs.companyTagline != null) ...[
            const SizedBox(height: 8),
            Text(
              aboutUs.companyTagline!,
              style: AppTextStyles.tagline,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
