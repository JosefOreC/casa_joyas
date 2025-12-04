import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:casa_joyas/services/directions_service.dart';
import 'package:casa_joyas/services/polyline_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RouteMapScreen extends StatefulWidget {
  final DirectionsResponse directionsData;

  const RouteMapScreen({super.key, required this.directionsData});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _setupMap();
  }

  void _setupMap() {
    // 1. Crear marcadores
    _markers = {
      Marker(
        markerId: const MarkerId('origin'),
        position: widget.directionsData.startLocation,
        infoWindow: const InfoWindow(title: 'Tu ubicación'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: widget.directionsData.endLocation,
        infoWindow: const InfoWindow(title: 'Casa de las Joyas'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    // 2. Decodificar y crear polyline
    final points = PolylineService.decodePolyline(
      widget.directionsData.encodedPolyline,
    );

    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: Colors.blue,
        width: 5,
        patterns: [PatternItem.dash(30), PatternItem.gap(20)],
      ),
    };
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _fitBounds();
  }

  void _fitBounds() {
    // Ajustar la cámara para mostrar toda la ruta
    final bounds = _calculateBounds();
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  LatLngBounds _calculateBounds() {
    final startLat = widget.directionsData.startLocation.latitude;
    final startLng = widget.directionsData.startLocation.longitude;
    final endLat = widget.directionsData.endLocation.latitude;
    final endLng = widget.directionsData.endLocation.longitude;

    return LatLngBounds(
      southwest: LatLng(
        startLat < endLat ? startLat : endLat,
        startLng < endLng ? startLng : endLng,
      ),
      northeast: LatLng(
        startLat > endLat ? startLat : endLat,
        startLng > endLng ? startLng : endLng,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cómo Llegar')),
      body: Stack(
        children: [
          // Mapa
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.directionsData.startLocation,
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapToolbarEnabled: false,
          ),

          // Panel de información inferior
          Positioned(bottom: 0, left: 0, right: 0, child: _buildInfoPanel()),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra superior (handle)
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Información de ruta
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.straighten,
                  label: 'Distancia',
                  value: widget.directionsData.distance,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.access_time,
                  label: 'Tiempo',
                  value: widget.directionsData.duration,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.directions_car,
                  label: 'Medio',
                  value: _getModeText(widget.directionsData.mode),
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Botón para abrir en Google Maps
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openInGoogleMaps,
              icon: const Icon(Icons.map),
              label: const Text('Abrir en Google Maps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getModeText(String mode) {
    switch (mode) {
      case 'driving':
        return 'En coche';
      case 'walking':
        return 'A pie';
      case 'transit':
        return 'Transporte público';
      case 'bicycling':
        return 'En bicicleta';
      default:
        return mode;
    }
  }

  void _openInGoogleMaps() async {
    // Construir URL de Google Maps con origen y destino
    final start = widget.directionsData.startLocation;
    final end = widget.directionsData.endLocation;

    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${start.latitude},${start.longitude}'
      '&destination=${end.latitude},${end.longitude}'
      '&travelmode=${widget.directionsData.mode}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir Google Maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
