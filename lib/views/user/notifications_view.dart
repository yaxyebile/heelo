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
            .load(auth.currentUser!.id, role: auth.currentUser!.role.name);
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
                    final isPromo = n.type == 'promo';
                    final isDelivery = n.type == 'delivery';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: n.isRead
                            ? (isPromo ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC))
                            : (isPromo
                                ? const Color(0xFFFEF3C7)
                                : AppColors.primary.withValues(alpha: 0.08)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isPromo
                              ? const Color(0xFFFDE68A)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isPromo
                                ? const Color(0xFFD97706).withValues(alpha: 0.15)
                                : (isDelivery
                                    ? const Color(0xFF0284C7).withValues(alpha: 0.15)
                                    : AppColors.primary.withValues(alpha: 0.15)),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPromo
                                ? Icons.local_offer_rounded
                                : (isDelivery
                                    ? Icons.two_wheeler_rounded
                                    : Icons.notifications_active_rounded),
                            color: isPromo
                                ? const Color(0xFFD97706)
                                : (isDelivery
                                    ? const Color(0xFF0284C7)
                                    : AppColors.primary),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          n.title,
                          style: TextStyle(
                            fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w900,
                            color: isPromo ? const Color(0xFF92400E) : const Color(0xFF0F172A),
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            n.body,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                          ),
                        ),
                        onTap: () => notif.markRead(n.id),
                      ),
                    );
                  },
                ),
    );
  }
}
