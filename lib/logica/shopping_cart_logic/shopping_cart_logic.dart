import 'package:flutter/foundation.dart';
import 'package:casa_joyas/modelo/products/order.dart';
import 'package:casa_joyas/modelo/products/sale.dart';
import 'package:casa_joyas/modelo/products/joya.dart';
import 'package:casa_joyas/logica/products/order_logic.dart'; 
import 'package:casa_joyas/logica/products/sale_logic.dart'; 
import 'package:casa_joyas/logica/auth/auth_logic.dart'; 

class ShoppingCartLogic extends ChangeNotifier {
  final OrderLogic _orderLogic;
  final SaleLogic _saleLogic; 
  final AuthLogic _authLogic;
  
  final List<OrderItem> _items = [];
  bool _isProcessingOrder = false;

  ShoppingCartLogic(this._orderLogic, this._saleLogic, this._authLogic); 

  List<OrderItem> get items => _items;
  bool get isProcessingOrder => _isProcessingOrder;
  double get total => _items.fold(0.0, (sum, item) => sum + (item.cantidad * item.precioUnitario));

  void _setProcessing(bool value) {
    _isProcessingOrder = value;
    notifyListeners();
  }

  void addItem(Joya joya, {int cantidad = 1, String? especificaciones}) {
    final existingIndex = _items.indexWhere((item) => item.joyaId == joya.id);

    if (existingIndex >= 0) {
      final existingItem = _items[existingIndex];
      _items[existingIndex] = OrderItem(
        joyaId: joya.id,
        joyaNombre: joya.nombre,
        cantidad: existingItem.cantidad + cantidad,
        precioUnitario: joya.precio,
        especificaciones: especificaciones ?? existingItem.especificaciones,
      );
    } else {
      _items.add(OrderItem(
        joyaId: joya.id,
        joyaNombre: joya.nombre,
        cantidad: cantidad,
        precioUnitario: joya.precio,
        especificaciones: especificaciones,
      ));
    }
    notifyListeners();
  }

  void removeItem(String joyaId) {
    _items.removeWhere((item) => item.joyaId == joyaId);
    notifyListeners();
  }
  
  void updateItemQuantity(String joyaId, int newQuantity) {
    final index = _items.indexWhere((item) => item.joyaId == joyaId);
    if (index >= 0 && newQuantity > 0) {
      final existingItem = _items[index];
      _items[index] = OrderItem(
        joyaId: existingItem.joyaId,
        joyaNombre: existingItem.joyaNombre,
        cantidad: newQuantity,
        precioUnitario: existingItem.precioUnitario,
        especificaciones: existingItem.especificaciones,
      );
    } else if (newQuantity <= 0) {
      removeItem(joyaId);
    }
    notifyListeners();
  }
  
  Future<Order?> placeOrder() async {
    if (_items.isEmpty || !_authLogic.isAuthenticated || _authLogic.currentUser == null) {
      throw Exception('El carrito está vacío o el usuario no está autenticado.');
    }
    
    _setProcessing(true);
    
    try {
      final userId = _authLogic.currentUser!.id;
      final newOrder = Order(
        id: '',
        userId: userId,
        fecha: DateTime.now(),
        total: total,
        items: List.from(_items), 
        estado: 'Pendiente',
      );
      
      final createdOrder = await _orderLogic.addOrder(newOrder); 

      if (createdOrder != null) {
        final transactionDate = createdOrder.fecha;
        for (var item in createdOrder.items) {
          final saleRecord = Sale(
            id: '', 
            orderId: createdOrder.id,
            joyaId: item.joyaId,
            cantidad: item.cantidad,
            precioUnitario: item.precioUnitario,
            fechaVenta: transactionDate,
          );
          await _saleLogic.addSale(saleRecord);
        }
      }
      
      _items.clear();
      return createdOrder;
    } catch (e) {
      rethrow;
    } finally {
      _setProcessing(false);
    }
  }
}