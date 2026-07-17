import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../data/database_helper.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await DatabaseHelper.instance.getNotificationsForUser(userId);
      _notifications = data.map((map) => NotificationModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint("Lỗi tải thông báo: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId, int userId) async {
    try {
      await DatabaseHelper.instance.markNotificationAsRead(notificationId);
      await loadNotifications(userId);
    } catch (e) {
      debugPrint("Lỗi đánh dấu thông báo đã đọc: $e");
    }
  }

  Future<void> addNotification({
    required int userId,
    required String title,
    required String message,
  }) async {
    try {
      final notif = NotificationModel(
        userId: userId,
        title: title,
        message: message,
        createdAt: DateTime.now().toIso8601String(),
      );
      await DatabaseHelper.instance.insertNotification(notif.toMap());
      await loadNotifications(userId);
    } catch (e) {
      debugPrint("Lỗi thêm thông báo: $e");
    }
  }
}
