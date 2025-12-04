import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/logica/auth/auth_logic.dart';
import 'package:casa_joyas/logica/products/order_logic.dart'; // NECESARIO
import 'package:casa_joyas/logica/shopping_cart_logic/shopping_cart_logic.dart';
import 'package:casa_joyas/modelo/products/order.dart'; // NECESARIO
import 'package:casa_joyas/ui/shop/main_screen.dart';
import 'package:casa_joyas/ui/shop/shopping_cart_ui.dart';
import 'package:casa_joyas/ui/auth/login.dart';
import 'package:casa_joyas/ui/shop/jewelry_search_screen.dart';
import 'package:casa_joyas/core/theme/app_colors.dart';

class PedidosScreen extends StatelessWidget {
  // Eliminamos la dependencia directa de AuthLogic en el constructor y la obtenemos por Provider.
  const PedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos todas las lógicas necesarias
    final authLogic = Provider.of<AuthLogic>(context);
    final cartLogic = Provider.of<ShoppingCartLogic>(context);
    final orderLogic = Provider.of<OrderLogic>(
      context,
    ); // Lógica para obtener el historial

    final userId = authLogic.currentUser?.id;

    // --- Verificación de Autenticación ---
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('HISTORIAL DE PEDIDOS'),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Debe iniciar sesión para ver su historial de pedidos.',
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
        foregroundColor: AppColors.white,
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
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartLogic.items.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          Consumer<AuthLogic>(
            builder: (context, authLogic, child) {
              return IconButton(
                icon: Icon(
                  authLogic.isAuthenticated ? Icons.logout : Icons.login,
                ),
                onPressed: () async {
                  if (authLogic.isAuthenticated) {
                    await authLogic.signOut();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Sesión cerrada")),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
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
            return Center(
              child: Text('Error al cargar pedidos: ${snapshot.error}'),
            );
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
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(context, order);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const JewelrySearchScreen(),
            ),
          );
        },
        backgroundColor: AppColors.violetDark,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Buscar por Foto'),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(order.estado);
    final statusIcon = _getStatusIcon(order.estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedido #${order.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.fecha != null
                            ? order.fecha.toString().substring(0, 10)
                            : 'Sin fecha',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.estado.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Order items
          ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Row(
              children: [
                Icon(
                  Icons.shopping_bag,
                  size: 20,
                  color: AppColors.goldPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${order.items?.length ?? 0} productos',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            children: (order.items ?? []).map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.joyaURL,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.joyaNombre,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Cantidad: ${item.cantidad}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (item.especificaciones != null &&
                              item.especificaciones!.isNotEmpty)
                            Text(
                              item.especificaciones!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      'S/. ${(item.cantidad * item.precioUnitario).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          // Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.goldPrimary.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'S/. ${order.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.goldPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return AppColors.warning;
      case 'en proceso':
      case 'procesando':
        return AppColors.info;
      case 'completado':
      case 'entregado':
        return AppColors.success;
      case 'cancelado':
        return AppColors.error;
      default:
        return AppColors.mediumGray;
    }
  }

  IconData _getStatusIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Icons.schedule;
      case 'en proceso':
      case 'procesando':
        return Icons.local_shipping;
      case 'completado':
      case 'entregado':
        return Icons.check_circle;
      case 'cancelado':
        return Icons.cancel;
      default:
        return Icons.receipt_long;
    }
  }
}
