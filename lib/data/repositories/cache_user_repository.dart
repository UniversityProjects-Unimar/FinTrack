import 'package:fin_track/data/repositories/http_user_repository.dart';
import 'package:fin_track/data/repositories/user_repository.dart';
import 'package:fin_track/data/services/app_exception.dart';
import 'package:fin_track/features/autenticacao/domain/models/user.dart';
import 'package:fin_track/features/autenticacao/domain/repositories/i_user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheUserRepository implements IUserRepository {
  CacheUserRepository({
    required UserRepository local,
    required HttpUserRepository remote,
    required SharedPreferences prefs,
  }) : _local = local,
       _remote = remote,
       _prefs = prefs;

  static const int _tempoVidaCacheMinutos = 30;

  final UserRepository _local;
  final HttpUserRepository _remote;
  final SharedPreferences _prefs;

  String _chaveUltimaAtualizacao(int userId) {
    return 'user_ultima_atualizacao_$userId';
  }

  bool _cacheEstaFresco(int userId) {
    final ultimaAtualizacaoMs = _prefs.getInt(_chaveUltimaAtualizacao(userId));
    if (ultimaAtualizacaoMs == null) return false;

    final ultimaAtualizacao = DateTime.fromMillisecondsSinceEpoch(
      ultimaAtualizacaoMs,
    );
    final diferenca = DateTime.now().difference(ultimaAtualizacao);

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
  Future<User?> getById({required int id, bool forceRefresh = false}) async {
    if (!forceRefresh && _cacheEstaFresco(id)) {
      final local = await _local.getById(id: id);
      if (local != null) return local;
    }

    try {
      final remote = await _remote.getById(id: id, forceRefresh: true);
      if (remote == null) return null;

      await _local.upsert(user: remote);
      await _registrarAtualizacaoCache(id);
      return remote;
    } on NetworkException {
      return _local.getById(id: id);
    } on TimeoutApiException {
      return _local.getById(id: id);
    }
  }

  @override
  Future<User?> getByEmail({required String email}) async {
    try {
      final remote = await _remote.getByEmail(email: email);

      if (remote != null) {
        await _local.upsert(user: remote);
        await _registrarAtualizacaoCache(remote.id);
        return remote;
      }
    } on AppException {}

    return _local.getByEmail(email: email);
  }

  @override
  Future<User?> getFirst({bool forceRefresh = false}) {
    return _local.getFirst(forceRefresh: forceRefresh);
  }

  @override
  Future<User> upsert({required User user}) async {
    final saved = await _local.upsert(user: user);

    try {
      await _remote.upsert(user: user);
    } catch (_) {}

    await _invalidarCache(user.id);
    return saved;
  }

  @override
  Future<void> seedIfEmpty({required User user}) {
    return _local.seedIfEmpty(user: user);
  }
}
