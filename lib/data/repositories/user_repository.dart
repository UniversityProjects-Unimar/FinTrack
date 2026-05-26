import 'package:fin_track/features/autenticacao/domain/models/user.dart';
import 'package:sqflite/sqflite.dart';

class UserRepository {
  UserRepository(this._db);

  final Database _db;

  Future<User> create({required User user}) async {
    final map = Map<String, dynamic>.from(user.toSqliteMap());
    if (user.id <= 0) {
      map.remove('id');
    }

    final id = await _db.insert(
      'users',
      map,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    return user.id > 0 ? user : user.copyWith(id: id);
  }

  Future<User?> getById({required int id}) async {
    final maps = await _db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return User.fromSqliteMap(maps.first);
  }

  Future<User?> getByEmail({required String email}) async {
    final maps = await _db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return User.fromSqliteMap(maps.first);
  }

  Future<User?> getFirst() async {
    final maps = await _db.query(
      'users',
      orderBy: 'id ASC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return User.fromSqliteMap(maps.first);
  }

  Future<int> count() async {
    final result = await _db.rawQuery('SELECT COUNT(*) as total FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> seedIfEmpty({required User user}) async {
    final existing = await count();
    if (existing > 0) return;

    await create(user: user);
  }

  Future<User> upsert({required User user}) async {
    await _db.insert(
      'users',
      user.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return user;
  }
}
