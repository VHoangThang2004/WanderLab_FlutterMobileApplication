import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;
      if (userId != null) {
        Provider.of<NotificationProvider>(context, listen: false).loadNotifications(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final notifProvider = Provider.of<NotificationProvider>(context);

    if (authProvider.currentUser == null) {
      return const Center(
        child: Text(
          'Vui lòng đăng nhập để xem thông báo.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    final userId = authProvider.currentUser!.id!;

    return Scaffold(
      body: notifProvider.isLoading && notifProvider.notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : notifProvider.notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'Bạn chưa có thông báo nào.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await notifProvider.loadNotifications(userId);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifProvider.notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifProvider.notifications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: notif.isRead ? Colors.white : Colors.blue.shade50,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.notifications,
                            color: notif.isRead ? Colors.grey : Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(
                            notif.title,
                            style: TextStyle(
                              fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(notif.message),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(notif.createdAt),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          onTap: () {
                            if (!notif.isRead) {
                              notifProvider.markAsRead(notif.id!, userId);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return isoString;
    }
  }
}

