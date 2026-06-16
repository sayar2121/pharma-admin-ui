import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_theme.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';

class SideNavBar extends ConsumerStatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SideNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  ConsumerState<SideNavBar> createState() => _SideNavBarState();
}

class _SideNavBarState extends ConsumerState<SideNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: AppColors.divider.withAlpha(128), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStatusToggle(),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildNavItem(
                    context,
                    0,
                    'Dashboard',
                    Iconsax.element_3,
                    '/dashboard',
                  ),
                  _buildNavItem(
                    context,
                    1,
                    'Available Medicines',
                    Iconsax.health,
                    '/available-medicines',
                  ),
                  _buildNavItem(
                    context,
                    3,
                    'Order Management',
                    Iconsax.receipt,
                    '/order-management',
                  ),
                  _buildNavItem(
                    context,
                    4,
                    'Payments & Earnings',
                    Iconsax.wallet,
                    '/earnings',
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Divider(color: AppColors.divider, thickness: 1),
                  ),
                  _buildNavItem(
                    context,
                    5,
                    'Profile',
                    Iconsax.user,
                    '/profile',
                  ),
                  _buildNavItem(
                    context,
                    6,
                    'Settings',
                    Iconsax.setting_2,
                    '/settings',
                  ),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildStatusToggle() {
    final isOnline = ref.watch(orderProvider).isOnline;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isOnline
              ? Colors.green.withAlpha(20)
              : Colors.red.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOnline
                ? Colors.green.withAlpha(50)
                : Colors.red.withAlpha(50),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isOnline ? Iconsax.wifi : Iconsax.wifi_square,
              color: isOnline ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isOnline ? Colors.green : Colors.red,
                ),
              ),
            ),
            Switch(
              value: isOnline,
              onChanged: (value) {
                ref.read(orderProvider.notifier).setOnlineStatus(value);
              },
              activeThumbColor: Colors.green,
              activeTrackColor: Colors.green.withAlpha(50),
              inactiveThumbColor: Colors.red,
              inactiveTrackColor: Colors.red.withAlpha(50),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  'assets/logo/logo.png',
                  width: 32,
                  height: 32,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Iconsax.hospital,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PharmaApp',
                      style: TextStyle(
                        fontFamily: 'Fraunces',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text('Partner Portal', style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    String title,
    IconData icon,
    String route,
  ) {
    final isSelected = widget.selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          widget.onItemSelected(index);
          Scaffold.of(context).closeDrawer();
          context.go(route);
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withAlpha(25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withAlpha(50)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.description.copyWith(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final authState = ref.watch(authProvider);
    final shopName = authState.user?.shopName ?? 'Loading...';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.divider.withAlpha(128), width: 1),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.blush,
            child: const Icon(
              Iconsax.user,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  shopName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text('Store Owner', style: AppTextStyles.caption),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                // ignore: use_build_context_synchronously
                context.go('/login');
              }
            },
            icon: const Icon(Iconsax.logout, size: 20, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
