import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/logica/products/sale_logic.dart'; 

class SaleCRUDScreen extends StatelessWidget {
  const SaleCRUDScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final saleLogic = Provider.of<SaleLogic>(context);

    if (saleLogic.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Ventas (Sólo Lectura)'),
        backgroundColor: Colors.teal,
      ),
      body: saleLogic.sales.isEmpty
          ? const Center(child: Text('No hay registros de ventas.'))
          : ListView.builder(
              itemCount: saleLogic.sales.length,
              itemBuilder: (context, index) {
                final sale = saleLogic.sales[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: const Icon(Icons.trending_up, color: Colors.teal),
                    title: Text('${sale.joyaId} (x${sale.cantidad})'),
                    subtitle: Text(
                      'Orden: ${sale.orderId.substring(0, 6)}... | Precio Unitario: S/. ${sale.precioUnitario.toStringAsFixed(2)}',
                    ),
                    trailing: Text(
                      'Total Venta: S/. ${(sale.cantidad * sale.precioUnitario).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
    );
  }
}