import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/modelo/products/order.dart';
import 'package:casa_joyas/logica/products/order_logic.dart'; 

class OrderCRUDScreen extends StatelessWidget {
  const OrderCRUDScreen({super.key});

  final List<String> _estados = const ['Pendiente', 'Procesando', 'Enviada', 'Entregada', 'Cancelada'];

  void _mostrarDialogoDetalle(BuildContext context, OrderLogic orderLogic, Order order) {
    String? estadoSeleccionado = order.estado;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalle y Estado de Orden #${order.id.substring(0, 6)}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total: S/. ${order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Fecha: ${order.fecha.toLocal().toString().split(' ')[0]}'),
                Text('Usuario ID: ${order.userId.substring(0, 6)}...'),
                const Divider(),
                const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...order.items.map((item) => Text('${item.joyaNombre} (x${item.cantidad}) - S/. ${item.precioUnitario.toStringAsFixed(2)}')),
                const Divider(),
                DropdownButtonFormField<String>(
                  value: order.estado,
                  items: _estados
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    estadoSeleccionado = value;
                  },
                  decoration: const InputDecoration(labelText: 'Cambiar Estado'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar')),
            ElevatedButton(
              onPressed: () async {
                if (estadoSeleccionado != null && estadoSeleccionado != order.estado) {
                  final orderActualizada = order.copyWith(estado: estadoSeleccionado);
                  await orderLogic.updateOrder(orderActualizada);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar Estado'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderLogic = Provider.of<OrderLogic>(context);

    if (orderLogic.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin. de Órdenes'),
        backgroundColor: Colors.orange,
      ),
      body: orderLogic.orders.isEmpty
          ? const Center(child: Text('No hay órdenes registradas.'))
          : ListView.builder(
              itemCount: orderLogic.orders.length,
              itemBuilder: (context, index) {
                final order = orderLogic.orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text('Orden #${order.id.substring(0, 8)}...'),
                    subtitle: Text('Total: S/. ${order.total.toStringAsFixed(2)} | Estado: ${order.estado}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility, color: Colors.blue),
                          onPressed: () => _mostrarDialogoDetalle(context, orderLogic, order),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}