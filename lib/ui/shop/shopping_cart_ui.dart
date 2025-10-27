import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/logica/shopping_cart_logic/shopping_cart_logic.dart';
import 'package:casa_joyas/modelo/products/order.dart';

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
    try {
      final order = await cartLogic.placeOrder();
      if (order != null) {
        Navigator.of(context).pop(); // Cerrar el carrito
        _showOrderSuccess(context, order.id);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar el pedido: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
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
        backgroundColor: Color.fromARGB(255, 36, 15, 230),
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
                      return _buildCartItem(context, cartLogic, item);
                    },
                  ),
                ),
                _buildCheckoutSection(context, cartLogic),
              ],
            ),
    );
  }

  Widget _buildCartItem(BuildContext context, ShoppingCartLogic cartLogic, OrderItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 2,
      child: ListTile(
        title: Text(item.joyaNombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Precio Unitario: S/. ${item.precioUnitario.toStringAsFixed(2)}'),
            if (item.especificaciones != null && item.especificaciones!.isNotEmpty)
              Text('Personalización: "${item.especificaciones}"', style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
           
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => cartLogic.updateItemQuantity(item.joyaId, item.cantidad - 1),
            ),
            
            Text('${item.cantidad}', style: const TextStyle(fontWeight: FontWeight.bold)),
            
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => cartLogic.updateItemQuantity(item.joyaId, item.cantidad + 1),
            ),
           
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => cartLogic.removeItem(item.joyaId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, ShoppingCartLogic cartLogic) {
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: cartLogic.isProcessingOrder
                  ? null
                  : () => _placeOrder(context, cartLogic),
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