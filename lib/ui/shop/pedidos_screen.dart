import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/logica/auth/auth_logic.dart';
import 'package:casa_joyas/logica/products/order_logic.dart'; // NECESARIO
import 'package:casa_joyas/logica/shopping_cart_logic/shopping_cart_logic.dart';
import 'package:casa_joyas/modelo/products/order.dart'; // NECESARIO
import 'package:casa_joyas/ui/shop/main_screen.dart';
import 'package:casa_joyas/ui/shop/shopping_cart_ui.dart';


class PedidosScreen extends StatelessWidget {
  // Eliminamos la dependencia directa de AuthLogic en el constructor y la obtenemos por Provider.
  const PedidosScreen({super.key}); 
  
  @override
  Widget build(BuildContext context) {
    // Obtenemos todas las lógicas necesarias
    final authLogic = Provider.of<AuthLogic>(context);
    final cartLogic = Provider.of<ShoppingCartLogic>(context);
    final orderLogic = Provider.of<OrderLogic>(context); // Lógica para obtener el historial

    final userId = authLogic.currentUser?.id;

    // --- Verificación de Autenticación ---
    if (userId == null) {
        return Scaffold(
            appBar: AppBar(
              title: const Text('HISTORIAL DE PEDIDOS'),
              backgroundColor: const Color.fromARGB(255, 47, 1, 214),
              foregroundColor: Colors.white,
            ),
            body: const Center(
                child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('Debe iniciar sesión para ver su historial de pedidos.', 
                                style: TextStyle(fontSize: 18, color: Colors.red),
                                textAlign: TextAlign.center,
                    ),
                ),
            ),
        );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('HISTORIAL DE PEDIDOS'),
        backgroundColor: const Color.fromARGB(255, 47, 1, 214),
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ShoppingCartScreen(),
                    ),
                  );
                },
              ),
              if (cartLogic.items.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartLogic.items.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await authLogic.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const MainScreen(),
                ),
              );
            },
          ),
        ],
      ),
      // --- Cuerpo: Carga Asíncrona del Historial ---
      body: FutureBuilder<List<Order>>(
        future: orderLogic.fetchUserOrders(userId), // <--- FILTRADO POR USUARIO
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar pedidos: ${snapshot.error}'));
          }
          
          final orders = snapshot.data;

          if (orders == null || orders.isEmpty) {
            return const Center(
              child: Text(
                'No has realizado ningún pedido aún.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          // --- Lista de Pedidos ---
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                elevation: 4,
                child: ExpansionTile(
                  leading: const Icon(Icons.receipt_long, color: Colors.indigo),
                  title: Text('Pedido #${order.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Total: S/. ${order.total.toStringAsFixed(2)} | Estado: ${order.estado}'),
                  children: (order.items ?? []).map((item){
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(item.joyaURL),
                      ),
                      title: Text('${item.joyaNombre} (x${item.cantidad})'),
                      trailing: Text('S/. ${(item.cantidad * item.precioUnitario).toStringAsFixed(2)}'),
                      subtitle: item.especificaciones != null && item.especificaciones!.isNotEmpty
                          ? Text('Nota: ${item.especificaciones}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey))
                          : null,
                    );
                  }).toList(),
                  // Muestra la fecha del pedido
                  trailing: Text(
                    // Si order.fecha es nula, muestra 'Sin Fecha' en lugar de crashear
                    order.fecha != null 
                        ? order.fecha.toString().substring(0, 10) 
                        : 'Sin Fecha',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}