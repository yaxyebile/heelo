import 'dart:async';
import 'package:flutter/material.dart';
import '../core/services/features_service.dart';
import '../models/app_notification.dart';
import '../core/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _items = [];
  bool _loading = false;
  Timer? _pollingTimer;

  List<AppNotification> get items => _items;
  int get unreadCount => _items.where((n) => !n.isRead).length;
  bool get isLoading => _loading;

  void startPolling(String userId, {String? role}) {
    if (_pollingTimer != null) return;
    load(userId, role: role);
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      load(userId, role: role);
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }

  Future<void> load(String userId, {String? role}) async {
    _loading = true;
    notifyListeners();
    try {
      final fetched = await FeaturesService.fetchNotifications(userId, role: role);
      // Look for new unread notifications and trigger native push
      for (final item in fetched) {
        if (!item.isRead && !_items.any((old) => old.id == item.id)) {
          await LocalNotificationService.showNotification(
            id: item.id.hashCode,
            title: item.title,
            body: item.body,
          );
        }
      }
      _items = fetched;
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
