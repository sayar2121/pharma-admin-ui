import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/side_nav_bar.dart';
import '../../cards/settings/settings_card.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/dashboard');
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
      drawer: SideNavBar(
        selectedIndex: 6, // Index for Settings
        onItemSelected: (index) {},
      ),
      appBar: const CustomAppBar(
        title: 'Settings',
        subtitle: 'APP PREFERENCES',
        showDrawer: true,
      ),
      body: settingsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('General'),
                  SettingsCard(
                    title: 'About Us',
                    icon: Iconsax.info_circle,
                    onTap: () => context.push('/about-us'),
                  ),
                  SettingsCard(
                    title: 'Terms and Conditions',
                    icon: Iconsax.document_text,
                    onTap: () => context.push('/terms-conditions'),
                  ),
                  SettingsCard(
                    title: 'Privacy and Policies',
                    icon: Iconsax.shield_tick,
                    onTap: () => context.push('/privacy-policy'),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Support'),
                  SettingsCard(
                    title: 'Give Feedback',
                    icon: Iconsax.message_edit,
                    onTap: () => context.push('/feedback'),
                  ),
                  SettingsCard(
                    title: 'Report a Problem',
                    icon: Iconsax.danger,
                    onTap: () => context.push('/report-problem'),
                  ),
                  SettingsCard(
                    title: 'Help Center',
                    icon: Iconsax.support,
                    onTap: () => _showHelpCenterBottomSheet(context),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Account Action'),
                  SettingsCard(
                    title: 'Delete Account',
                    icon: Iconsax.user_remove,
                    iconColor: AppColors.error,
                    showTrailing: false,
                    onTap: () => _showDeleteDialog(context, ref),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    ));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account', style: AppTextStyles.cardTitle),
        content: Text(
          'Are you sure you want to delete your account? This action is permanent and cannot be undone.',
          style: AppTextStyles.description,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(settingsProvider.notifier).deleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 12,
          bottom: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Help Center',
              style: AppTextStyles.header,
            ),
            const SizedBox(height: 8),
            const Text(
              'Contact us for any support or inquiries. We are available 24/7.',
              style: AppTextStyles.description,
            ),
            const SizedBox(height: 24),
            _buildContactRow(
              Iconsax.call,
              'Call Us',
              '+91 8000000000',
              AppColors.primary,
            ),
            const SizedBox(height: 16),
            _buildContactRow(
              Iconsax.sms,
              'Email Us',
              'support@medy24.com',
              AppColors.secondary,
            ),
            const SizedBox(height: 16),
            _buildContactRow(
              Iconsax.location,
              'Headquarters',
              'Naiyo24 PVT LTD, Tech Park',
              AppColors.success,
            ),
            const SizedBox(height: 16),
            _buildContactRow(
              Iconsax.global,
              'Website',
              'www.naiyo24.com',
              AppColors.starYellow,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String title, String detail, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withAlpha(128)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.description.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
