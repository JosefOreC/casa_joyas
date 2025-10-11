import 'package:flutter/foundation.dart';
import 'package:casa_joyas/modelo/database/crud_order.dart';
import 'package:casa_joyas/modelo/products/order.dart';

class OrderLogic extends ChangeNotifier {
  final OrderCRUDLogic _orderRepo;
  List<Order> _orders = [];
  bool _isLoading = false;

  OrderLogic(this._orderRepo) {
    fetchOrders();
  }

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

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