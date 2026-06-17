import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../providers/earning_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/side_nav_bar.dart';
import '../../widgets/global_order_overlay.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_url.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_bar.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showAllTransactions = false;

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
      appBar: CustomAppBar(
        title: 'Payments & Earnings',
        subtitle: 'Track your shop\'s revenue',
        showDrawer: true,
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
                          _buildPeriodFilter(earningState.period),
                          const SizedBox(height: 16),
                          _buildExportButtons(earningState.period),
                          const SizedBox(height: 16),
                          if (earningState.summary != null) ...[
                            _buildSummaryCards(earningState.summary!, earningState.period),
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
                          else ...[
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _showAllTransactions ? earningState.earnings.length : (earningState.earnings.length > 3 ? 3 : earningState.earnings.length),
                              itemBuilder: (context, index) {
                                final earning = earningState.earnings[index];
                                return _buildEarningTile(earning);
                              },
                            ),
                            if (earningState.earnings.length > 3)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                                child: Center(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _showAllTransactions = !_showAllTransactions;
                                      });
                                    },
                                    icon: Icon(
                                      _showAllTransactions ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                    label: Text(
                                      _showAllTransactions ? 'View Less' : 'View All Transactions',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary.withAlpha(20),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
        ),
      ),
    ));
  }

  Future<void> _exportData(String format, String period) async {
    final shopId = ref.read(authProvider).user?.shopId;
    if (shopId == null) return;

    final urlString = '${ApiUrl.baseUrl}/earnings/pharma-shop/export/$shopId?period=$period&format=$format';
    final Uri url = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open export link.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting data: $e')),
        );
      }
    }
  }

  Widget _buildExportButtons(String currentPeriod) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _exportData('excel', currentPeriod),
            icon: const Icon(Iconsax.document_download, size: 18),
            label: const Text('Export Excel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green[700],
              side: BorderSide(color: Colors.green[700]!),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _exportData('pdf', currentPeriod),
            icon: const Icon(Iconsax.document_download, size: 18),
            label: const Text('Export PDF'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red[700],
              side: BorderSide(color: Colors.red[700]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodFilter(String currentPeriod) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All Time', 'all', currentPeriod),
          const SizedBox(width: 8),
          _buildFilterChip('Weekly', 'weekly', currentPeriod),
          const SizedBox(width: 8),
          _buildFilterChip('Monthly', 'monthly', currentPeriod),
          const SizedBox(width: 8),
          _buildFilterChip('Yearly', 'yearly', currentPeriod),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String currentPeriod) {
    final isSelected = value == currentPeriod;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(earningProvider.notifier).setPeriod(value);
        }
      },
      selectedColor: AppColors.primary.withAlpha(50),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.divider,
        ),
      ),
    );
  }

  // ignore: strict_top_level_inference
  Widget _buildSummaryCards(summary, String period) {
    String revenueLabel = 'Revenue';
    if (period == 'weekly') revenueLabel = 'Weekly Revenue';
    if (period == 'monthly') revenueLabel = 'Monthly Revenue';
    if (period == 'yearly') revenueLabel = 'Yearly Revenue';

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
              Text(
                revenueLabel,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
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

    return InkWell(
      onTap: () => _showTransactionDetails(context, earning),
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
    ));
  }

  void _showTransactionDetails(BuildContext context, earning) {
    final bool isCod = earning.paymentMode.toLowerCase() == 'cod';
    final DateFormat formatter = DateFormat('dd MMM yyyy, hh:mm a');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaction Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCod ? Colors.orange.withAlpha(20) : Colors.blue.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isCod ? 'COD' : 'ONLINE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCod ? Colors.orange : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Order ID', '#${earning.orderId}'),
            const SizedBox(height: 12),
            _buildDetailRow('Date & Time', formatter.format(earning.createdAt)),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Settlement Status', 
              earning.settlementStatus.toUpperCase(),
              valueColor: earning.settlementStatus.toLowerCase() == 'settled' ? AppColors.success : Colors.orange,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            _buildDetailRow('Total Customer Bill', '₹${earning.totalBillAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            _buildDetailRow('Platform Fee', '- ₹${earning.platformFeeDeduction.toStringAsFixed(2)}', valueColor: AppColors.error),
            const SizedBox(height: 12),
            _buildDetailRow('Delivery Fee', '- ₹${earning.deliveryFeeDeduction.toStringAsFixed(2)}', valueColor: AppColors.error),
            const SizedBox(height: 12),
            _buildDetailRow('Taxes', '- ₹${earning.taxesDeduction.toStringAsFixed(2)}', valueColor: AppColors.error),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Net Earning', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(
                  '₹${earning.netEarning.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.success),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
