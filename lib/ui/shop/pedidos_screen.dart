import 'package:flutter/material.dart';
import 'package:casa_joyas/logica/auth/auth_logic.dart';
import 'package:casa_joyas/ui/shop/main_screen.dart';
import 'package:casa_joyas/ui/shop/shopping_cart_ui.dart';
import 'package:casa_joyas/logica/shopping_cart_logic/shopping_cart_logic.dart';
import 'package:provider/provider.dart';

class PedidosScreen extends StatelessWidget {
  final AuthLogic authLogic;
  const PedidosScreen({super.key, required this.authLogic});
  @override
  Widget build(BuildContext context) {
    
    final cartLogic = Provider.of<ShoppingCartLogic>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('CASA DE LAS JOYAS'),
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
      body: const Center(
        child: Text(
          'Aquí se mostrará el historial de pedidos del usuario',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
      
    );
  }
}