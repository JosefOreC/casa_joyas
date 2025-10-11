import 'package:casa_joyas/modelo/products/user.dart';

abstract class UserCRUDLogic {
  Future<User?> create(User user);
  Future<User?> read(String id);
  Future<List<User>> readAll();
  Future<void> update(User user);
  Future<void> delete(String id);
  
  Future<User?> registerUser({required String email, required String password, required String nombre, String? numero});
  Future<User?> signInUser({required String email, required String password});
  Future<void> signOut();
  Future<User?> getCurrentUser();
}