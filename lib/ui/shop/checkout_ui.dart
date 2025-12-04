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

  // Nuevas variables para el mapa interactivo
  String _deliveryType = 'delivery'; // 'delivery' o 'store_pickup'
  final LatLng _storeLocation = const LatLng(-11.950044, -75.284174);
  GoogleMapController? _mapController;

  final List<String> _paymentOptions = [
    'Tarjeta de Crédito',
    'Transferencia Bancaria',
    'Pago contra Entrega',
  ];

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

        // Formato para mostrar en el Container
        final displayAddress =
            'País: ${place.country ?? 'N/A'}\n'
            'Región: ${place.administrativeArea ?? 'N/A'}\n'
            'Ciudad: ${place.locality ?? place.subAdministrativeArea ?? 'N/A'}\n'
            'Calle: ${place.street ?? 'N/A'}';

        // Formato compacto para el TextField
        final compactAddress = '${place.street ?? ''}, ${place.locality ?? ''}';

        setState(() {
          _translatedAddress = displayAddress;
          _addressController.text = compactAddress.trim();
        });
      } else {
        setState(() {
          _translatedAddress =
              'No se encontró dirección para estas coordenadas.';
          _addressController.text = 'Dirección no disponible';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error de geocodificación: $e')));
      }
      setState(() {
        _translatedAddress =
            'Error al conectar con el servicio de geocodificación.';
      });
    }
  }

  // --- LÓGICA DE GEOLOCALIZACIÓN REAL (geolocator) ---
  Future<void> _getCurrentLocation() async {
    // Validar que esté en modo delivery
    if (_deliveryType == 'store_pickup') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('En modo "Recojo en Tienda" no se requiere ubicación'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _currentLocationMessage = 'Solicitando ubicación...';
    });

    bool serviceEnabled;
    LocationPermission permission;

    // 1. Verificar si los servicios de ubicación están habilitados.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentLocationMessage =
            'ERROR: Servicios de ubicación deshabilitados.';
      });
      await Geolocator.openLocationSettings();
      return;
    }

    // 2. Verificar el estado de los permisos de la aplicación.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocationMessage = 'ERROR: Permiso de ubicación denegado.';
        });
        return;
      }
    }

    // 3. Obtener la posición actual
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final LatLng newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _deliveryLocation = newLocation;
        _currentLocationMessage = 'Ubicación obtenida con precisión.';
      });

      // Animar la cámara del mapa a la nueva ubicación
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newLocation, 16),
      );

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  // --- FUNCIÓN: Callback cuando se arrastra el marcador ---
  Future<void> _onMarkerDragged(LatLng newPosition) async {
    setState(() {
      _deliveryLocation = newPosition;
    });

    // Actualizar la dirección con geocoding inverso
    await _translateCoordinatesToAddress(newPosition);
  }

  void _confirmOrder() async {
    final cartLogic = Provider.of<ShoppingCartLogic>(context, listen: false);

    // Validación mejorada según tipo de entrega
    if (_deliveryType == 'delivery' && _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, seleccione una ubicación de entrega en el mapa.',
          ),
        ),
      );
      return;
    }

    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingrese un teléfono de contacto.'),
        ),
      );
      return;
    }

    try {
      // Aquí puedes agregar lógica para guardar:
      // - _deliveryType (tipo de entrega: 'delivery' o 'store_pickup')
      // - _deliveryLocation (coordenadas LatLng)
      // - _addressController.text (dirección formateada)

      final order = await cartLogic.placeOrder();

      if (order != null && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        _showOrderSuccess(context, order.id);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar el pedido: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showOrderSuccess(BuildContext context, String orderId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '¡Pedido finalizado con éxito! ID: ${orderId.substring(0, 8)}...',
        ),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🚚 Detalles de la Entrega',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(),

            // Selector de Tipo de Entrega
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'delivery',
                  label: Text('Delivery'),
                  icon: Icon(Icons.local_shipping),
                ),
                ButtonSegment(
                  value: 'store_pickup',
                  label: Text('Recojo en Tienda'),
                  icon: Icon(Icons.store),
                ),
              ],
              selected: {_deliveryType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _deliveryType = newSelection.first;
                  if (_deliveryType == 'store_pickup') {
                    // Cambiar a ubicación de tienda
                    _deliveryLocation = _storeLocation;
                    _translateCoordinatesToAddress(_storeLocation);
                    // Centrar mapa en la tienda
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(_storeLocation, 16),
                    );
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            Container(
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: _deliveryLocation,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('delivery_location'),
                      position: _deliveryLocation,
                      draggable: _deliveryType == 'delivery',
                      onDragEnd: _deliveryType == 'delivery'
                          ? _onMarkerDragged
                          : null,
                      icon: _deliveryType == 'store_pickup'
                          ? BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed,
                            )
                          : BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueBlue,
                            ),
                      infoWindow: InfoWindow(
                        title: _deliveryType == 'store_pickup'
                            ? 'Casa de las Joyas'
                            : 'Ubicación de entrega',
                      ),
                    ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                onPressed: _deliveryType == 'delivery'
                    ? _getCurrentLocation
                    : null,
                icon: const Icon(Icons.my_location),
                label: const Text('Usar Ubicación Actual'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _deliveryType == 'delivery'
                      ? Colors.orange
                      : Colors.grey,
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
              decoration: const InputDecoration(
                labelText: 'Dirección de Entrega',
                helperText: 'Actualizada automáticamente desde el mapa',
              ),
              readOnly: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono de Contacto',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 30),

            // --- Sección de Pago ---
            Text(
              '💳 Método de Pago',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
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
                const Text(
                  'TOTAL:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'S/. ${cartLogic.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: cartLogic.isProcessingOrder ? null : _confirmOrder,
                icon: cartLogic.isProcessingOrder
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  cartLogic.isProcessingOrder
                      ? 'Procesando...'
                      : 'CONFIRMAR Y PAGAR',
                ),
                style: ElevatedButton.styleFrom(
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
