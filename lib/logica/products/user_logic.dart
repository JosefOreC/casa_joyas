import 'package:flutter/foundation.dart';
import 'package:casa_joyas/modelo/database/crud_user.dart';
import 'package:casa_joyas/modelo/products/user.dart';

class UserLogic extends ChangeNotifier {
  final UserCRUDLogic _userRepo;
  List<User> _users = [];
  bool _isLoading = false;

  UserLogic(this._userRepo) {
    fetchUsers();
  }

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchUsers() async {
    _setLoading(true);
    try {
      _users = await _userRepo.readAll();
    } catch (e) {
      print('Error al cargar usuarios: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUser(User user) async {
    _setLoading(true);
    try {
      await _userRepo.update(user);
    } catch (e) {
      rethrow;
    } finally {
      fetchUsers();
    }
  }

  Future<void> deleteUser(String id) async {
    _setLoading(true);
    try {
      await _userRepo.delete(id);
    } catch (e) {
      rethrow;
    } finally {
      fetchUsers();
    }
  }
}