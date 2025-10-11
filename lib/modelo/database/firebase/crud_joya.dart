import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:casa_joyas/modelo/database/crud_joya.dart';
import 'package:casa_joyas/modelo/products/joya.dart';

class FirebaseJoyaCRUDLogic implements JoyaCRUDLogic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'jewels';

  @override
  Future<Joya?> create(Joya joya) async {
    final docRef = _firestore.collection(_collectionName).doc();
    await docRef.set(joya.toMap());
    return joya.copyWith(id: docRef.id);
  }

  @override
  Future<Joya?> read(String id) async {
    final docSnapshot = await _firestore.collection(_collectionName).doc(id).get();
    if (docSnapshot.exists) {
      return Joya.fromMap(docSnapshot.data()!, docSnapshot.id);
    }
    return null;
  }

  @override
  Future<List<Joya>> readAll() async {
    final querySnapshot = await _firestore.collection(_collectionName).get();
    return querySnapshot.docs.map((doc) => Joya.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> update(Joya joya) async {
    await _firestore.collection(_collectionName).doc(joya.id).update(joya.toMap());
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }
}

extension JoyaExtension on Joya {
  Joya copyWith({String? id, String? nombre, String? descripcion, double? precio, int? stock, String? imageUrl}) {
    return Joya(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}