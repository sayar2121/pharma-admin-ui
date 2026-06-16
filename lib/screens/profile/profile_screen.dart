import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/side_nav_bar.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../cards/profile/profile_header_card.dart';
import '../../cards/profile/profile_options_card.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/dashboard');
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'My Profile',
        subtitle: 'Manage your pharmacy account',
        showDrawer: true,
      ),
      drawer: SideNavBar(
        selectedIndex: 5, // Profile index
        onItemSelected: (index) {},
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            if (user != null) ProfileHeaderCard(user: user),
            const SizedBox(height: AppSpacing.sectionGap),
            const ProfileOptionsCard(),
            const SizedBox(height: AppSpacing.sectionGap),
          ],
        ),
      ),
    ));
  }
}
