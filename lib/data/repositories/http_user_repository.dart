import 'package:fin_track/data/services/user_service.dart';
import 'package:fin_track/features/autenticacao/domain/models/user.dart';
import 'package:fin_track/features/autenticacao/domain/repositories/i_user_repository.dart';

class HttpUserRepository implements IUserRepository {
  HttpUserRepository({required UserService service}) : _service = service;

  final UserService _service;

  @override
  Future<User?> getById({required int id, bool forceRefresh = false}) {
    return _service.getById(userId: id);
  }

  @override
  Future<User?> getByEmail({required String email}) async {
    return _service.getByEmail(email: email);
  }

  @override
  Future<User?> getFirst({bool forceRefresh = false}) async {
    return null;
  }

  @override
  Future<User> upsert({required User user}) {
    return _service.upsert(user: user);
  }

  @override
  Future<void> seedIfEmpty({required User user}) async {
    return;
  }
}
