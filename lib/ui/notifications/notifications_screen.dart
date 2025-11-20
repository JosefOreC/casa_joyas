import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casa_joyas/logica/products/notification_logic.dart';
import 'package:casa_joyas/logica/auth/auth_logic.dart';
import 'package:casa_joyas/modelo/products/notification.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('es', timeago.EsMessages());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  void _loadNotifications() {
    final authLogic = Provider.of<AuthLogic>(context, listen: false);
    final notificationLogic = Provider.of<NotificationLogic>(
      context,
      listen: false,
    );

    if (authLogic.currentUser != null) {
      notificationLogic.fetchUserNotifications(authLogic.currentUser!.id);
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.orderStatusChange:
        return Icons.local_shipping;
      case NotificationType.orderCreated:
        return Icons.shopping_bag;
      case NotificationType.general:
        return Icons.info;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.orderStatusChange:
        return Colors.blue;
      case NotificationType.orderCreated:
        return Colors.green;
      case NotificationType.general:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authLogic = Provider.of<AuthLogic>(context);
    final notificationLogic = Provider.of<NotificationLogic>(context);

    if (authLogic.currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notificaciones'),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(
          child: Text('Debes iniciar sesión para ver notificaciones'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (notificationLogic.unreadCount > 0)
            TextButton.icon(
              onPressed: () async {
                await notificationLogic.markAllAsRead(
                  authLogic.currentUser!.id,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Todas las notificaciones marcadas como leídas',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.done_all, color: Colors.white),
              label: const Text(
                'Marcar todas',
                style: TextStyle(color: Colors.white),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: notificationLogic.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationLogic.notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes notificaciones',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => _loadNotifications(),
              child: ListView.builder(
                itemCount: notificationLogic.notifications.length,
                itemBuilder: (context, index) {
                  final notification = notificationLogic.notifications[index];
                  final icon = _getNotificationIcon(notification.type);
                  final color = _getNotificationColor(notification.type);

                  return Dismissible(
                    key: Key(notification.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirmar'),
                            content: const Text('¿Eliminar esta notificación?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text(
                                  'Eliminar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      notificationLogic.deleteNotification(notification.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notificación eliminada'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      elevation: notification.isRead ? 0 : 2,
                      color: notification.isRead
                          ? Colors.white
                          : color.withOpacity(0.05),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.2),
                          child: Icon(icon, color: color),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: notification.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              notification.message,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              timeago.format(
                                notification.createdAt,
                                locale: 'es',
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          if (!notification.isRead) {
                            await notificationLogic.markAsRead(notification.id);
                          }

                          // Si tiene metadata de orden, podríamos navegar a los detalles
                          if (notification.metadata != null &&
                              notification.metadata!.containsKey('orderId')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Orden: ${notification.metadata!['orderId']}',
                                ),
                                action: SnackBarAction(
                                  label: 'Ver Pedidos',
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pop(); // Volver al home
                                    // El usuario puede ir a la pestaña de pedidos
                                  },
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
