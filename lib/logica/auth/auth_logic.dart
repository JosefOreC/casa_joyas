import 'package:flutter/foundation.dart';
import 'package:casa_joyas/modelo/database/crud_user.dart';
import 'package:casa_joyas/modelo/products/user.dart';

class AuthLogic extends ChangeNotifier {
  final UserCRUDLogic _userRepo;
  User? _currentUser;
  bool _isLoading = false;

  AuthLogic(this._userRepo);

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> register(String email, String password, String nombre, String? numero) async {
    _setLoading(true);
    try {
      final user = await _userRepo.registerUser(
        email: email,
        password: password,
        nombre: nombre,
        numero: numero,
      );
      _currentUser = user;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      final user = await _userRepo.signInUser(email: email, password: password);
      _currentUser = user;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _userRepo.signOut();
      _currentUser = null;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    _currentUser = await _userRepo.getCurrentUser();
    _setLoading(false);
  }
}