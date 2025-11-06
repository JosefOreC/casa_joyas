import 'package:flutter/foundation.dart';
import 'package:casa_joyas/modelo/database/crud_joya.dart';
import 'package:casa_joyas/modelo/products/joya.dart';

class JoyaLogic extends ChangeNotifier {
  final JoyaCRUDLogic _joyaRepo;
  List<Joya> _joyas = [];
  bool _isLoading = false;

  JoyaLogic(this._joyaRepo) {
    fetchJoyas();
  }

  List<Joya> get joyas => _joyas;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchJoyas() async {
    _setLoading(true);
    try {
      _joyas = await _joyaRepo.readAll();
    } catch (e) {
      print('Error al cargar joyas: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<Joya?> readJoya(String id) async {
    try {
      // El JoyaCRUDLogic debe tener un método read(String id) para esto.
      return await _joyaRepo.read(id); 
    } catch (e) {
      // Registrar error, pero retornar null para no detener la aplicación
      if (kDebugMode) {
        print('Error al leer joya individual $id: $e');
      }
      return null;
    }
  }
  
  Future<void> addJoya(Joya joya) async {
    _setLoading(true);
    try {
      final newJoya = await _joyaRepo.create(joya);
      if (newJoya != null) {
        _joyas.add(newJoya);
      }
    } catch (e) {
      rethrow;
    } finally {
      fetchJoyas();
    }
  }

  Future<void> updateJoya(Joya joya) async {
    _setLoading(true);
    try {
      await _joyaRepo.update(joya);
    } catch (e) {
      rethrow;
    } finally {
      fetchJoyas();
    }
  }

  Future<void> deleteJoya(String id) async {
    _setLoading(true);
    try {
      await _joyaRepo.delete(id);
    } catch (e) {
      rethrow;
    } finally {
      fetchJoyas();
    }
  }
}