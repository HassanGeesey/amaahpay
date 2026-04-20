class CustomerModel {
  final String id;
  final String merchantId;
  final String name;
  final String phone;
  final double creditBalance;
  final double depositBalance;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerModel({
    required this.id,
    required this.merchantId,
    required this.name,
    required this.phone,
    required this.creditBalance,
    required this.depositBalance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      merchantId: json['merchant_id'],
      name: json['name'],
      phone: json['phone'] ?? '',
      creditBalance: (json['credit_balance'] as num?)?.toDouble() ?? 0.0,
      depositBalance: (json['deposit_balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_id': merchantId,
      'name': name,
      'phone': phone,
      'credit_balance': creditBalance,
      'deposit_balance': depositBalance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
