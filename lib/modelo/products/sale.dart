import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final String id;
  final String orderId;
  final String joyaId;
  final int cantidad;
  final double precioUnitario;
  final DateTime fechaVenta;

  Sale({
    required this.id,
    required this.orderId,
    required this.joyaId,
    required this.cantidad,
    required this.precioUnitario,
    required this.fechaVenta,
  });

  factory Sale.fromMap(Map<String, dynamic> data, String id) {
    final timestamp = data['fechaVenta'];
    DateTime date = (timestamp is Timestamp) ? timestamp.toDate() : DateTime.now();

    return Sale(
      id: id,
      orderId: data['orderId'] ?? '',
      joyaId: data['joyaId'] ?? '',
      cantidad: data['cantidad'] ?? 0,
      precioUnitario: (data['precioUnitario'] as num?)?.toDouble() ?? 0.0,
      fechaVenta: date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'joyaId': joyaId,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'fechaVenta': fechaVenta,
    };
  }
}