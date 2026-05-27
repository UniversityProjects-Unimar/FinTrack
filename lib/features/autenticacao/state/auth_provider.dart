import 'package:fin_track/core/models/logged_user.dart';
import 'package:fin_track/features/autenticacao/domain/repositories/i_user_repository.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required IUserRepository userRepository})
    : _userRepository = userRepository;

  final IUserRepository _userRepository;
  LoggedUser? _user;

  LoggedUser? get user => _user;

  bool get isAuthenticated => _user != null;

  Future<bool> login({required String email}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final user = await _userRepository.getByEmail(email: normalizedEmail);

    if (user == null) {
      _user = null;
      notifyListeners();
      return false;
    }

    _user = LoggedUser(id: user.id, email: user.email, name: user.name);
    notifyListeners();
    return true;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
