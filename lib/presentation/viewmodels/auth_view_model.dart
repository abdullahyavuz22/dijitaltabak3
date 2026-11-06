import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';

/// `AuthGate` görünümünün view model'i: oturum durumunu tutar.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel({AuthRepository? repository})
    : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  bool _ready = false;
  bool _loggedIn = false;
  bool _isAdmin = false;

  bool get ready => _ready;
  bool get loggedIn => _loggedIn;
  bool get isAdmin => _isAdmin;

  void init() {
    // Supabase yapılandırılmamışsa uygulamayı açık bırak.
    if (!_repository.isConfigured) {
      _loggedIn = true;
      _ready = true;
      notifyListeners();
      return;
    }

    _loggedIn = _repository.currentSession != null;
    _ready = true;
    notifyListeners();
    _refreshRole();

    _repository.authStateChanges.listen((data) {
      _loggedIn = data.session != null;
      notifyListeners();
      _refreshRole();
    });

    _repository.listenDeepLinks();
  }

  Future<void> _refreshRole() async {
    _isAdmin = _loggedIn ? await _repository.isCurrentUserAdmin() : false;
    notifyListeners();
  }
}
