import 'package:casa_joyas/modelo/products/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

abstract class UserCRUDLogic {
  Future<User?> create(User user);
  Future<User?> read(String id);
  Future<List<User>> readAll();
  Future<void> update(User user);
  Future<void> delete(String id);
  Future<void> signOut();
  Future<User?> getCurrentUser();
  Future<bool> existsEmail(String email);
  Future<bool> existsNumero(String numero);
  Future<User?> getUserById(String uid);

  Future<User?> registerUser({
    required String email,
    required String password,
    required String nombre,
    String? numero,
  });
  Future<User?> signInUser({required String email, required String password});

  Future<User?> signInWithGoogle(fb.User firebaseUser);

  /// Actualizar foto de perfil del usuario
  Future<void> updateUserPhoto(String userId, String photoUrl);
}
