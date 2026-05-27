import 'package:fin_track/features/autenticacao/domain/models/transaction.dart';

abstract interface class ITransactionRepository {
  Future<List<Transaction>> getAll({required int userId, bool forceRefresh});

  Future<Transaction> upsert({required int userId, required Transaction tx});

  Future<void> deleteById({required int userId, required String id});

  Future<void> seedIfEmpty({
    required int userId,
    required List<Transaction> seed,
  });
}
