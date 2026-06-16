import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/side_nav_bar.dart';
import '../../theme/app_theme.dart';
import '../../providers/order_provider.dart';
import '../../providers/earning_provider.dart';
import '../../models/order.dart';
import '../../cards/order/order_bottomsheet.dart';
import '../../providers/notification_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animController.forward();
    
    // Automatically trigger fetch when dashboard opens if we are online
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProvider.notifier).ensureConnectedAndFetch();
      ref.read(earningProvider.notifier).fetchEarningsData();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.read(orderProvider.notifier).ensureConnectedAndFetch();
    await ref.read(earningProvider.notifier).fetchEarningsData();
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final earningState = ref.watch(earningProvider);
    final activeOrders = orderState.activeOrders;
    final incomingOrders = orderState.incomingOrders;

    double earnings = earningState.summary?.totalNetEarnings ?? 0.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App', style: AppTextStyles.cardTitle),
            content: const Text('Are you sure you want to close the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Dashboard',
          subtitle: 'Overview of your pharmacy',
          showDrawer: true,
          actions: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CustomAppBar.buildActionButton(
                  icon: Iconsax.notification,
                  onTap: () => context.push('/notifications'),
                ),
                if (ref.watch(notificationProvider).unreadCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        ref.watch(notificationProvider).unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      drawer: SideNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnimatedWidget(
                  0,
                  _buildStatsRow(activeOrders.length, incomingOrders.length, earnings),
                ),
                const SizedBox(height: 32),
                _buildAnimatedWidget(
                  1,
                  _buildQuickActions(),
                ),
                const SizedBox(height: 32),
                _buildAnimatedWidget(
                  2,
                  _buildRecentOrdersHeader(),
                ),
                const SizedBox(height: 16),
                if (activeOrders.isEmpty && incomingOrders.isEmpty)
                  _buildAnimatedWidget(3, _buildEmptyState())
                else
                  ...[
                    // Show incoming
                    ...(incomingOrders.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt))).take(10).toList().asMap().entries.map((entry) {
                      return _buildAnimatedWidget(3 + entry.key, _buildOrderCard(entry.value, isIncoming: true));
                    }),
                    // Show a few active
                    ...(activeOrders.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt))).take(5).toList().asMap().entries.map((entry) {
                      return _buildAnimatedWidget(13 + entry.key, _buildOrderCard(entry.value, isIncoming: false));
                    }),
                  ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildAnimatedWidget(int index, Widget child) {
    // Staggered animation
    final start = (index * 0.1).clamp(0.0, 1.0);
    final end = (start + 0.5).clamp(0.0, 1.0);
    
    final animation = CurvedAnimation(
      parent: _animController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }

  Widget _buildStatsRow(int activeCount, int pendingCount, double earnings) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Active',
            activeCount.toString(),
            Iconsax.truck_fast,
            AppColors.primary,
            AppColors.primary.withAlpha(20),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Pending',
            pendingCount.toString(),
            Iconsax.timer,
            AppColors.warning,
            AppColors.warning.withAlpha(20),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Earnings',
            '₹${earnings.toStringAsFixed(0)}',
            Iconsax.wallet_3,
            AppColors.success,
            AppColors.success.withAlpha(20),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppCardStyles.sleekCard.copyWith(
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTextStyles.header.copyWith(fontSize: 24, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: AppTextStyles.cardTitle),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildActionChip('Inventory', Iconsax.box, () => context.go('/available-medicines')),
              _buildActionChip('Orders', Iconsax.receipt, () => context.go('/order-management')),
              _buildActionChip('Settings', Iconsax.setting_2, () => context.go('/settings')),
              _buildActionChip('Profile', Iconsax.user, () => context.go('/profile')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip(String label, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.description.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrdersHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Recent Activity', style: AppTextStyles.cardTitle),
        TextButton(
          onPressed: () => context.go('/order-management'),
          child: Text(
            'View All',
            style: AppTextStyles.tagline.copyWith(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: AppCardStyles.sleekCard,
      child: const Column(
        children: [
          Icon(Iconsax.document_text_1, size: 48, color: AppColors.textTertiary),
          SizedBox(height: 16),
          Text('No recent orders', style: AppTextStyles.cardTitle),
          SizedBox(height: 8),
          Text(
            'When you receive orders, they will appear here.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order, {required bool isIncoming}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppCardStyles.sleekCard,
      child: InkWell(
        onTap: () {
          // Open order details bottom sheet
          OrderBottomSheet.show(context, order);
        },
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isIncoming ? AppColors.warning : AppColors.primary).withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIncoming ? Iconsax.timer : Iconsax.receipt_item,
                  color: isIncoming ? AppColors.warning : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customer.name,
                      style: AppTextStyles.description.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${order.id.substring(0, 8)}...',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(0)}',
                    style: AppTextStyles.cardTitle.copyWith(color: AppColors.success),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusBadge(order.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor = AppColors.infoLight;
    Color textColor = AppColors.info;

    if (status == 'pending') {
      bgColor = AppColors.warningLight;
      textColor = AppColors.warning;
    } else if (status == 'packing' || status == 'ready_for_delivery') {
      bgColor = AppColors.warningLight;
      textColor = AppColors.warning;
    } else if (status == 'out_for_delivery' || status == 'delivered') {
      bgColor = AppColors.successLight;
      textColor = AppColors.success;
    } else if (status == 'cancelled' || status == 'rejected') {
      bgColor = AppColors.errorLight;
      textColor = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase().replaceAll('_', ' '),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
