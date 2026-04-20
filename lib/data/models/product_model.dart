class ProductModel {
  final String id;
  final String merchantId;
  final String name;
  final String unit;
  final double defaultPriceUsd;
  final double defaultPriceSos;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.merchantId,
    required this.name,
    required this.unit,
    required this.defaultPriceUsd,
    required this.defaultPriceSos,
    required this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      merchantId: json['merchant_id'],
      name: json['name'],
      unit: json['unit'] ?? 'piece',
      defaultPriceUsd: (json['default_price_usd'] as num?)?.toDouble() ?? 0.0,
      defaultPriceSos: (json['default_price_sos'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_id': merchantId,
      'name': name,
      'unit': unit,
      'default_price_usd': defaultPriceUsd,
      'default_price_sos': defaultPriceSos,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
