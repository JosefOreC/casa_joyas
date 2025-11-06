// Ubicación asumida: lib/data/shopping_cart_data.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:casa_joyas/modelo/products/order.dart'; 
import 'package:casa_joyas/modelo/database/shopping_cart_interface.dart';

class FirebaseCartPersistenceLogic implements CartPersistenceLogic {
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'user_carts'; 

  @override
  Future<void> saveCart(String userId, List<OrderItem> items) async {
    
    final itemsMapList = items.map((item) => item.toMap()).toList();
    
    await _firestore.collection(_collectionName).doc(userId).set({
      'userId': userId,
      'items': itemsMapList,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<OrderItem>> loadCart(String userId) async {
    final doc = await _firestore.collection(_collectionName).doc(userId).get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      final List<dynamic> itemsJson = data['items'] ?? [];
      
      return itemsJson.map((json) => OrderItem.fromMap(json)).toList();
    }
    return [];
  }

  @override
  Future<void> clearCart(String userId) async {
    await _firestore.collection(_collectionName).doc(userId).delete();
  }
}