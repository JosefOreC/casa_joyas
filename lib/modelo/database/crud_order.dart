import 'package:your_app_name/lib/modelo/products/order.dart';

abstract class OrderCRUDLogic {
  Future<Order?> create(Order order);
  Future<Order?> read(String id);
  Future<List<Order>> readAll();
  Future<void> update(Order order);
  Future<void> delete(String id);
}