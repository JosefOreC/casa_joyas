class Joya {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;
  final String imageUrl;

  Joya({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.imageUrl,
  });

  factory Joya.fromMap(Map<String, dynamic> data, String id) {
    return Joya(
      id: id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      precio: (data['precio'] as num?)?.toDouble() ?? 0.0,
      stock: data['stock'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'imageUrl': imageUrl,
    };
  }
}