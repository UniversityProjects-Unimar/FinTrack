class Transaction {
  const Transaction({
    required this.id,
    required this.amount,
    required this.category,
    this.description = '',
    required this.createdAt,
  });

  final String id;
  final double amount;
  final String category;
  final String description;
  final DateTime createdAt;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'description': description,
      'created_at': createdAt
    };
  }

  Transaction copyWith({
    String? id,
    double? amount,
    String? category,
    String? description,
    DateTime? createdAt
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
      other.id == id &&
      other.amount == amount &&
      other.category == category &&
      other.description == description &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}