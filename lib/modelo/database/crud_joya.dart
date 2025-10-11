import 'package:your_app_name/lib/modelo/products/joya.dart';

abstract class JoyaCRUDLogic {
  Future<Joya?> create(Joya joya);
  Future<Joya?> read(String id);
  Future<List<Joya>> readAll();
  Future<void> update(Joya joya);
  Future<void> delete(String id);
}