import 'package:fin_track/data/database/app_database.dart';
import 'package:fin_track/data/repositories/transaction_repository.dart';
import 'package:fin_track/data/repositories/user_repository.dart';
import 'package:fin_track/features/autenticacao/state/auth_provider.dart';
import 'package:fin_track/features/autenticacao/domain/models/user.dart';
import 'package:fin_track/features/catalogo/state/preferences_provider.dart';
import 'package:fin_track/features/catalogo/state/transactions_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  if (getIt.isRegistered<AuthProvider>()) {
    return;
  }

  final db = await AppDatabase.getInstance();

  final userRepository = UserRepository(db);
  await userRepository.seedIfEmpty(
    user: User(
      id: 1,
      name: 'Demo',
      email: 'demo@fintrack.com',
      currencyCode: 'BRL',
      createdAt: DateTime.now(),
    ),
  );

  getIt.registerSingleton<Database>(db);
  getIt.registerSingleton<UserRepository>(userRepository);
  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepository(getIt<Database>()),
  );

  getIt.registerLazySingleton<AuthProvider>(
    () => AuthProvider(userRepository: getIt<UserRepository>()),
  );
  getIt.registerLazySingleton<TransactionsProvider>(
    () => TransactionsProvider(
      repository: getIt<TransactionRepository>(),
      seed: const [],
    ),
  );
  getIt.registerLazySingleton<PreferencesProvider>(() => PreferencesProvider());
}
