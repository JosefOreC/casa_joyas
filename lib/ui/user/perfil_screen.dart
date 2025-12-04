import 'dart:io';
import 'package:flutter/material.dart';
import 'package:casa_joyas/logica/auth/auth_logic.dart';
import 'package:casa_joyas/ui/shop/main_screen.dart';
import 'package:casa_joyas/ui/shop/shopping_cart_ui.dart';
import 'package:casa_joyas/logica/shopping_cart_logic/shopping_cart_logic.dart';
import 'package:casa_joyas/logica/firebase_storage_service.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/ui/auth/login.dart';
import 'package:casa_joyas/core/theme/app_colors.dart';
import 'package:casa_joyas/ui/user/settings_screen.dart';
import 'package:image_picker/image_picker.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;

  Future<void> _pickAndUploadPhoto(
    BuildContext context,
    AuthLogic authLogic,
  ) async {
    // Mostrar diálogo para seleccionar fuente
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar foto de perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de galería'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    // Seleccionar imagen
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() {
      _uploading = true;
    });

    try {
      final File imageFile = File(image.path);
      final userId = authLogic.currentUser!.id;

      // Subir a Firebase Storage
      final photoUrl = await _storageService.uploadProfilePhoto(
        imageFile,
        userId,
      );

      // Actualizar perfil del usuario en Firestore
      await authLogic.updateUserPhoto(photoUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil actualizada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir la foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authLogic = Provider.of<AuthLogic>(context);
    final cartLogic = Provider.of<ShoppingCartLogic>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Casa de las Joyas'),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
        ),
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
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),

          /// ICONO LOGIN / LOGOUT
          IconButton(
            icon: Icon(authLogic.isAuthenticated ? Icons.logout : Icons.login),
            onPressed: () async {
              if (authLogic.isAuthenticated) {
                await authLogic.signOut();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Sesión cerrada")));
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
            ? _buildUserInfo(context, authLogic)
            : _buildNoSession(context),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, AuthLogic authLogic) {
    final user = authLogic.currentUser!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          // Foto y nombre con botón de editar
          Stack(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundImage:
                    user.photoUrl != null && user.photoUrl!.isNotEmpty
                    ? NetworkImage(user.photoUrl!)
                    : null,
                backgroundColor: AppColors.violetPrimary,
                child: user.photoUrl == null || user.photoUrl!.isEmpty
                    ? Text(
                        user.nombre.isNotEmpty
                            ? user.nombre[0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                          fontSize: 45,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              if (_uploading)
                Positioned.fill(
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.black54,
                    child: const CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _pickAndUploadPhoto(context, authLogic),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            user.nombre,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),
          Text(
            user.email,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),

          if (user.numero != null && user.numero!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              "Teléfono: ${user.numero}",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],

          const SizedBox(height: 30),

          // Card con información adicional
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
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
                  _itemTile(
                    Icons.phone_android_outlined,
                    "Número",
                    user.numero!,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Settings Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: AppColors.violetDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              label: const Text(
                'Configuración',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                await authLogic.signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sesión cerrada")),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.goldPrimary),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  Widget _buildNoSession(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Debes iniciar sesión',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Para ver tu perfil y acceder a todas las funciones, inicia sesión o regístrate.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: AppColors.violetDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              label: const Text(
                'Iniciar sesión',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
