import 'package:your_app_name/lib/modelo/products/sale.dart';

abstract class SaleCRUDLogic {
  Future<Sale?> create(Sale sale);
  Future<Sale?> read(String id);
  Future<List<Sale>> readAll();
  Future<void> update(Sale sale);
  Future<void> delete(String id);
}