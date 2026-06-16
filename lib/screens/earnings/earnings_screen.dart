import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../providers/earning_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/side_nav_bar.dart';
import '../../widgets/global_order_overlay.dart';
import 'package:go_router/go_router.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final earningState = ref.watch(earningProvider);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/dashboard');
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
      drawer: SideNavBar(
        selectedIndex: 4,
        onItemSelected: (index) {},
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.menu_1),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Payments & Earnings'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: () => ref.read(earningProvider.notifier).fetchEarningsData(),
          ),
        ],
      ),
      body: GlobalOrderOverlay(
        child: RefreshIndicator(
          onRefresh: () => ref.read(earningProvider.notifier).fetchEarningsData(),
          child: earningState.isLoading && earningState.summary == null
              ? const Center(child: CircularProgressIndicator())
              : earningState.error != null && earningState.summary == null
                  ? Center(child: Text(earningState.error!, style: const TextStyle(color: AppColors.error)))
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (earningState.summary != null) ...[
                            _buildSummaryCards(earningState.summary!),
                            const SizedBox(height: 24),
                          ],
                          const Text(
                            'Recent Transactions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (earningState.earnings.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text('No earnings found.'),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: earningState.earnings.length,
                              itemBuilder: (context, index) {
                                final earning = earningState.earnings[index];
                                return _buildEarningTile(earning);
                              },
                            ),
                        ],
                      ),
                    ),
        ),
      ),
    ));
  }

  // ignore: strict_top_level_inference
  Widget _buildSummaryCards(summary) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF14B8A6).withAlpha(60),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Net Earnings',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${summary.totalNetEarnings.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Settled Amount',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${summary.settledAmount.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Pending Settlement',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${(summary.totalNetEarnings - summary.settledAmount).toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMiniCard(
                'Platform Owes You\n(Online Payments)',
                summary.pendingOnlineReceivables,
                Iconsax.receive_square,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMiniCard(
                'You Owe Platform\n(COD Dues)',
                summary.pendingCodDues,
                Iconsax.wallet_minus,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniCard(String title, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppCardStyles.sleekCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: AppTextStyles.header.copyWith(fontSize: 18, color: color),
          ),
        ],
      ),
    );
  }

  // ignore: strict_top_level_inference
  Widget _buildEarningTile(earning) {
    final bool isCod = earning.paymentMode.toLowerCase() == 'cod';
    final DateFormat formatter = DateFormat('dd MMM yyyy, hh:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppCardStyles.sleekCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${earning.orderId.substring(0, 8)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCod ? Colors.orange.withAlpha(20) : Colors.blue.withAlpha(20),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isCod ? Colors.orange.withAlpha(50) : Colors.blue.withAlpha(50)),
                ),
                child: Text(
                  isCod ? 'COD' : 'ONLINE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isCod ? Colors.orange : Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(earning.createdAt),
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Bill', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              Text('₹${earning.totalBillAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Platform Deductions', style: TextStyle(fontSize: 14, color: AppColors.error)),
              Text(
                '- ₹${(earning.platformFeeDeduction + earning.deliveryFeeDeduction + earning.taxesDeduction).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, color: AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Net Earning', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text(
                '₹${earning.netEarning.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.success),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
