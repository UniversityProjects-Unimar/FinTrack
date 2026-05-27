import 'package:fin_track/features/autenticacao/domain/models/user.dart';

abstract interface class IUserRepository {
  Future<User?> getById({required int id, bool forceRefresh = false});

  Future<User?> getByEmail({required String email});

  Future<User?> getFirst({bool forceRefresh = false});

  Future<User> upsert({required User user});

  Future<void> seedIfEmpty({required User user});
}
