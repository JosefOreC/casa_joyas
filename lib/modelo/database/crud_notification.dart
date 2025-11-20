import 'package:casa_joyas/modelo/products/notification.dart';

abstract class NotificationCRUDLogic {
  Future<AppNotification?> create(AppNotification notification);
  Future<AppNotification?> read(String id);
  Future<List<AppNotification>> readByUserId(String userId);
  Future<List<AppNotification>> readUnreadByUserId(String userId);
  Future<void> update(AppNotification notification);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead(String userId);
  Future<void> delete(String id);
}
