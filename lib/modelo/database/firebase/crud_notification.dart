import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:casa_joyas/modelo/database/crud_notification.dart';
import 'package:casa_joyas/modelo/products/notification.dart';

class FirebaseNotificationCRUDLogic implements NotificationCRUDLogic {
  final fs.FirebaseFirestore _firestore = fs.FirebaseFirestore.instance;
  final String _collectionName = 'notifications';

  @override
  Future<AppNotification?> create(AppNotification notification) async {
    final docRef = _firestore.collection(_collectionName).doc();
    await docRef.set(notification.toMap());
    return notification.copyWith(id: docRef.id);
  }

  @override
  Future<AppNotification?> read(String id) async {
    final docSnapshot = await _firestore
        .collection(_collectionName)
        .doc(id)
        .get();
    if (docSnapshot.exists) {
      return AppNotification.fromMap(docSnapshot.data()!, docSnapshot.id);
    }
    return null;
  }

  @override
  Future<List<AppNotification>> readByUserId(String userId) async {
    final querySnapshot = await _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<AppNotification>> readUnreadByUserId(String userId) async {
    final querySnapshot = await _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> update(AppNotification notification) async {
    await _firestore
        .collection(_collectionName)
        .doc(notification.id)
        .update(notification.toMap());
  }

  @override
  Future<void> markAsRead(String id) async {
    await _firestore.collection(_collectionName).doc(id).update({
      'isRead': true,
    });
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final querySnapshot = await _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }
}
