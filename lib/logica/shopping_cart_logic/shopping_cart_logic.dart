import 'package:flutter/foundation.dart';
import 'package:casa_joyas/modelo/products/order.dart';
import 'package:casa_joyas/modelo/products/sale.dart';
import 'package:casa_joyas/modelo/products/joya.dart';
import 'package:casa_joyas/logica/products/order_logic.dart'; 
import 'package:casa_joyas/logica/products/sale_logic.dart'; 
import 'package:casa_joyas/logica/auth/auth_logic.dart'; 
import 'package:casa_joyas/modelo/database/shopping_cart_interface.dart'; 
import 'package:casa_joyas/logica/products/joya_logic.dart';

class ShoppingCartLogic extends ChangeNotifier {
  final OrderLogic _orderLogic;
  final SaleLogic _saleLogic; 
  final AuthLogic _authLogic;
  final CartPersistenceLogic _cartPersistence;
  final JoyaLogic _joyaLogic; 
  
  final List<OrderItem> _items = [];
  final Map<String, int> _stockMap = {}; 
  bool _isProcessingOrder = false;

  ShoppingCartLogic(this._orderLogic, this._saleLogic, this._authLogic, this._cartPersistence, this._joyaLogic) {
    _authLogic.addListener(_onAuthChange);
    _onAuthChange();
  }

  @override
  void dispose() {
    _authLogic.removeListener(_onAuthChange);
    super.dispose();
  }

  void _onAuthChange() {
    if (_authLogic.isAuthenticated) {
      loadCart();
    } else {
      _items.clear();
      _stockMap.clear();
      notifyListeners();
    }
  }

  List<OrderItem> get items => _items;
  bool get isProcessingOrder => _isProcessingOrder;
  double get total => _items.fold(0.0, (sum, item) => sum + (item.cantidad * item.precioUnitario));

  void _setProcessing(bool value) {
    _isProcessingOrder = value;
    notifyListeners();
  }

  // --- PERSISTENCIA (Por Usuario en Firestore) ---

  Future<void> saveCart() async {
    final userId = _authLogic.currentUser?.id;
    if (userId != null) {
      await _cartPersistence.saveCart(userId, _items);
    }
  }

  Future<void> loadCart() async {
    final userId = _authLogic.currentUser?.id;
    if (userId != null) {
      _items.clear();
      final loadedItems = await _cartPersistence.loadCart(userId);
      _items.addAll(loadedItems);
      notifyListeners();
    }
  }

  // --- MODIFICACIÓN DEL CARRITO ---
  
  void addItem(Joya joya, {int cantidad = 1, String? especificaciones}) async { 
    final existingIndex = _items.indexWhere((item) => 
        item.joyaId == joya.id && 
        item.especificaciones == especificaciones
    );
    
    final availableStock = await checkAvailableStock(joya.id);
    final currentCartQuantity = existingIndex >= 0 ? _items[existingIndex].cantidad : 0;
    final finalQuantity = currentCartQuantity + cantidad;

    if (finalQuantity > availableStock) {
        throw Exception('Stock insuficiente. Solo quedan ${availableStock - currentCartQuantity} unidades de ${joya.nombre}.');
    }

    if (existingIndex >= 0) {
        final existingItem = _items[existingIndex];
        _items[existingIndex] = OrderItem(
            joyaId: joya.id,
            joyaNombre: joya.nombre,
            joyaURL: joya.imageUrl,
            cantidad: finalQuantity, 
            precioUnitario: joya.precio,
            especificaciones: especificaciones ?? existingItem.especificaciones,
        );
    } else {
        _items.add(OrderItem(
            joyaId: joya.id,
            joyaNombre: joya.nombre,
            joyaURL: joya.imageUrl,
            cantidad: cantidad,
            precioUnitario: joya.precio,
            especificaciones: especificaciones,
        ));
    }
    saveCart(); 
    notifyListeners();
  }

  void removeItem(String joyaId) {
    _items.removeWhere((item) => item.joyaId == joyaId);
    saveCart(); 
    notifyListeners();
  }
  
  void updateItemQuantity(String joyaId, int newQuantity) {
    final index = _items.indexWhere((item) => item.joyaId == joyaId);
    if (newQuantity <= 0) {
        throw Exception('Confirmación Requerida'); 
    }
    if (index >= 0) {
      final existingItem = _items[index];
      _items[index] = OrderItem(
        joyaId: existingItem.joyaId,
        joyaNombre: existingItem.joyaNombre,
        joyaURL: existingItem.joyaURL,
        cantidad: newQuantity,
        precioUnitario: existingItem.precioUnitario,
        especificaciones: existingItem.especificaciones,
      );
    }
    saveCart(); 
    notifyListeners();
  }

  // --- LÓGICA DE STOCK (CORREGIDA) ---
  
  Future<int> checkAvailableStock(String joyaId) async {
    try {
      final joya = await _joyaLogic.readJoya(joyaId); 
      return joya?.stock ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener stock para $joyaId: $e');
      }
      return 0;
    }
  }

  Future<bool> isItemInStock(OrderItem item) async {
    final stock = await checkAvailableStock(item.joyaId);
    _stockMap[item.joyaId] = stock; 
    // 🚨 CORRECCIÓN CLAVE: NOTIFYLISTENERS() ELIMINADO.
    // La interfaz de usuario (FutureBuilder) manejará la actualización.
    return item.cantidad <= stock;
  }

  int getStockForItem(String joyaId) {
    return _stockMap[joyaId] ?? 0;
  }

  // --- LÓGICA DE PEDIDO ---
  
  Future<Order?> placeOrder() async {
    final userId = _authLogic.currentUser?.id;
    if (_items.isEmpty || userId == null) {
      throw Exception('El carrito está vacío o el usuario no está autenticado. Por favor inicie sesión.');
    }
    
    // Verificación de stock final
    for (var item in _items) {
      final stockDisponible = await checkAvailableStock(item.joyaId);
      if (item.cantidad > stockDisponible) {
          throw Exception('Stock insuficiente para ${item.joyaNombre}. Solo quedan $stockDisponible unidades.');
      }
    }

    _setProcessing(true);
    
    try {
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
            joyaURL: item.joyaURL,
            cantidad: item.cantidad,
            precioUnitario: item.precioUnitario,
            fechaVenta: transactionDate,
          );
          await _saleLogic.addSale(saleRecord);

          final currentJoya = await _joyaLogic.readJoya(item.joyaId);
          if (currentJoya != null) {
            final newStock = currentJoya.stock - item.cantidad;
            final updatedJoya = currentJoya.copyWith(stock: newStock);
            await _joyaLogic.updateJoya(updatedJoya);
          }
        }
      }
      
      _items.clear();
      await _cartPersistence.clearCart(userId); 
      
      return createdOrder;
    } catch (e) {
      rethrow;
    } finally {
      _setProcessing(false);
    }
  }
}