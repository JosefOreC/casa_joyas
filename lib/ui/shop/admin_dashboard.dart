import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/logica/auth/auth_logic.dart';
import 'package:casa_joyas/ui/form/joya_crud_ui.dart';
import 'package:casa_joyas/ui/form/user_crud_ui.dart';
import 'package:casa_joyas/ui/form/order_crud_ui.dart';
import 'package:casa_joyas/ui/form/sale_crud_ui.dart';
import 'package:casa_joyas/ui/shop/main_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authLogic = Provider.of<AuthLogic>(context);
    final rol = authLogic.currentUser!.rol.name.toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Admin ($rol)'),
        backgroundColor: Colors.redAccent,
        actions: [
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.diamond, color: Colors.blue),
            title: const Text('CRUD Joyas (Inventario)'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const JoyaCRUDScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.blueGrey),
            title: const Text('CRUD Usuarios (Roles)'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserCRUDScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping, color: Colors.orange),
            title: const Text('CRUD Órdenes (Gestión de Envíos)'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrderCRUDScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart, color: Colors.teal),
            title: const Text('Reporte de Ventas'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SaleCRUDScreen())),
          ),
        ],
      ),
    );
  }
}