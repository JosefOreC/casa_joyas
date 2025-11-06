import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:casa_joyas/modelo/products/user.dart';
import 'package:casa_joyas/modelo/database/crud_user.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class FirebaseUserCRUDLogic implements UserCRUDLogic {
  final fs.FirebaseFirestore _firestore = fs.FirebaseFirestore.instance;
  final String _collectionName = 'users';

  @override
  Future<User?> create(User user) async {
    final docRef = _firestore.collection(_collectionName).doc(user.id);
    await docRef.set(user.toMap());
    return user;
  }

  @override
  Future<User?> read(String id) async {
    final docSnapshot = await _firestore.collection(_collectionName).doc(id).get();
    if (docSnapshot.exists) {
      return User.fromMap(docSnapshot.data()!, docSnapshot.id);
    }
    return null;
  }

  @override
  Future<List<User>> readAll() async {
    final querySnapshot = await _firestore.collection(_collectionName).get();
    return querySnapshot.docs.map((doc) => User.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> update(User user) async {
    await _firestore.collection(_collectionName).doc(user.id).update(user.toMap());
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }

  @override
  Future<void> signOut() async {
    // Firebase sign out se hace en AuthLogic
  }

  @override
  Future<User?> getCurrentUser() async {
    // Opcional: sincronizar con FirebaseAuth.instance.currentUser
    return null;
  }

  @override
  Future<User?> registerUser({
    required String email,
    required String password,
    required String nombre,
    String? numero,
  }) async {
    final newId = _firestore.collection(_collectionName).doc().id;

    final newUserModel = User(
      id: newId,
      nombre: nombre,
      email: email,
      password: password,
      numero: numero,
      rol: UserRole.cliente,
    );

    await create(newUserModel);
    return newUserModel.copyWith(password: '');
  }

  @override
  Future<User?> signInUser({
    required String email,
    required String password,
  }) async {
    final querySnapshot = await _firestore
        .collection(_collectionName)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final userData = querySnapshot.docs.first;
      final storedPassword = userData.data()['password'] as String?;
      if (storedPassword == password) {
        return User.fromMap(userData.data(), userData.id).copyWith(password: '');
      }
    }
    throw Exception('Credenciales inválidas.');
  }

  // --- Nuevo método para Google Sign-In ---
  Future<User?> signInWithGoogle(fb.User firebaseUser) async {
    if (firebaseUser.email == null) return null;

    // Verificar si el usuario ya existe en Firestore
    final querySnapshot = await _firestore
        .collection(_collectionName)
        .where('email', isEqualTo: firebaseUser.email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Usuario existente
      final doc = querySnapshot.docs.first;
      return User.fromMap(doc.data(), doc.id);
    } else {
      // Crear usuario nuevo en Firestore
      final newId = _firestore.collection(_collectionName).doc().id;
      final newUser = User(
        id: newId,
        nombre: firebaseUser.displayName ?? 'Usuario',
        email: firebaseUser.email!,
        password: '', // no usamos password con Google
        numero: null,
        rol: UserRole.cliente,
      );
      await create(newUser);
      return newUser;
    }
  }
}
