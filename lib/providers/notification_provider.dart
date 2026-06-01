import 'package:flutter/material.dart';
import '../core/services/features_service.dart';
import '../models/app_notification.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _items = [];
  bool _loading = false;

  List<AppNotification> get items => _items;
  int get unreadCount => _items.where((n) => !n.isRead).length;
  bool get isLoading => _loading;

  Future<void> load(String userId) async {
    _loading = true;
    notifyListeners();
    try {
      _items = await FeaturesService.fetchNotifications(userId);
    } catch (e) {
      debugPrint('NotificationProvider.load: $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    await FeaturesService.markNotificationRead(id);
    final i = _items.indexWhere((n) => n.id == id);
    if (i != -1) {
      _items[i] = AppNotification(
        id: _items[i].id,
        userId: _items[i].userId,
        title: _items[i].title,
        body: _items[i].body,
        type: _items[i].type,
        relatedId: _items[i].relatedId,
        isRead: true,
        createdAt: _items[i].createdAt,
      );
      notifyListeners();
    }
  }

  Future<void> markAllRead(String userId) async {
    await FeaturesService.markAllNotificationsRead(userId);
    await load(userId);
  }
}
