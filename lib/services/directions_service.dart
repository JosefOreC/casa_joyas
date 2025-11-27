import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:casa_joyas/core/constants/api_constants.dart';

/// Modelo de respuesta de Google Directions API
class DirectionsResponse {
  final String distance;
  final String duration;
  final String mode;
  final String encodedPolyline;
  final LatLng startLocation;
  final LatLng endLocation;

  DirectionsResponse({
    required this.distance,
    required this.duration,
    required this.mode,
    required this.encodedPolyline,
    required this.startLocation,
    required this.endLocation,
  });

  factory DirectionsResponse.fromJson(Map<String, dynamic> json, String mode) {
    // Obtener la primera ruta y su primera etapa (leg)
    final route = json['routes'][0];
    final leg = route['legs'][0];

    return DirectionsResponse(
      distance: leg['distance']['text'],
      duration: leg['duration']['text'],
      mode: mode,
      encodedPolyline: route['overview_polyline']['points'],
      startLocation: LatLng(
        leg['start_location']['lat'],
        leg['start_location']['lng'],
      ),
      endLocation: LatLng(
        leg['end_location']['lat'],
        leg['end_location']['lng'],
      ),
    );
  }
}

/// Servicio para obtener direcciones desde Google Directions API
class DirectionsService {
  /// Obtiene las direcciones entre dos puntos
  ///
  /// [origin] - Ubicación de origen
  /// [destination] - Ubicación de destino
  /// [mode] - Modo de transporte: 'driving', 'walking', 'transit', 'bicycling'
  ///
  /// Retorna un [DirectionsResponse] con la información de la ruta
  /// o null si hay un error
  Future<DirectionsResponse?> getDirections({
    required LatLng origin,
    required LatLng destination,
    String mode = 'driving',
  }) async {
    try {
      // Construir la URL con los parámetros
      final originStr = '${origin.latitude},${origin.longitude}';
      final destinationStr = '${destination.latitude},${destination.longitude}';

      final url = Uri.parse(
        '${ApiConstants.directionsBaseUrl}'
        '?origin=$originStr'
        '&destination=$destinationStr'
        '&key=${ApiConstants.googleMapsApiKey}'
        '&mode=$mode',
      );

      // Hacer la petición HTTP GET
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );

      // Verificar el código de estado HTTP
      if (response.statusCode != 200) {
        throw Exception('Error HTTP: ${response.statusCode}');
      }

      // Parsear la respuesta JSON
      final data = json.decode(response.body);

      // Verificar el estado de la respuesta de la API
      final status = data['status'];

      if (status != 'OK') {
        // Manejar diferentes estados de error
        switch (status) {
          case 'NOT_FOUND':
            throw Exception('No se pudo encontrar una ruta');
          case 'ZERO_RESULTS':
            throw Exception('No hay rutas disponibles');
          case 'MAX_WAYPOINTS_EXCEEDED':
            throw Exception('Demasiados puntos de ruta');
          case 'INVALID_REQUEST':
            throw Exception('Solicitud inválida');
          case 'OVER_QUERY_LIMIT':
            throw Exception('Límite de consultas excedido');
          case 'REQUEST_DENIED':
            throw Exception('Solicitud denegada - Verifique la API key');
          case 'UNKNOWN_ERROR':
            throw Exception('Error desconocido en el servidor');
          default:
            throw Exception('Error: $status');
        }
      }

      // Verificar que haya rutas en la respuesta
      if (data['routes'] == null || (data['routes'] as List).isEmpty) {
        throw Exception('No se encontraron rutas');
      }

      // Crear y retornar el objeto DirectionsResponse
      return DirectionsResponse.fromJson(data, mode);
    } on http.ClientException catch (e) {
      // Error de red
      throw Exception('Error de red: ${e.message}');
    } catch (e) {
      // Otros errores
      rethrow;
    }
  }
}
