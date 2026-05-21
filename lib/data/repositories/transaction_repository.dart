import 'package:fin_track/features/autenticacao/domain/models/transaction.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;

class TransactionRepository {
  TransactionRepository(this._db);

  final Database _db;

  Future<Transaction> create({
    required String userId,
    required Transaction tx,
  }) async {
    await _db.insert(
      'transactions',
      tx.toSimpleSqliteMap(userId: userId),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    return tx;
  }

  Future<List<Transaction>> getAll({required String userId}) async {
    final maps = await _db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return maps.map(Transaction.fromSimpleSqliteMap).toList();
  }

  Future<Transaction?> getById({
    required String userId,
    required String id,
  }) async {
    final maps = await _db.query(
      'transactions',
      where: 'user_id = ? AND id = ?',
      whereArgs: [userId, id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Transaction.fromSimpleSqliteMap(maps.first);
  }

  Future<Transaction> upsert({
    required String userId,
    required Transaction tx,
  }) async {
    await _db.insert(
      'transactions',
      tx.toSimpleSqliteMap(userId: userId),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return tx;
  }

  Future<void> update({required String userId, required Transaction tx}) async {
    await _db.update(
      'transactions',
      tx.toSimpleSqliteMap(userId: userId),
      where: 'user_id = ? AND id = ?',
      whereArgs: [userId, tx.id],
    );
  }

  Future<void> deleteById({required String userId, required String id}) async {
    await _db.delete(
      'transactions',
      where: 'user_id = ? AND id = ?',
      whereArgs: [userId, id],
    );
  }

  Future<int> count({required String userId}) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as total FROM transactions WHERE user_id = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> seedIfEmpty({
    required String userId,
    required List<Transaction> seed,
  }) async {
    if (seed.isEmpty) return;

    final existing = await count(userId: userId);
    if (existing > 0) return;

    await _db.transaction((txn) async {
      for (final tx in seed) {
        await txn.insert(
          'transactions',
          tx.toSimpleSqliteMap(userId: userId),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }
}
