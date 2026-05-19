import 'package:fin_track/features/autenticacao/domain/models/transaction.dart';
import 'package:fin_track/features/autenticacao/state/auth_provider.dart';
import 'package:fin_track/features/catalogo/state/preferences_provider.dart';
import 'package:fin_track/features/catalogo/state/transactions_provider.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  if (getIt.isRegistered<AuthProvider>()) {
    return;
  }

  getIt.registerLazySingleton<AuthProvider>(() => AuthProvider());
  getIt.registerLazySingleton<TransactionsProvider>(
    () => TransactionsProvider(
      seed: [
        Transaction(
          id: 't1',
          amount: 80,
          category: 'Mercado',
          description: 'Compra semanal',
          createdAt: DateTime(2026, 4, 1),
        ),
        Transaction(
          id: 't2',
          amount: 35,
          category: 'Transporte',
          description: 'Combustível',
          createdAt: DateTime(2026, 4, 2),
        ),
        Transaction(
          id: 't3',
          amount: 120,
          category: 'Lazer',
          description: 'Cinema e lanche',
          createdAt: DateTime(2026, 4, 4),
        ),
      ],
    ),
  );
  getIt.registerLazySingleton<PreferencesProvider>(() => PreferencesProvider());
}
