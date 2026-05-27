import 'package:fin_track/data/database/app_database.dart';
import 'package:fin_track/data/repositories/cache_transaction_repository.dart';
import 'package:fin_track/data/repositories/cache_user_repository.dart';
import 'package:fin_track/data/repositories/http_transaction_repository.dart';
import 'package:fin_track/data/repositories/http_user_repository.dart';
import 'package:fin_track/data/repositories/transaction_repository.dart';
import 'package:fin_track/data/repositories/user_repository.dart';
import 'package:fin_track/data/services/transaction_service.dart';
import 'package:fin_track/data/services/user_service.dart';
import 'package:fin_track/features/autenticacao/domain/models/user.dart';
import 'package:fin_track/features/autenticacao/domain/repositories/i_user_repository.dart';
import 'package:fin_track/features/autenticacao/state/auth_provider.dart';
import 'package:fin_track/features/catalogo/domain/repositories/i_transaction_repository.dart';
import 'package:fin_track/features/catalogo/state/transactions_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  if (getIt.isRegistered<AuthProvider>()) {
    return;
  }

  final db = await AppDatabase.getInstance();
  final prefs = await SharedPreferences.getInstance();
  final httpClient = http.Client();

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
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerSingleton<http.Client>(httpClient);
  getIt.registerSingleton<UserRepository>(userRepository);

  final userService = UserService(client: getIt<http.Client>());
  final remoteUserRepository = HttpUserRepository(service: userService);
  getIt.registerSingleton<UserService>(userService);
  getIt.registerSingleton<HttpUserRepository>(remoteUserRepository);
  getIt.registerLazySingleton<IUserRepository>(
    () => CacheUserRepository(
      local: getIt<UserRepository>(),
      remote: getIt<HttpUserRepository>(),
      prefs: getIt<SharedPreferences>(),
    ),
  );

  final localTransactionRepository = TransactionRepository(getIt<Database>());
  final transactionService = TransactionService(client: getIt<http.Client>());
  final remoteTransactionRepository = HttpTransactionRepository(
    service: transactionService,
  );

  getIt.registerSingleton<TransactionRepository>(localTransactionRepository);
  getIt.registerSingleton<TransactionService>(transactionService);
  getIt.registerSingleton<HttpTransactionRepository>(
    remoteTransactionRepository,
  );
  getIt.registerLazySingleton<ITransactionRepository>(
    () => CacheTransactionRepository(
      local: getIt<TransactionRepository>(),
      remote: getIt<HttpTransactionRepository>(),
      prefs: getIt<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton<AuthProvider>(
    () => AuthProvider(userRepository: getIt<IUserRepository>()),
  );
  getIt.registerLazySingleton<TransactionsProvider>(
    () => TransactionsProvider(
      repository: getIt<ITransactionRepository>(),
      seed: const [],
    ),
  );
}
