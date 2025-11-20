import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/logica/auth/auth_logic.dart';
import 'package:casa_joyas/logica/products/notification_logic.dart';
import 'package:casa_joyas/ui/shop/joya_part_screen.dart';
import 'package:casa_joyas/ui/shop/pedidos_screen.dart';
import 'package:casa_joyas/ui/user/perfil_screen.dart';

class ClientHome extends StatefulWidget {
  const ClientHome({super.key});

  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Cargar notificaciones no leídas al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authLogic = Provider.of<AuthLogic>(context, listen: false);
      final notificationLogic = Provider.of<NotificationLogic>(
        context,
        listen: false,
      );

      if (authLogic.currentUser != null) {
        notificationLogic.fetchUnreadNotifications(authLogic.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const JoyaPartScreen(),
      const PedidosScreen(),
      const PerfilScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.diamond_outlined),
            label: 'Joyas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
