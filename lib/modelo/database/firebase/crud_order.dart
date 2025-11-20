import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:casa_joyas/modelo/database/crud_order.dart';
import 'package:casa_joyas/modelo/products/order.dart';

class FirebaseOrderCRUDLogic implements OrderCRUDLogic {
  final fs.FirebaseFirestore _firestore = fs.FirebaseFirestore.instance;
  final String _collectionName = 'orden';

  @override
  Future<Order?> create(Order order) async {
    final docRef = _firestore.collection(_collectionName).doc();
    await docRef.set(order.toMap());
    return order.copyWith(id: docRef.id);
  }

  @override
  Future<Order?> read(String id) async {
    final docSnapshot = await _firestore
        .collection(_collectionName)
        .doc(id)
        .get();
    if (docSnapshot.exists) {
      return Order.fromMap(docSnapshot.data()!, docSnapshot.id);
    }
    return null;
  }

  @override
  Future<List<Order>> readAll() async {
    final querySnapshot = await _firestore.collection(_collectionName).get();
    return querySnapshot.docs
        .map((doc) => Order.fromMap(doc.data()!, doc.id))
        .toList();
  }

  @override
  Future<List<Order>> readByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Asegurar que startDate sea al inicio del día y endDate al final del día
    final start = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      0,
      0,
      0,
    );
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    final querySnapshot = await _firestore
        .collection(_collectionName)
        .where('fecha', isGreaterThanOrEqualTo: fs.Timestamp.fromDate(start))
        .where('fecha', isLessThanOrEqualTo: fs.Timestamp.fromDate(end))
        .orderBy('fecha', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => Order.fromMap(doc.data()!, doc.id))
        .toList();
  }

  @override
  Future<List<Order>> readByUserId(String userId) async {
    final querySnapshot = await _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('fecha', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => Order.fromMap(doc.data()!, doc.id))
        .toList();
  }

  @override
  Future<void> update(Order order) async {
    await _firestore
        .collection(_collectionName)
        .doc(order.id)
        .update(order.toMap());
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }
}
