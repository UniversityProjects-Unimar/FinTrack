import 'package:fin_track/data/repositories/http_transaction_repository.dart';
import 'package:fin_track/data/repositories/transaction_repository.dart';
import 'package:fin_track/data/services/app_exception.dart';
import 'package:fin_track/features/autenticacao/domain/models/transaction.dart';
import 'package:fin_track/features/catalogo/domain/repositories/i_transaction_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheTransactionRepository implements ITransactionRepository {
  CacheTransactionRepository({
    required TransactionRepository local,
    required HttpTransactionRepository remote,
    required SharedPreferences prefs,
  }) : _local = local,
       _remote = remote,
       _prefs = prefs;

  static const int _tempoVidaCacheMinutos = 30;

  final TransactionRepository _local;
  final HttpTransactionRepository _remote;
  final SharedPreferences _prefs;

  String _chaveUltimaAtualizacao(int userId) {
    return 'transactions_ultima_atualizacao_user_$userId';
  }

  bool _cacheEstaFresco(int userId) {
    final ultimaAtualizacaoMs = _prefs.getInt(_chaveUltimaAtualizacao(userId));
    if (ultimaAtualizacaoMs == null) return false;

    final ultimaAtualizacao = DateTime.fromMillisecondsSinceEpoch(
      ultimaAtualizacaoMs,
    );
    final agora = DateTime.now();
    final diferenca = agora.difference(ultimaAtualizacao);

    return diferenca.inMinutes < _tempoVidaCacheMinutos;
  }

  Future<void> _registrarAtualizacaoCache(int userId) {
    return _prefs.setInt(
      _chaveUltimaAtualizacao(userId),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> _invalidarCache(int userId) {
    return _prefs.remove(_chaveUltimaAtualizacao(userId));
  }

  @override
  Future<List<Transaction>> getAll({
    required int userId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cacheEstaFresco(userId)) {
      return _local.getAll(userId: userId);
    }

    try {
      final items = await _remote.getAll(userId: userId, forceRefresh: true);
      await _local.replaceAll(userId: userId, items: items);
      await _registrarAtualizacaoCache(userId);
      return items;
    } on NetworkException {
      return _local.getAll(userId: userId);
    } on TimeoutApiException {
      return _local.getAll(userId: userId);
    }
  }

  @override
  Future<Transaction> upsert({
    required int userId,
    required Transaction tx,
  }) async {
    final saved = await _local.upsert(userId: userId, tx: tx);

    try {
      await _remote.upsert(userId: userId, tx: tx);
    } catch (_) {}

    await _invalidarCache(userId);
    return saved;
  }

  @override
  Future<void> deleteById({required int userId, required String id}) async {
    await _local.deleteById(userId: userId, id: id);

    try {
      await _remote.deleteById(userId: userId, id: id);
    } catch (_) {}

    await _invalidarCache(userId);
  }

  @override
  Future<void> seedIfEmpty({
    required int userId,
    required List<Transaction> seed,
  }) async {
    await _local.seedIfEmpty(userId: userId, seed: seed);
  }
}
