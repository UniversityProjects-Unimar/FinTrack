import 'package:fin_track/core/models/logged_user.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  LoggedUser? _user;

  LoggedUser? get user => _user;

  bool get isAuthenticated => _user != null;

  void login({required String email}) {
    final normalizedEmail = email.trim().toLowerCase();
    _user = LoggedUser(id: normalizedEmail, email: normalizedEmail);
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
