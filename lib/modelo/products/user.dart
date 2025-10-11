enum UserRole {
  administrador,
  empleado,
  cliente,
}

class User {
  final String id;
  final String nombre;
  final String email;
  final String password;
  final String? numero;
  final UserRole rol;

  User({
    required this.id,
    required this.nombre,
    required this.email,
    required this.password,
    this.numero,
    this.rol = UserRole.cliente,
  });

  factory User.fromMap(Map<String, dynamic> data, String id) {
    final String rolString = data['rol'] as String? ?? UserRole.cliente.name;
    final UserRole userRol = UserRole.values.firstWhere(
      (e) => e.name == rolString,
      orElse: () => UserRole.cliente,
    );

    return User(
      id: id,
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '', 
      numero: data['numero'],
      rol: userRol,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'numero': numero,
      'rol': rol.name,
      'password': password,
    };
  }
}

extension UserCopyExtension on User {
  User copyWith({String? id, String? nombre, String? email, String? password, String? numero, UserRole? rol}) {
    return User(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      password: password ?? this.password,
      numero: numero ?? this.numero,
      rol: rol ?? this.rol,
    );
  }
}