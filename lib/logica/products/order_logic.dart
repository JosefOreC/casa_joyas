import 'package:flutter/foundation.dart';
import 'package:casa_joyas/modelo/database/crud_order.dart';
import 'package:casa_joyas/modelo/products/order.dart';

class OrderLogic extends ChangeNotifier {
  final OrderCRUDLogic _orderRepo;
  List<Order> _orders = [];
  bool _isLoading = false;

  // Constructor Limpio (sin fetchOrders() automático)
  OrderLogic(this._orderRepo);

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Mantener fetchOrders() para la vista de administrador
  Future<void> fetchOrders() async {
    _setLoading(true);
    try {
      _orders = await _orderRepo.readAll();
    } catch (e) {
      print('Error al cargar órdenes: $e');
    } finally {
      _setLoading(false);
    }
  }

  // --- MÉTODO CLAVE: fetchUserOrders (CORRECCIÓN APLICADA) ---
  Future<List<Order>> fetchUserOrders(String userId) async {
    // ELIMINAMOS _setLoading(true/false) para evitar el bucle de reconstrucción.
    try {
      final userOrders = await _orderRepo.readByUserId(userId); 
      return userOrders;
    } catch (e) {
      print('Error al cargar órdenes del usuario $userId: $e');
      // Si el error es la falta de índice, la consola lo mostrará.
      rethrow; // Relanzamos el error para que FutureBuilder pueda mostrarlo
    }
  }
  // -------------------------------------------------------------

  Future<Order?> addOrder(Order order) async {
    try {
      final newOrder = await _orderRepo.create(order);
      if (newOrder != null) {
        _orders.add(newOrder);
        notifyListeners(); 
      }
      return newOrder;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateOrder(Order order) async {
    _setLoading(true);
    try {
      await _orderRepo.update(order);
    } catch (e) {
      rethrow;
    } finally {
      fetchOrders(); 
    }
  }
}