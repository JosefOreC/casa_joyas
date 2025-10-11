import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/logica/auth/auth_logic.dart';
import 'package:casa_joyas/logica/shopping_cart_logic/shopping_cart_logic.dart';
import 'package:casa_joyas/ui/shop/main_screen.dart';
import 'package:casa_joyas/ui/shop/shopping_cart_ui.dart';

class ClientHome extends StatelessWidget {
  const ClientHome({super.key});

  @override
  Widget build(BuildContext context) {
    final authLogic = Provider.of<AuthLogic>(context);
    final cartLogic = Provider.of<ShoppingCartLogic>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Joyas'),
        backgroundColor: Colors.pinkAccent,
        actions: [
          // Botón del Carrito
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ShoppingCartScreen()));
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
          // Botón de Cierre de Sesión
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await authLogic.signOut();
              // Vuelve al router principal (MainScreen) para forzar la redirección al Login
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenido, ${authLogic.currentUser!.nombre}!', style: const TextStyle(fontSize: 18)),
            Text('Rol: ${authLogic.currentUser!.rol.name.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            // Aquí iría el GridView o ListView del catálogo de joyas usando JoyaLogic
            const Text('--- Catálogo de Joyas ---', style: TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}