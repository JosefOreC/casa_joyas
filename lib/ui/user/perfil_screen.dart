import 'package:flutter/material.dart';
import 'package:casa_joyas/logica/auth/auth_logic.dart';
import 'package:casa_joyas/ui/shop/main_screen.dart';
import 'package:casa_joyas/ui/shop/shopping_cart_ui.dart';
import 'package:casa_joyas/logica/shopping_cart_logic/shopping_cart_logic.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/ui/auth/login.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authLogic = Provider.of<AuthLogic>(context);
    final cartLogic = Provider.of<ShoppingCartLogic>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CASA DE LAS JOYAS'),
        backgroundColor: const Color.fromARGB(255, 47, 1, 214),
        foregroundColor: Colors.white,
        actions: [
          /// ICONO DEL CARRITO
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

          /// ICONO LOGIN / LOGOUT
          IconButton(
            icon: Icon(
              authLogic.isAuthenticated ? Icons.logout : Icons.login,
            ),
            onPressed: () async {
              if (authLogic.isAuthenticated) {
                await authLogic.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Sesión cerrada")),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),

      /// CONTENIDO DEL PERFIL
      body: Center(
        child: authLogic.isAuthenticated && authLogic.currentUser != null
            ? _buildUserInfo(authLogic)
            : _buildNoSession(context),
      ),
    );
  }

  Widget _buildUserInfo(AuthLogic authLogic) {
  final user = authLogic.currentUser!;

  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
    child: Column(
      children: [
        // Foto y nombre
        CircleAvatar(
          radius: 55,
          backgroundColor: const Color(0xFF304FFE),
          child: Text(
            user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : "?",
            style: const TextStyle(fontSize: 45, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          user.nombre,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 8),
        Text(
          user.email,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),

        if (user.numero != null && user.numero!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            "Teléfono: ${user.numero}",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],

        const SizedBox(height: 30),

        // Card con información adicional
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: const Offset(0, 4),
                color: Colors.black.withOpacity(0.1),
              ),
            ],
          ),
          child: Column(
            children: [
              _itemTile(Icons.person_outline, "Nombre", user.nombre),
              _itemTile(Icons.email_outlined, "Correo", user.email),
              if (user.numero != null)
                _itemTile(Icons.phone_android_outlined, "Número", user.numero!),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Botón cerrar sesión
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.exit_to_app),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            label: const Text(
              'Cerrar sesión',
              style: TextStyle(fontSize: 18),
            ),
            onPressed: () async {
              await authLogic.signOut();
            },
          ),
        ),
      ],
    ),
  );
}

  /// Widget reutilizable para cada item de información
  Widget _itemTile(IconData icon, String title, String value) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.blueAccent),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }


  // 🔶 Vista cuando NO hay usuario logueado
  Widget _buildNoSession(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_outline, size: 100, color: Colors.grey),
        const SizedBox(height: 20),
        const Text(
          "No has iniciado sesión",
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text("Iniciar sesión"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
      ],
    );
  }
}
