class Joya {
  final String id;
  String nombre;
  final String descripcion;
  final double precio;
  final int stock;
  final String imageUrl;
  final String tipo;
  final String material;

  Joya({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.imageUrl,
    required this.material,
    required this.tipo,
  });

  Joya copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    double? precio,
    int? stock, // Campo clave para el carrito
    String? imageUrl,
    String? tipo,
    String? material,
  }) {
    return Joya(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock, // El nuevo valor de stock se aplica aquí
      imageUrl: imageUrl ?? this.imageUrl,
      material: material ?? this.material,
      tipo: tipo ?? this.tipo,
    );
  }

  factory Joya.fromMap(Map<String, dynamic> data, String id) {
    return Joya(
      id: id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      precio: (data['precio'] as num?)?.toDouble() ?? 0.0,
      stock: data['stock'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      material: data['material'] ?? '',
      tipo: data['tipo'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'imageUrl': imageUrl,
      'material': material,
      'tipo': tipo,
    };
  }
}