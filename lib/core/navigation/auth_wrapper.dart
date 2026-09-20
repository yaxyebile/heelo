import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../views/admin/dashboard_view.dart';
import '../../views/delivery/delivery_dashboard_view.dart';
import '../../views/staff/dashboard_view.dart';
import '../../views/user/main_scaffold.dart';
import '../../views/restaurant/restaurant_dashboard_view.dart';
import '../../views/web/web_landing_page.dart';

/// Routes user to the correct app section based on role.
class AuthWrapper extends StatefulWidget {
  final int initialTab;
  const AuthWrapper({super.key, this.initialTab = 0});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showWebLanding = true;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final notifProvider = Provider.of<NotificationProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (auth.isAuthenticated) {
        notifProvider.startPolling(auth.currentUser!.id);
      } else {
        notifProvider.stopPolling();
      }
    });

    final shellKey = ValueKey('main-${auth.currentUser?.id ?? 'guest'}');

    Widget userShell() => MainScaffold(
          key: shellKey,
          initialTab: widget.initialTab,
        );

    final isDesktopWeb = kIsWeb && MediaQuery.of(context).size.width >= 850;

    if (!auth.isAuthenticated) {
      if (isDesktopWeb && _showWebLanding) {
        return WebLandingPage(
          onLaunchApp: () {
            setState(() {
              _showWebLanding = false;
            });
          },
        );
      }
      return userShell();
    }

    switch (auth.currentUser?.role) {
      case UserRole.admin:
        return const AdminDashboardView();
      case UserRole.seller:
        return const SellerDashboardView();
      case UserRole.delivery:
        return const DeliveryDashboardView();
      case UserRole.restaurant:
        return const RestaurantDashboardView();
      case UserRole.user:
      default:
        return userShell();
    }
  }
}
