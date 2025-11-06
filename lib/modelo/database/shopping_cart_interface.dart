
import 'package:casa_joyas/modelo/products/order.dart';

abstract class CartPersistenceLogic {
  
  Future<void> saveCart(String userId, List<OrderItem> items);
  
  Future<List<OrderItem>> loadCart(String userId);

  Future<void> clearCart(String userId);
}