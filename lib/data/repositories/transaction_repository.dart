import 'package:fin_track/features/autenticacao/domain/models/transaction.dart';
import 'package:fin_track/features/catalogo/domain/repositories/i_transaction_repository.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;

class TransactionRepository implements ITransactionRepository {
  TransactionRepository(this._db);

  final Database _db;

  Future<Transaction> create({
    required int userId,
    required Transaction tx,
  }) async {
    await _db.insert(
      'transactions',
      tx.toSimpleSqliteMap(userId: userId),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    return tx;
  }

  @override
  Future<List<Transaction>> getAll({
    required int userId,
    bool forceRefresh = false,
  }) async {
    final maps = await _db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return maps.map(Transaction.fromSimpleSqliteMap).toList();
  }

  Future<Transaction?> getById({
    required int userId,
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

  @override
  Future<Transaction> upsert({
    required int userId,
    required Transaction tx,
  }) async {
    await _db.insert(
      'transactions',
      tx.toSimpleSqliteMap(userId: userId),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return tx;
  }

  Future<void> update({required int userId, required Transaction tx}) async {
    await _db.update(
      'transactions',
      tx.toSimpleSqliteMap(userId: userId),
      where: 'user_id = ? AND id = ?',
      whereArgs: [userId, tx.id],
    );
  }

  @override
  Future<void> deleteById({required int userId, required String id}) async {
    await _db.delete(
      'transactions',
      where: 'user_id = ? AND id = ?',
      whereArgs: [userId, id],
    );
  }

  Future<int> count({required int userId}) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as total FROM transactions WHERE user_id = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<void> seedIfEmpty({
    required int userId,
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

  Future<void> replaceAll({
    required int userId,
    required List<Transaction> items,
  }) async {
    await _db.transaction((txn) async {
      await txn.delete(
        'transactions',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      for (final tx in items) {
        await txn.insert(
          'transactions',
          tx.toSimpleSqliteMap(userId: userId),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
