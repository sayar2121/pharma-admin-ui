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

    return Scaffold(
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
                    onTap: () {},
                  ),
                  SettingsCard(
                    title: 'Privacy and Policies',
                    icon: Iconsax.shield_tick,
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Support'),
                  SettingsCard(
                    title: 'Give Feedback',
                    icon: Iconsax.message_edit,
                    onTap: () {},
                  ),
                  SettingsCard(
                    title: 'Report a Problem',
                    icon: Iconsax.danger,
                    onTap: () {},
                  ),
                  SettingsCard(
                    title: 'Help Center',
                    icon: Iconsax.support,
                    onTap: () {},
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
    );
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
}
