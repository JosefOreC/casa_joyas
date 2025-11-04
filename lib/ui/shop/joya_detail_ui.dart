import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/logica/shopping_cart_logic/shopping_cart_logic.dart';
import 'package:casa_joyas/modelo/products/joya.dart';

class JoyaDetailScreen extends StatelessWidget {
  final Joya joya;

  const JoyaDetailScreen({Key? key, required this.joya}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartLogic = Provider.of<ShoppingCartLogic>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(joya.nombre),
        backgroundColor: const Color.fromARGB(255, 47, 1, 214),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            joya.imageUrl.isNotEmpty
                ? Image.network(joya.imageUrl) 
                : const Icon(Icons.image, size: 100), 
            const SizedBox(height: 20),
            Text(
              joya.nombre,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              joya.descripcion,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              '\$${joya.precio.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (joya.stock > 0) {
                  cartLogic.addItem(joya);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Añadido al carrito')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No hay stock disponible')),
                  );
                }
              },
              child: const Text('Añadir al carrito'),
            ),
          ],
        ),
      ),
    );
  }
}
