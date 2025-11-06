import 'package:casa_joyas/modelo/products/order.dart';

abstract class OrderCRUDLogic {
  Future<Order?> create(Order order);
  Future<Order?> read(String id);
  Future<List<Order>> readAll();
  Future<void> update(Order order);
  Future<void> delete(String id);
  Future<List<Order>> readByUserId(String userId); 
}