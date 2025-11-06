import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/logica/shopping_cart_logic/shopping_cart_logic.dart';
import 'package:casa_joyas/modelo/products/order.dart';
import 'package:casa_joyas/ui/shop/checkout_ui.dart'; 


class ShoppingCartScreen extends StatelessWidget {
  const ShoppingCartScreen({super.key});

  void _showOrderSuccess(BuildContext context, String orderId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pedido realizado con éxito! ID: ${orderId.substring(0, 8)}...'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _placeOrder(BuildContext context, ShoppingCartLogic cartLogic) async {
    if (cartLogic.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El carrito está vacío. Agregue productos para continuar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CheckoutScreen(),
      ),
    );
  }

  // Función que fuerza la verificación de stock para la sección de checkout
  Future<void> _checkAllStock(ShoppingCartLogic cartLogic) async {
    if (cartLogic.items.isEmpty) return;
    // Esperamos a que todas las consultas de stock terminen.
    await Future.wait(
      cartLogic.items.map((item) => cartLogic.isItemInStock(item))
    );
  }

  // Confirma y Elimina el Ítem del Carrito
  void _confirmAndRemoveItem(BuildContext context, ShoppingCartLogic cartLogic, OrderItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar "${item.joyaNombre}" del carrito?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      cartLogic.removeItem(item.joyaId); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.joyaNombre} eliminado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartLogic = Provider.of<ShoppingCartLogic>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CASA DE LAS JOYAS'),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 36, 15, 230),
      ),
      body: cartLogic.items.isEmpty
          ? const Center(
              child: Text(
                'Tu carrito está vacío.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartLogic.items.length,
                    itemBuilder: (context, index) {
                      final item = cartLogic.items[index];
                      
                      // 🚨 SOLUCIÓN: Llama al stock conocido sin FutureBuilder
                      final stockAvailable = cartLogic.getStockForItem(item.joyaId);
                      final inStock = item.cantidad <= stockAvailable;
                      
                      return _buildCartItem(context, cartLogic, item, inStock);
                    },
                  ),
                ),
                // FutureBuilder principal que garantiza que el stock esté disponible
                FutureBuilder(
                  future: _checkAllStock(cartLogic), 
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return _buildCheckoutSection(context, cartLogic);
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildCartItem(BuildContext context, ShoppingCartLogic cartLogic, OrderItem item, bool inStock) {
    final opacity = inStock ? 1.0 : 0.5;
    final stockMensaje = inStock ? 'En Stock' : 'AGOTADO';
    final stockColor = inStock ? Colors.green : Colors.red;
    
    final stockAvailable = cartLogic.getStockForItem(item.joyaId);
    final canIncrement = inStock && item.cantidad < stockAvailable; 

    return Opacity(
      opacity: opacity,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        elevation: 2,
        child: ListTile(
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(item.joyaURL),
                fit: BoxFit.cover,
              ),
            ),
            child: !inStock 
                ? const Center(
                    child: Icon(Icons.do_not_disturb_alt, color: Colors.white, size: 30),
                  )
                : null,
          ),
          
          title: Text(item.joyaNombre, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Precio Unitario: S/. ${item.precioUnitario.toStringAsFixed(2)}'),
              if (item.especificaciones != null && item.especificaciones!.isNotEmpty)
                Text('Personalización: "${item.especificaciones}"', style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
              
              Text(
                stockMensaje,
                style: TextStyle(color: stockColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón de Decremento
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: inStock 
                    ? () {
                        if (item.cantidad <= 1) {
                            _confirmAndRemoveItem(context, cartLogic, item);
                        } else {
                            cartLogic.updateItemQuantity(item.joyaId, item.cantidad - 1);
                        }
                    }
                    : null, 
              ),
              
              // Cantidad
              Text('${item.cantidad}', style: const TextStyle(fontWeight: FontWeight.bold)),
              
              // Botón de Incremento
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: canIncrement
                    ? () => cartLogic.updateItemQuantity(item.joyaId, item.cantidad + 1)
                    : null, 
              ),
              
              // Botón Eliminar (Tacho)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmAndRemoveItem(context, cartLogic, item), 
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, ShoppingCartLogic cartLogic) {
    // hasOutOfStockItem ahora usa data que fue consultada en _checkAllStock
    final hasOutOfStockItem = cartLogic.items.any((item) => item.cantidad > cartLogic.getStockForItem(item.joyaId));
    final canPlaceOrder = !cartLogic.isProcessingOrder && !hasOutOfStockItem && cartLogic.items.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                'S/. ${cartLogic.total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 36, 15, 230)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (hasOutOfStockItem)
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                '❌ Uno o más artículos tienen stock insuficiente. Actualice el carrito.',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canPlaceOrder
                  ? () => _placeOrder(context, cartLogic)
                  : null, 
              icon: cartLogic.isProcessingOrder
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.payment),
              label: Text(cartLogic.isProcessingOrder ? 'Procesando...' : 'FINALIZAR PEDIDO'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 36, 15, 230),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}