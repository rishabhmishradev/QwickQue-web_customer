class UserModel {
  final int id;
  final String? firebaseUid;
  final String role;
  final String? name;
  final String email;
  final String? phone;
  final bool isActive;

  UserModel({
    required this.id,
    this.firebaseUid,
    required this.role,
    this.name,
    required this.email,
    this.phone,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firebaseUid: json['firebase_uid'],
      role: json['role'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'role': role,
      'name': name,
      'email': email,
      'phone': phone,
      'is_active': isActive,
    };
  }
}
