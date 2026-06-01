import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../views/admin/dashboard_view.dart';
import '../../views/delivery/delivery_dashboard_view.dart';
import '../../views/staff/dashboard_view.dart';
import '../../views/user/main_scaffold.dart';

/// Routes user to the correct app section based on role.
class AuthWrapper extends StatelessWidget {
  final int initialTab;
  const AuthWrapper({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final shellKey = ValueKey('main-${auth.currentUser?.id ?? 'guest'}');

    Widget userShell() => MainScaffold(
          key: shellKey,
          initialTab: initialTab,
        );

    if (!auth.isAuthenticated) {
      return userShell();
    }

    switch (auth.currentUser?.role) {
      case UserRole.admin:
        return const AdminDashboardView();
      case UserRole.seller:
        return const SellerDashboardView();
      case UserRole.delivery:
        return const DeliveryDashboardView();
      case UserRole.user:
      default:
        return userShell();
    }
  }
}
