import 'package:flutter/foundation.dart';
import 'package:casa_joyas/modelo/database/crud_user.dart';
import 'package:casa_joyas/modelo/products/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthLogic extends ChangeNotifier {
  final UserCRUDLogic _userRepo;

  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool isAuthenticated = false;
  bool isLoading = false;

  AuthLogic(this._userRepo);

  // ===========================================================
  //              CHECK LOGIN STATE (AUTO-LOGIN)
  // ===========================================================
  Future<void> checkAuthStatus() async {
    isLoading = true;
    notifyListeners();

    final firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      _currentUser = await _userRepo.read(firebaseUser.uid);
      isAuthenticated = _currentUser != null;
    } else {
      isAuthenticated = false;
    }

    isLoading = false;
    notifyListeners();
  }

  // ===========================================================
  //                   LOGIN NORMAL
  // ===========================================================
  Future<void> signIn(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      _currentUser = await _userRepo.read(uid);

      if (_currentUser == null) {
        throw Exception("El usuario no existe en Firestore.");
      }

      isAuthenticated = true;

    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_firebaseErrorMessage(e));
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _firebaseErrorMessage(fb.FirebaseAuthException e) {
    switch (e.code) {
      case "user-not-found":
        return "No existe un usuario con ese correo.";
      case "wrong-password":
        return "La contraseña es incorrecta.";
      case "invalid-email":
        return "El correo ingresado no es válido.";
      default:
        return "Error: ${e.message}";
    }
  }

  // ===========================================================
  //                   GOOGLE LOGIN CORREGIDO
  // ===========================================================
  Future<void> signInWithGoogle() async {
    isLoading = true;
    notifyListeners();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Invocar inicio de sesión
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        isLoading = false;
        notifyListeners();
        return; // Cancelado por el usuario
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Credencial para Firebase
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Inicia sesión en Firebase
      final userCredential =
          await _auth.signInWithCredential(credential);

      final fbUser = userCredential.user!;

      // Buscar usuario en Firestore
      _currentUser = await _userRepo.read(fbUser.uid);

      // Si no existe, lo crea
      if (_currentUser == null) {
        final newUser = User(
          id: fbUser.uid,
          nombre: fbUser.displayName ?? 'Usuario',
          email: fbUser.email!,
          numero: null,
          password: '',
          rol: UserRole.cliente,
        );

        await _userRepo.create(newUser);
        _currentUser = newUser;
      }

      isAuthenticated = true;
    } catch (e) {
      throw Exception("Error en login con Google: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  // ===========================================================
  //                   REGISTRO COMPLETO
  // ===========================================================
  Future<void> register(
    String email,
    String password,
    String nombre,
    String? numero,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      // Duplicados
      if (await _userRepo.existsEmail(email)) {
        throw Exception("El correo ya está registrado.");
      }

      if (numero != null && numero.isNotEmpty) {
        if (await _userRepo.existsNumero(numero)) {
          throw Exception("El número ya está registrado.");
        }
      }

      // Crear usuario en Firebase Auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      // Crear modelo
      final newUser = User(
        id: uid,
        nombre: nombre,
        email: email,
        password: "",
        numero: numero,
        rol: UserRole.cliente,
      );

      // Guardarlo en Firestore
      await _userRepo.create(newUser);

      _currentUser = newUser;
      isAuthenticated = true;

    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_firebaseErrorMessage(e));

    } catch (e) {
      throw Exception("Error en registro: $e");

    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================
  //                   LOGOUT
  // ===========================================================
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();

    _currentUser = null;
    isAuthenticated = false;
    notifyListeners();
  }
}
