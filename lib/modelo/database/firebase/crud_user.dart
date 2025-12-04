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
    final docSnapshot = await _firestore
        .collection(_collectionName)
        .doc(id)
        .get();
    if (docSnapshot.exists) {
      return User.fromMap(docSnapshot.data()!, docSnapshot.id);
    }
    return null;
  }

  @override
  Future<List<User>> readAll() async {
    final querySnapshot = await _firestore.collection(_collectionName).get();
    return querySnapshot.docs
        .map((doc) => User.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> update(User user) async {
    await _firestore
        .collection(_collectionName)
        .doc(user.id)
        .update(user.toMap());
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
    // 🔥 Crear usuario en FirebaseAuth
    final authResult = await fb.FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    final uid = authResult.user!.uid;

    // 🔥 Crear documento en Firestore
    final newUser = User(
      id: uid,
      nombre: nombre,
      email: email,
      password: "",
      numero: numero,
      rol: UserRole.cliente,
    );

    await _firestore.collection(_collectionName).doc(uid).set(newUser.toMap());

    return newUser;
  }

  @override
  Future<bool> existsEmail(String email) async {
    final result = await _firestore
        .collection("users")
        .where("email", isEqualTo: email)
        .get();

    return result.docs.isNotEmpty;
  }

  @override
  Future<bool> existsNumero(String numero) async {
    final result = await _firestore
        .collection("users")
        .where("numero", isEqualTo: numero)
        .get();

    return result.docs.isNotEmpty;
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
        return User.fromMap(
          userData.data(),
          userData.id,
        ).copyWith(password: '');
      }
    }
    throw Exception('Credenciales inválidas.');
  }

  @override
  Future<User> signInWithGoogle(fb.User firebaseUser) async {
    if (firebaseUser.email == null)
      throw Exception("El usuario no tiene email");

    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: firebaseUser.email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return User.fromMap(doc.data(), doc.id);
    } else {
      final newUser = User(
        id: _firestore.collection('users').doc().id,
        nombre: firebaseUser.displayName ?? 'Usuario',
        email: firebaseUser.email!,
        password: '',
        numero: null,
        rol: UserRole.cliente,
      );
      await create(newUser);
      return newUser;
    }
  }

  @override
  Future<User?> getUserById(String uid) async {
    try {
      final docSnapshot = await _firestore
          .collection(_collectionName)
          .doc(uid)
          .get();
      if (!docSnapshot.exists) return null;
      return User.fromMap(docSnapshot.data()!, docSnapshot.id);
    } catch (e) {
      // opcional: loggear
      rethrow;
    }
  }

  @override
  Future<void> updateUserPhoto(String userId, String photoUrl) async {
    try {
      await _firestore.collection(_collectionName).doc(userId).update({
        'photoUrl': photoUrl,
      });
    } catch (e) {
      throw Exception('Error al actualizar la foto de perfil: $e');
    }
  }
}
