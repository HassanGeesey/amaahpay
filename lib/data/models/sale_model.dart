class SaleModel {
  final String id;
  final String merchantId;
  final String customerId;
  final String customerName;
  final double totalUsd;
  final double cashPaidUsd;
  final double depositUsedUsd;
  final double creditAddedUsd;
  final String? notes;
  final DateTime createdAt;

  SaleModel({
    required this.id,
    required this.merchantId,
    required this.customerId,
    required this.customerName,
    required this.totalUsd,
    required this.cashPaidUsd,
    required this.depositUsedUsd,
    required this.creditAddedUsd,
    this.notes,
    required this.createdAt,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customers'] as Map<String, dynamic>?;
    return SaleModel(
      id: json['id'],
      merchantId: json['merchant_id'],
      customerId: json['customer_id'],
      customerName: customer?['name'] as String? ?? 'Unknown',
      totalUsd: (json['total_usd'] as num?)?.toDouble() ?? 0.0,
      cashPaidUsd: (json['cash_paid_usd'] as num?)?.toDouble() ?? 0.0,
      depositUsedUsd: (json['deposit_used_usd'] as num?)?.toDouble() ?? 0.0,
      creditAddedUsd: (json['credit_added_usd'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
