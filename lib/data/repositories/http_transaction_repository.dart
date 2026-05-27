import 'package:fin_track/data/services/transaction_service.dart';
import 'package:fin_track/features/autenticacao/domain/models/transaction.dart';
import 'package:fin_track/features/catalogo/domain/repositories/i_transaction_repository.dart';

class HttpTransactionRepository implements ITransactionRepository {
  HttpTransactionRepository({required TransactionService service})
    : _service = service;

  final TransactionService _service;

  @override
  Future<List<Transaction>> getAll({
    required int userId,
    bool forceRefresh = false,
  }) {
    return _service.listByUser(userId: userId);
  }

  @override
  Future<Transaction> upsert({required int userId, required Transaction tx}) {
    return _service.upsert(userId: userId, tx: tx);
  }

  @override
  Future<void> deleteById({required int userId, required String id}) {
    return _service.delete(userId: userId, id: id);
  }

  @override
  Future<void> seedIfEmpty({
    required int userId,
    required List<Transaction> seed,
  }) async {
    return;
  }
}
