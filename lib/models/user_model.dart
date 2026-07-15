class UserModel {
  final int? id;
  final String fullName;
  final String email;
  final String passwordHash;
  final String? avatarUrl;
  final String createdAt;

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.passwordHash,
    this.avatarUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'passwordHash': passwordHash,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      fullName: map['fullName'],
      email: map['email'],
      passwordHash: map['passwordHash'],
      avatarUrl: map['avatarUrl'],
      createdAt: map['createdAt'],
    );
  }
}
