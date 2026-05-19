import 'package:fin_track/core/models/logged_user.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  LoggedUser? _user;

  LoggedUser? get user => _user;

  bool get isAuthenticated => _user != null;

  void login({required String email}) {
    _user = LoggedUser(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      email: email,
    );
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
