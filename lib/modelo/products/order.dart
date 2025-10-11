import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String userId;
  final DateTime fecha;
  final double total;
  final List<OrderItem> items; 
  final String estado;

  Order({
    required this.id,
    required this.userId,
    required this.fecha,
    required this.total,
    required this.items,
    this.estado = 'Pendiente',
  });

  factory Order.fromMap(Map<String, dynamic> data, String id) {
    final timestamp = data['fecha'];
    DateTime date = (timestamp is Timestamp) ? timestamp.toDate() : DateTime.now();
    
    List<OrderItem> loadedItems = (data['items'] as List<dynamic>?)
        ?.map((itemMap) => OrderItem.fromMap(itemMap as Map<String, dynamic>))
        .toList() ?? [];

    return Order(
      id: id,
      userId: data['userId'] ?? '',
      fecha: date,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      items: loadedItems,
      estado: data['estado'] ?? 'Pendiente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fecha': fecha,
      'total': total,
      'items': items.map((item) => item.toMap()).toList(), 
      'estado': estado,
    };
  }
}

class OrderItem {
  final String joyaId;
  final String joyaNombre;
  final int cantidad;
  final double precioUnitario;
  final String? especificaciones; // Campo de personalización

  OrderItem({
    required this.joyaId,
    required this.joyaNombre,
    required this.cantidad,
    required this.precioUnitario,
    this.especificaciones,
  });

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      joyaId: data['joyaId'] ?? '',
      joyaNombre: data['joyaNombre'] ?? '',
      cantidad: data['cantidad'] ?? 0,
      precioUnitario: (data['precioUnitario'] as num?)?.toDouble() ?? 0.0,
      especificaciones: data['especificaciones'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'joyaId': joyaId,
      'joyaNombre': joyaNombre,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'especificaciones': especificaciones,
    };
  }
}

extension OrderCopyExtension on Order {
  Order copyWith({String? id, String? userId, DateTime? fecha, double? total, List<OrderItem>? items, String? estado}) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fecha: fecha ?? this.fecha,
      total: total ?? this.total,
      items: items ?? this.items,
      estado: estado ?? this.estado,
    );
  }
}