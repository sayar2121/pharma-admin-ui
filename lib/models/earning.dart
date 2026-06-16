class EarningModel {
  final String earningId;
  final String? shopId;
  final String orderId;
  final double totalBillAmount;
  final double platformFeeDeduction;
  final double deliveryFeeDeduction;
  final double taxesDeduction;
  final double netEarning;
  final String paymentMode;
  final String settlementStatus;
  final DateTime createdAt;
  final DateTime? settledAt;

  EarningModel({
    required this.earningId,
    this.shopId,
    required this.orderId,
    required this.totalBillAmount,
    required this.platformFeeDeduction,
    required this.deliveryFeeDeduction,
    required this.taxesDeduction,
    required this.netEarning,
    required this.paymentMode,
    required this.settlementStatus,
    required this.createdAt,
    this.settledAt,
  });

  factory EarningModel.fromJson(Map<String, dynamic> json) {
    return EarningModel(
      earningId: json['earning_id'] ?? '',
      shopId: json['shop_id'],
      orderId: json['order_id'] ?? '',
      totalBillAmount: double.tryParse(json['total_bill_amount']?.toString() ?? '0') ?? 0.0,
      platformFeeDeduction: double.tryParse(json['platform_fee_deduction']?.toString() ?? '0') ?? 0.0,
      deliveryFeeDeduction: double.tryParse(json['delivery_fee_deduction']?.toString() ?? '0') ?? 0.0,
      taxesDeduction: double.tryParse(json['taxes_deduction']?.toString() ?? '0') ?? 0.0,
      netEarning: double.tryParse(json['net_earning']?.toString() ?? '0') ?? 0.0,
      paymentMode: json['payment_mode'] ?? 'cod',
      settlementStatus: json['settlement_status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      settledAt: json['settled_at'] != null ? DateTime.parse(json['settled_at']) : null,
    );
  }
}

class EarningSummary {
  final String shopId;
  final double totalNetEarnings;
  final double pendingCodDues;
  final double pendingOnlineReceivables;
  final double settledAmount;

  EarningSummary({
    required this.shopId,
    required this.totalNetEarnings,
    required this.pendingCodDues,
    required this.pendingOnlineReceivables,
    required this.settledAmount,
  });

  factory EarningSummary.fromJson(Map<String, dynamic> json) {
    return EarningSummary(
      shopId: json['shop_id'] ?? '',
      totalNetEarnings: double.tryParse(json['total_net_earnings']?.toString() ?? '0') ?? 0.0,
      pendingCodDues: double.tryParse(json['pending_cod_dues']?.toString() ?? '0') ?? 0.0,
      pendingOnlineReceivables: double.tryParse(json['pending_online_receivables']?.toString() ?? '0') ?? 0.0,
      settledAmount: double.tryParse(json['settled_amount']?.toString() ?? '0') ?? 0.0,
    );
  }
}
