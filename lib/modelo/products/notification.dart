import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { orderStatusChange, orderCreated, general }

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.metadata,
  });

  factory AppNotification.fromMap(Map<String, dynamic> data, String id) {
    final timestamp = data['createdAt'];
    DateTime date = (timestamp is Timestamp)
        ? timestamp.toDate()
        : DateTime.now();

    final String typeString =
        data['type'] as String? ?? NotificationType.general.name;
    final NotificationType notifType = NotificationType.values.firstWhere(
      (e) => e.name == typeString,
      orElse: () => NotificationType.general,
    );

    return AppNotification(
      id: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: notifType,
      createdAt: date,
      isRead: data['isRead'] ?? false,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'createdAt': createdAt,
      'isRead': isRead,
      'metadata': metadata,
    };
  }
}

extension NotificationCopyExtension on AppNotification {
  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }
}
