import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/logica/auth/auth_logic.dart';
import 'package:casa_joyas/logica/shopping_cart_logic/shopping_cart_logic.dart';
import 'package:casa_joyas/logica/products/notification_logic.dart';
import 'package:casa_joyas/ui/shop/main_screen.dart';
import 'package:casa_joyas/ui/shop/shopping_cart_ui.dart';
import 'package:casa_joyas/ui/shop/catalogo_joyas_ui.dart';
import 'package:casa_joyas/ui/notifications/notifications_screen.dart';
import 'package:casa_joyas/ui/widgets/notification_badge.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:casa_joyas/ui/auth/login.dart';

class JoyaPartScreen extends StatefulWidget {
  const JoyaPartScreen({super.key});

  @override
  State<JoyaPartScreen> createState() => _JoyaPartScreenState();
}

class _JoyaPartScreenState extends State<JoyaPartScreen> {
  // Coordenadas estáticas de la tienda
  final LatLng _storeLocation = const LatLng(-11.950044, -75.284174);
  String _translatedAddress = 'Cargando ubicación...';

  // URL exacta que deseas lanzar al presionar el mapa estático
  final String _mapLaunchUrl = 'https://maps.app.goo.gl/LM81Aj7shPsdfCLY6';

  @override
  void initState() {
    super.initState();
    _translateCoordinatesToAddress(_storeLocation);
  }

  // --- LÓGICA DE GEOCODIFICACIÓN INVERSA ---
  Future<void> _translateCoordinatesToAddress(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address =
            'País: ${place.country ?? 'N/A'}\n' +
            'Región: ${place.administrativeArea ?? 'N/A'}\n' +
            'Ciudad: ${place.locality ?? place.subAdministrativeArea ?? 'San Jerónimo de Tunán'}\n' +
            'Calle: ${place.street ?? 'N/A'}';

        if (mounted) {
          setState(() {
            _translatedAddress = address;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _translatedAddress = 'Dirección no encontrada.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _translatedAddress = 'Error al obtener la dirección.';
        });
      }
    }
  }

  // --- FUNCIÓN AGREGADA: Abrir la URL en Maps ---
  void _launchExternalMap(BuildContext context) async {
    final uri = Uri.parse(_mapLaunchUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo abrir el mapa. Revise la URL o la configuración.',
            ),
          ),
        );
      }
    }
  }

  // --- CUADRO DE DIÁLOGO: Contiene el mapa estático clickeable ---
  void _showStoreLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('📍 ENCUÉNTRANOS AQUÍ'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Mapa Estático (Clickeable)
                GestureDetector(
                  onTap: () =>
                      _launchExternalMap(context), // <--- Redirección al link
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 50,
                          color: Colors.red[700],
                        ),
                        const Positioned(
                          top: 8,
                          child: Text(
                            'TOCA PARA ABRIR EN MAPAS EXTERNOS', // Instrucción para el usuario
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          child: Text(
                            'Lat: ${_storeLocation.latitude}, Lon: ${_storeLocation.longitude}',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Dirección traducida
                const Text(
                  'Dirección aproximada:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(_translatedAddress, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CERRAR'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authLogic = Provider.of<AuthLogic>(context);
    final cartLogic = Provider.of<ShoppingCartLogic>(context);
    final notificationLogic = Provider.of<NotificationLogic>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CASA DE LAS JOYAS'),
        backgroundColor: const Color.fromARGB(255, 47, 1, 214),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        actions: [
          // Botón Pin Drop: Abre el cuadro de diálogo
          IconButton(
            icon: const Icon(Icons.pin_drop),
            color: Colors.white,
            onPressed: () => _showStoreLocationDialog(context),
          ),

          // Ícono de notificaciones con badge
          NotificationBadge(
            count: notificationLogic.unreadCount,
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    )
                    .then((_) {
                      // Recargar contador al volver
                      if (authLogic.currentUser != null) {
                        notificationLogic.fetchUnreadNotifications(
                          authLogic.currentUser!.id,
                        );
                      }
                    });
              },
              tooltip: 'Notificaciones',
            ),
          ),

          // Carrito de compras con badge
          NotificationBadge(
            count: cartLogic.items.length,
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ShoppingCartScreen()),
                );
              },
              tooltip: 'Carrito',
            ),
          ),

          // Botón de login/logout
          IconButton(
            icon: Icon(authLogic.isAuthenticated ? Icons.logout : Icons.login),
            color: Colors.white,
            onPressed: () async {
              if (authLogic.isAuthenticated) {
                // Cerrar sesión
                await authLogic.signOut();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Sesión cerrada")));
                setState(() {});
              } else {
                // Ir a pantalla de login
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            tooltip: authLogic.isAuthenticated
                ? 'Cerrar sesión'
                : 'Iniciar sesión',
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: CatalogoJoyasScreen(),
      ),
    );
  }
}
