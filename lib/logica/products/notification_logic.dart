import 'package:flutter/foundation.dart';
import 'package:casa_joyas/modelo/database/crud_notification.dart';
import 'package:casa_joyas/modelo/products/notification.dart';

class NotificationLogic extends ChangeNotifier {
  final NotificationCRUDLogic _notificationRepo;
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  NotificationLogic(this._notificationRepo);

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Crear una notificación
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final notification = AppNotification(
        id: '',
        userId: userId,
        title: title,
        message: message,
        type: type,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      await _notificationRepo.create(notification);
    } catch (e) {
      print('Error al crear notificación: $e');
    }
  }

  // Cargar notificaciones del usuario
  Future<void> fetchUserNotifications(String userId) async {
    _setLoading(true);
    try {
      _notifications = await _notificationRepo.readByUserId(userId);
      _updateUnreadCount();
    } catch (e) {
      print('Error al cargar notificaciones: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Obtener solo notificaciones no leídas
  Future<void> fetchUnreadNotifications(String userId) async {
    try {
      final unreadNotifications = await _notificationRepo.readUnreadByUserId(
        userId,
      );
      _unreadCount = unreadNotifications.length;
      notifyListeners();
    } catch (e) {
      print('Error al cargar notificaciones no leídas: $e');
    }
  }

  // Marcar una notificación como leída
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationRepo.markAsRead(notificationId);

      // Actualizar localmente
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index >= 0) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _updateUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      print('Error al marcar notificación como leída: $e');
    }
  }

  // Marcar todas como leídas
  Future<void> markAllAsRead(String userId) async {
    try {
      await _notificationRepo.markAllAsRead(userId);

      // Actualizar localmente
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      print('Error al marcar todas como leídas: $e');
    }
  }

  // Eliminar una notificación
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationRepo.delete(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
      notifyListeners();
    } catch (e) {
      print('Error al eliminar notificación: $e');
    }
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }
}
