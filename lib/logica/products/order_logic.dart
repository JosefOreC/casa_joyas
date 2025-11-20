import 'package:flutter/foundation.dart';
import 'package:casa_joyas/modelo/database/crud_order.dart';
import 'package:casa_joyas/modelo/products/order.dart';
import 'package:casa_joyas/logica/products/notification_logic.dart';
import 'package:casa_joyas/modelo/products/notification.dart';

class OrderLogic extends ChangeNotifier {
  final OrderCRUDLogic _orderRepo;
  final NotificationLogic? _notificationLogic;
  List<Order> _orders = [];
  bool _isLoading = false;

  // Constructor con NotificationLogic opcional
  OrderLogic(this._orderRepo, [this._notificationLogic]);

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

  // Nuevo método para obtener órdenes por rango de fechas
  Future<void> fetchOrdersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _setLoading(true);
    try {
      _orders = await _orderRepo.readByDateRange(startDate, endDate);
    } catch (e) {
      print('Error al cargar órdenes por fecha: $e');
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

  Future<void> updateOrder(Order order, {Order? previousOrder}) async {
    _setLoading(true);
    try {
      await _orderRepo.update(order);

      // Enviar notificación si el estado cambió
      if (_notificationLogic != null &&
          previousOrder != null &&
          previousOrder.estado != order.estado) {
        await _sendOrderStatusNotification(order, previousOrder.estado);
      }
    } catch (e) {
      rethrow;
    } finally {
      fetchOrders();
    }
  }

  // Método privado para enviar notificación de cambio de estado
  Future<void> _sendOrderStatusNotification(
    Order order,
    String previousStatus,
  ) async {
    String message;
    switch (order.estado) {
      case 'Procesando':
        message =
            'Tu orden #${order.id.substring(0, 8)} está siendo procesada.';
        break;
      case 'Enviada':
        message =
            'Tu orden #${order.id.substring(0, 8)} ha sido enviada y está en camino.';
        break;
      case 'Entregada':
        message =
            '¡Tu orden #${order.id.substring(0, 8)} ha sido entregada! Gracias por tu compra.';
        break;
      case 'Cancelada':
        message = 'Tu orden #${order.id.substring(0, 8)} ha sido cancelada.';
        break;
      default:
        message =
            'El estado de tu orden #${order.id.substring(0, 8)} ha cambiado a: ${order.estado}';
    }

    await _notificationLogic!.createNotification(
      userId: order.userId,
      title: 'Actualización de Orden',
      message: message,
      type: NotificationType.orderStatusChange,
      metadata: {
        'orderId': order.id,
        'previousStatus': previousStatus,
        'newStatus': order.estado,
      },
    );
  }
}
