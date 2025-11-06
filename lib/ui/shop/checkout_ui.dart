import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/logica/shopping_cart_logic/shopping_cart_logic.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; 
import 'package:geocoding/geocoding.dart'; 
import 'package:geolocator/geolocator.dart';


class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController(text: 'Av. Principal 123');
  final _phoneController = TextEditingController();
  String _paymentMethod = 'Tarjeta de Crédito';
  
  
  LatLng _deliveryLocation = const LatLng(-12.0433, -77.0283);
  String _currentLocationMessage = 'Ubicación actual: No determinada'; 
  String _translatedAddress = 'Esperando coordenadas...'; 

  final List<String> _paymentOptions = ['Tarjeta de Crédito', 'Transferencia Bancaria', 'Pago contra Entrega'];


  @override
  void initState() {
    super.initState();
    
    _translateCoordinatesToAddress(_deliveryLocation);
  }

  
  Future<void> _translateCoordinatesToAddress(LatLng position) async {
    setState(() {
      _translatedAddress = 'Traduciendo...';
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _translatedAddress = 
              'País: ${place.country ?? 'N/A'}\n' +
              'Región: ${place.administrativeArea ?? 'N/A'}\n' +
              'Ciudad: ${place.locality ?? place.subAdministrativeArea ?? 'N/A'}\n' +
              'Calle: ${place.street ?? 'N/A'}';
        });
        // Opcional: Rellenar la dirección de referencia
        if (place.street != null && place.locality != null) {
             _addressController.text = '${place.street!}, ${place.locality!}';
        }
      } else {
        setState(() {
          _translatedAddress = 'No se encontró dirección para estas coordenadas.';
        });
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error de geocodificación: $e')),
         );
      }
      setState(() {
        _translatedAddress = 'Error al conectar con el servicio de geocodificación.';
      });
    }
  }


  // --- LÓGICA DE GEOLOCALIZACIÓN REAL (geolocator) ---
  Future<void> _getCurrentLocation() async {
    setState(() {
      _currentLocationMessage = 'Solicitando ubicación...';
    });

    bool serviceEnabled;
    LocationPermission permission;

    // 1. Verificar si los servicios de ubicación están habilitados.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentLocationMessage = 'ERROR: Servicios de ubicación deshabilitados.';
      });
      await Geolocator.openLocationSettings();
      return;
    }

    // 2. Verificar el estado de los permisos de la aplicación.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocationMessage = 'ERROR: Permiso de ubicación denegado.';
        });
        return;
      }
    }

    // 3. Obtener la posición actual
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      final LatLng newLocation = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _deliveryLocation = newLocation;
        _currentLocationMessage = 'Ubicación obtenida con precisión.';
      });

      // 4. Traducir y actualizar la dirección
      await _translateCoordinatesToAddress(newLocation);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ubicación obtenida con éxito.')),
        );
      }

    } catch (e) {
      setState(() {
        _currentLocationMessage = 'ERROR al obtener la posición: $e';
      });
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error: ${e.toString()}')),
         );
      }
    }
  }

  void _confirmOrder() async {
    final cartLogic = Provider.of<ShoppingCartLogic>(context, listen: false);
    
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese una dirección de entrega.')),
      );
      return;
    }
    
    try {
      final order = await cartLogic.placeOrder();
      
      if (order != null && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst); 
        _showOrderSuccess(context, order.id);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar el pedido: $errorMessage'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showOrderSuccess(BuildContext context, String orderId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Pedido finalizado con éxito! ID: ${orderId.substring(0, 8)}...'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartLogic = Provider.of<ShoppingCartLogic>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Pedido y Pago'),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 36, 15, 230),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Text('🚚 Detalles de la Entrega', style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),

            Container(
              height: 250, 
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.grey[200], 
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 50, color: Colors.blueGrey),
                    SizedBox(height: 10),
                    Text(
                      'MAPA (Próximamente)',
                      style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Coordenadas: Lat ${_deliveryLocation.latitude.toStringAsFixed(4)}, Lon ${_deliveryLocation.longitude.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
            const SizedBox(height: 10),
            
            // Mostrar la Dirección Traducida
            Text(
              'Dirección:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _translatedAddress,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 15),

            // Botón para Geolocalización (AHORA REAL)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _getCurrentLocation, // Llama a la ubicación real
                icon: const Icon(Icons.my_location),
                label: const Text('Usar Ubicación Actual'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentLocationMessage,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
            const SizedBox(height: 20),
            
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Dirección de Referencia (Avenida/Calle)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Teléfono de Contacto'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 30),

            // --- Sección de Pago ---
            Text('💳 Método de Pago', style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),

            Column(
              children: _paymentOptions.map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _paymentMethod,
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _paymentMethod = value;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // --- Sección de Resumen y Confirmación ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  'S/. ${cartLogic.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: cartLogic.isProcessingOrder ? null : _confirmOrder,
                icon: cartLogic.isProcessingOrder 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check_circle_outline),
                label: Text(cartLogic.isProcessingOrder ? 'Procesando...' : 'CONFIRMAR Y PAGAR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 36, 15, 230),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}