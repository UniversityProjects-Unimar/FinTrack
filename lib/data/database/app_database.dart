import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const int version = 4;
  static const String dbName = 'fintrack.db';

  static Database? _db;

  static Future<Database> getInstance() async {
    final existing = _db;
    if (existing != null) {
      return existing;
    }

    final databasesDir = await getDatabasesPath();
    final dbPath = path.join(databasesDir, dbName);
    // Print database path to help locate the file on disk.
    // ignore: avoid_print
    print('SQLite DB path: $dbPath');

    _db = await openDatabase(
      dbPath,
      version: version,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, _) async {
        await db.transaction((txn) async {
          await txn.execute(_sqlCreateUsers);
          await txn.execute(_sqlCreateTransactions);
          for (final stmt in _sqlCreateIndexes) {
            await txn.execute(stmt);
          }
        });
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          await db.transaction((txn) async {
            await txn.execute('DROP TABLE IF EXISTS transactions');
            await txn.execute('DROP TABLE IF EXISTS users');
            await txn.execute(_sqlCreateUsers);
            await txn.execute(_sqlCreateTransactions);
            for (final stmt in _sqlCreateIndexes) {
              await txn.execute(stmt);
            }
          });
        }
      },
    );

    return _db!;
  }

  static const String _sqlCreateUsers = '''
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  currency_code TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT
)
''';

  static const String _sqlCreateTransactions = '''
CREATE TABLE transactions (
	id TEXT PRIMARY KEY,
  user_id INTEGER NOT NULL,
	amount REAL NOT NULL,
	category TEXT NOT NULL,
	description TEXT NOT NULL DEFAULT '',
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
)
''';

  static const List<String> _sqlCreateIndexes = [
    'CREATE UNIQUE INDEX idx_users_email ON users (email)',
    'CREATE INDEX idx_transactions_user_id ON transactions (user_id)',
    'CREATE INDEX idx_transactions_category ON transactions (category)',
    'CREATE INDEX idx_transactions_created_at ON transactions (created_at)',
  ];
}
