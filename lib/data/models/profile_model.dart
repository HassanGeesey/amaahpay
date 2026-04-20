class ProfileModel {
  final String id;
  final String name;
  final String? phone;
  final String? shopName;
  final String role;
  final bool isActive;

  ProfileModel({
    required this.id,
    required this.name,
    this.phone,
    this.shopName,
    required this.role,
    required this.isActive,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unknown',
      phone: json['phone'] as String?,
      shopName: json['shop_name'] as String?,
      role: json['role'] as String? ?? 'merchant',
      isActive: json['is_active'] == true,
    );
  }
}
