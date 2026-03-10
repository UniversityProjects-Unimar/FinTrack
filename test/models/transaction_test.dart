import 'package:fin_track/features/autenticacao/domain/models/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Transaction', () {
    final createdAt = DateTime.parse('2026-03-01T10:00:00.000Z');

    test('fromJson cria objeto corretamente', () {
      final json = {
        'id': 't1',
        'amount': 10.0,
        'category': 'c1',
        'description': '...',
        'created_at': createdAt.toIso8601String()
      };

      final transaction = Transaction.fromJson(json);

      expect(
        transaction,
        Transaction(
          id: 't1',
          amount: 10.0,
          category: 'c1',
          description: '...',
          createdAt: createdAt
        )
      );
    });

    test('toJson produz json correto', () {
      final transaction = Transaction(
        id: 't1',
        amount: 10.0,
        category: 'c1',
        createdAt: createdAt
      );

      expect(
        transaction.toJson(), {
          'id': 't1',
          'amount': 10.0,
          'category': 'c1',
          'description': '',
          'created_at': createdAt
        }
      );
    });

    test('copyWith modifica apenas campos especificados', () {
      final original = Transaction(
        id: 't1',
        amount: 10.0,
        category: 'c1',
        createdAt: createdAt
      );

      final result = original.copyWith(category: 'c2');

      expect(result.category, 'c2');
      expect(result.id, original.id);
      expect(result.amount, original.amount);
      expect(result.createdAt, original.createdAt);
      expect(result.description, original.description);
    });
  });
}