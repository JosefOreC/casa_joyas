import 'package:flutter/material.dart';
import 'package:casa_joyas/logica/auth/auth_logic.dart';
import 'package:casa_joyas/ui/shop/main_screen.dart';
import 'package:casa_joyas/ui/shop/shopping_cart_ui.dart';
import 'package:casa_joyas/logica/shopping_cart_logic/shopping_cart_logic.dart';
import 'package:provider/provider.dart';


class PerfilScreen extends StatelessWidget {
  final AuthLogic authLogic;

  const PerfilScreen({super.key, required this.authLogic});

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 100, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Bienvenido a tu perfil',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.exit_to_app),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              label: const Text('Cerrar sesión'),
              onPressed: () async {
                await authLogic.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}