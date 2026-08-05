enum UserRole {
  guest,
  user,
  editor,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.guest:
        return 'Misafir';
      case UserRole.user:
        return 'Kayıtlı Kullanıcı';
      case UserRole.editor:
        return 'Editör';
      case UserRole.admin:
        return 'Yönetici';
    }
  }

  static UserRole fromString(String? roleStr) {
    switch (roleStr?.toLowerCase().trim()) {
      case 'user':
      case 'registered_user':
      case 'kayitli_kullanici':
        return UserRole.user;
      case 'editor':
      case 'editor_user':
        return UserRole.editor;
      case 'admin':
      case 'administrator':
        return UserRole.admin;
      case 'guest':
      default:
        return UserRole.guest;
    }
  }
}

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? token;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.token,
  });

  bool get isGuest => role == UserRole.guest;
  bool get isRegistered => role != UserRole.guest;

  factory UserModel.guest() {
    return const UserModel(
      id: 'guest',
      email: '',
      name: 'Misafir Kullanıcı',
      role: UserRole.guest,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'token': token,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? 'guest',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Kullanıcı',
      role: UserRole.fromString(json['role']?.toString()),
      token: json['token']?.toString(),
    );
  }
}
