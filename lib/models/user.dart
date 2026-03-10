class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.currencyCode,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String password;
  final String currencyCode;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      currencyCode: json['currencyCode'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'currencyCode': currencyCode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? currencyCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearUpdatedAt = false,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      currencyCode: currencyCode ?? this.currencyCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: clearUpdatedAt ? null : updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.password == password &&
        other.currencyCode == currencyCode &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        password.hashCode ^
        currencyCode.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
