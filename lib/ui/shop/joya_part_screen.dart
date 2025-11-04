  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:casa_joyas/logica/auth/auth_logic.dart';
  import 'package:casa_joyas/logica/shopping_cart_logic/shopping_cart_logic.dart';
  import 'package:casa_joyas/ui/shop/main_screen.dart';
  import 'package:casa_joyas/ui/shop/shopping_cart_ui.dart';
  import 'package:casa_joyas/ui/shop/catalogo_joyas_ui.dart';

  class JoyaPartScreen extends StatelessWidget {
    const JoyaPartScreen({super.key});

    @override
    Widget build(BuildContext context) {
      final authLogic = Provider.of<AuthLogic>(context);
      final cartLogic = Provider.of<ShoppingCartLogic>(context);

      final List<Widget> _pages = [
        Scaffold(
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
          body: const Padding(
            padding: EdgeInsets.all(8.0),
            child: CatalogoJoyasScreen(),
          ),
        ),
      ];

      return _pages[0];
    }
  }
