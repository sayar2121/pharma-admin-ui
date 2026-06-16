import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../theme/app_theme.dart';

class ProfileOptionsCard extends StatelessWidget {
  const ProfileOptionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            'ACCOUNT SETTINGS',
            style: AppTextStyles.tagline.copyWith(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        _buildOption(
          icon: Iconsax.user_edit,
          title: 'Update Account',
          subtitle: 'Manage your shop details',
          color: AppColors.primary,
          onTap: () => context.push('/update-profile'),
        ),
        const SizedBox(height: 12),
        _buildOption(
          icon: Iconsax.notification,
          title: 'Notifications',
          subtitle: 'Alerts and updates',
          color: AppColors.purple,
          onTap: () => context.push('/notifications'),
        ),
        const SizedBox(height: 12),
        _buildOption(
          icon: Iconsax.wallet_money,
          title: 'Payments & Earnings',
          subtitle: 'Track your revenue',
          color: AppColors.online,
          onTap: () => context.push('/earnings'),
        ),
        const SizedBox(height: 12),
        _buildOption(
          icon: Iconsax.setting_2,
          title: 'Settings',
          subtitle: 'Privacy and preferences',
          color: AppColors.silver,
          onTap: () => context.push('/settings'),
        ),
      ],
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: color.withAlpha(30), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          highlightColor: color.withAlpha(10),
          splashColor: color.withAlpha(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.cardTitle.copyWith(
                          fontSize: 17, 
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.arrow_right_3,
                    size: 18,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
