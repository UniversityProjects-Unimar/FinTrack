import 'package:fin_track/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User', () {
    final createdAt = DateTime.parse('2026-03-01T10:00:00.000Z');
    final updatedAt = DateTime.parse('2026-03-02T10:00:00.000Z');

    test('fromJson cria objeto corretamente', () {
      final json = {
        'id': 'u1',
        'name': 'Guilherme',
        'email': 'gui@email.com',
        'currencyCode': 'BRL',
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

      final user = User.fromJson(json);

      expect(
        user,
        User(
          id: 'u1',
          name: 'Guilherme',
          email: 'gui@email.com',
          currencyCode: 'BRL',
          createdAt: createdAt,
          updatedAt: updatedAt,
        ),
      );
    });

    test('toJson produz json correto', () {
      final user = User(
        id: 'u1',
        name: 'Guilherme',
        email: 'gui@email.com',
        currencyCode: 'BRL',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(user.toJson(), {
        'id': 'u1',
        'name': 'Guilherme',
        'email': 'gui@email.com',
        'currencyCode': 'BRL',
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      });
    });

    test('copyWith modifica apenas campos especificados', () {
      final original = User(
        id: 'u1',
        name: 'Guilherme',
        email: 'gui@email.com',
        currencyCode: 'BRL',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final result = original.copyWith(name: 'Ana');

      expect(result.name, 'Ana');
      expect(result.id, original.id);
      expect(result.email, original.email);
      expect(result.currencyCode, original.currencyCode);
      expect(result.createdAt, original.createdAt);
      expect(result.updatedAt, original.updatedAt);
    });
  });
}
