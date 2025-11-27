import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Servicio para decodificar polylines de Google Maps
class PolylineService {
  /// Decodifica un polyline codificado y retorna lista de puntos LatLng
  ///
  /// [encodedPolyline] - String codificado que representa la ruta
  ///
  /// Retorna una lista de [LatLng] que representa los puntos de la ruta
  ///
  /// Implementación del algoritmo de decodificación de Google Maps Polyline
  /// https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  static List<LatLng> decodePolyline(String encodedPolyline) {
    List<LatLng> poly = [];
    int index = 0;
    int len = encodedPolyline.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      // Decodificar latitud
      do {
        b = encodedPolyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      // Decodificar longitud
      do {
        b = encodedPolyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      // Convertir a coordenadas decimales
      double latitude = lat / 1E5;
      double longitude = lng / 1E5;

      poly.add(LatLng(latitude, longitude));
    }

    return poly;
  }
}
