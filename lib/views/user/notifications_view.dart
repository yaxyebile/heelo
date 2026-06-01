import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<NotificationProvider>(context, listen: false)
            .load(auth.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notif = Provider.of<NotificationProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          if (auth.currentUser != null)
            TextButton(
              onPressed: () =>
                  notif.markAllRead(auth.currentUser!.id),
              child: const Text('Read all',
                  style: TextStyle(color: AppColors.primary)),
            ),
        ],
      ),
      body: notif.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : notif.items.isEmpty
              ? const Center(
                  child: Text('No notifications yet',
                      style: TextStyle(color: AppColors.textSecondaryLight)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notif.items.length,
                  itemBuilder: (_, i) {
                    final n = notif.items[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: n.isRead
                            ? const Color(0xFFF8FAFC)
                            : AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(n.title,
                            style: TextStyle(
                                fontWeight: n.isRead
                                    ? FontWeight.w600
                                    : FontWeight.w900)),
                        subtitle: Text(n.body,
                            style: const TextStyle(fontSize: 13)),
                        onTap: () => notif.markRead(n.id),
                      ),
                    );
                  },
                ),
    );
  }
}
