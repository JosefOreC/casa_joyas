import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:casa_joyas/modelo/database/crud_sale.dart';
import 'package:casa_joyas/modelo/products/sale.dart';

class FirebaseSaleCRUDLogic implements SaleCRUDLogic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'venta';

  @override
  Future<Sale?> create(Sale sale) async {
    final docRef = _firestore.collection(_collectionName).doc();
    await docRef.set(sale.toMap());
    return sale.copyWith(id: docRef.id);
  }

  @override
  Future<Sale?> read(String id) async {
    final docSnapshot = await _firestore.collection(_collectionName).doc(id).get();
    if (docSnapshot.exists) {
      return Sale.fromMap(docSnapshot.data()!, docSnapshot.id);
    }
    return null;
  }

  @override
  Future<List<Sale>> readAll() async {
    final querySnapshot = await _firestore.collection(_collectionName).get();
    return querySnapshot.docs.map((doc) => Sale.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> update(Sale sale) async {
    await _firestore.collection(_collectionName).doc(sale.id).update(sale.toMap());
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }
}


extension SaleExtension on Sale {
  Sale copyWith({String? id, String? orderId, String? joyaId, int? cantidad, double? precioUnitario, DateTime? fechaVenta}) {
    return Sale(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      joyaId: joyaId ?? this.joyaId,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      fechaVenta: fechaVenta ?? this.fechaVenta,
    );
  }
}