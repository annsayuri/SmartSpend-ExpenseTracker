enum Role { USER, ADMIN }

class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password; // 🔒 BCrypt Encypted Password එක
  final Role role;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.role = Role.USER,
  });

  // 1. SQLite Database එකට Save කිරීමට Map එකක් බවට හැරවීම 🔄
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role.name, // 'USER' හෝ 'ADMIN' ලෙස String විදියට Save වේ
    };
  }

  // 2. Database එකෙන් ගන්නා Map Data එකක් Object එකක් බවට හැරවීම 📦
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] == 'ADMIN' ? Role.ADMIN : Role.USER,
    );
  }

  // 3. User Object එකේ Data Update කිරීමට පහසු CopyWith Function එක 🛠️
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    Role? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }
}