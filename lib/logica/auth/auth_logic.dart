import 'package:flutter/foundation.dart';
import 'package:casa_joyas/modelo/database/crud_user.dart';
import 'package:casa_joyas/modelo/products/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

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
      await GoogleSignIn().signOut(); 
      _currentUser = null;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    try {
      _currentUser = await _userRepo.getCurrentUser();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final fb.UserCredential userCredential =
          await fb.FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user == null) throw Exception("Error al iniciar sesión con Google.");

      
      final user = await _userRepo.signInWithGoogle(userCredential.user!);
      _currentUser = user;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
