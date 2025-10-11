import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:casa_joyas/modelo/database/crud_user.dart';
import 'package:casa_joyas/modelo/products/user.dart';

class FirebaseUserCRUDLogic implements UserCRUDLogic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
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
  Future<User?> registerUser({required String email, required String password, required String nombre, String? numero}) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final newUserModel = User(
          id: firebaseUser.uid,
          nombre: nombre,
          email: email,
          password: password,
          numero: numero,
          rol: UserRole.cliente,
        );

        await create(newUserModel);
        
        return newUserModel;
      }
      return null;
    } on auth.FirebaseAuthException catch (e) {
      print('Error de registro: ${e.code}');
      throw Exception(e.message ?? 'Error desconocido al registrar.');
    } catch (e) {
      print('Error inesperado de registro: $e');
      throw Exception('Error inesperado.');
    }
  }

  @override
  Future<User?> signInUser({required String email, required String password}) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        return await read(firebaseUser.uid);
      }
      return null;
    } on auth.FirebaseAuthException catch (e) {
      print('Error de inicio de sesión: ${e.code}');
      throw Exception(e.message ?? 'Error desconocido al iniciar sesión.');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      return await read(firebaseUser.uid);
    }
    return null;
  }
}