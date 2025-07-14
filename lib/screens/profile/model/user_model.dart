class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? mobileNumber;
  final String? profilePhotoUrl;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.mobileNumber,
    this.profilePhotoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );
  }
} 