import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const int version = 2;
  static const String dbName = 'fintrack.db';

  static Database? _db;

  static Future<Database> getInstance() async {
    final existing = _db;
    if (existing != null) {
      return existing;
    }

    final databasesDir = await getDatabasesPath();
    final dbPath = path.join(databasesDir, dbName);

    _db = await openDatabase(
      dbPath,
      version: version,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, _) async {
        await db.transaction((txn) async {
          await txn.execute(_sqlCreateTransactions);
          for (final stmt in _sqlCreateIndexes) {
            await txn.execute(stmt);
          }
        });
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.transaction((txn) async {
            await txn.execute('DROP TABLE IF EXISTS transactions');
            await txn.execute('DROP TABLE IF EXISTS categories');
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

  static const String _sqlCreateTransactions = '''
CREATE TABLE transactions (
	id TEXT PRIMARY KEY,
	user_id TEXT NOT NULL,
	amount REAL NOT NULL,
	category TEXT NOT NULL,
	description TEXT NOT NULL DEFAULT '',
	created_at TEXT NOT NULL
)
''';

  static const List<String> _sqlCreateIndexes = [
    'CREATE INDEX idx_transactions_user_id ON transactions (user_id)',
    'CREATE INDEX idx_transactions_category ON transactions (category)',
    'CREATE INDEX idx_transactions_created_at ON transactions (created_at)',
  ];
}
