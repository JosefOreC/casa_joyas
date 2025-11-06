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
    final docSnapshot = await _firestore.collection(_collectionName).doc(id).get();
    if (docSnapshot.exists) {
      return Order.fromMap(docSnapshot.data()!, docSnapshot.id);
    }
    return null;
  }

  @override
  Future<List<Order>> readAll() async {
    final querySnapshot = await _firestore.collection(_collectionName).get();
    return querySnapshot.docs.map((doc) => Order.fromMap(doc.data()!, doc.id)).toList();
  }

  @override
  Future<List<Order>> readByUserId(String userId) async {
    final querySnapshot = await _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId) 
        .orderBy('fecha', descending: true) 
        .get();

    // Asegúrate de que Order.fromMap maneje correctamente la conversión de Timestamp a DateTime
    return querySnapshot.docs.map((doc) => Order.fromMap(doc.data()!, doc.id)).toList();
  }
  // -----------------------------------------------------------------

  @override
  Future<void> update(Order order) async {
    await _firestore.collection(_collectionName).doc(order.id).update(order.toMap());
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }
}