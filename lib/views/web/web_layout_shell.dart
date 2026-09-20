import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/l10n/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/notification_provider.dart';
import '../user/cart_view.dart';
import '../user/search_view.dart';
import '../user/notifications_view.dart';
import '../auth/login_view.dart';
import 'web_landing_page.dart';

class WebLayoutShell extends StatefulWidget {
  final Widget child;
  final int currentTab;
  final ValueChanged<int>? onTabSelected;

  const WebLayoutShell({
    super.key,
    required this.child,
    this.currentTab = 0,
    this.onTabSelected,
  });

  @override
  State<WebLayoutShell> createState() => _WebLayoutShellState();
}

class _WebLayoutShellState extends State<WebLayoutShell> {
  int _cartItemCount(MarketplaceProvider market) {
    var n = 0;
    for (final items in market.cart.values) {
      n += items.length;
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 850;
    final market = Provider.of<MarketplaceProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final notif = Provider.of<NotificationProvider>(context);
    final cartCount = _cartItemCount(market);

    if (!isDesktop) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          // Desktop Top Web Navbar
          Container(
            height: 72,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1380),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // Brand & Logo
                      GestureDetector(
                        onTap: () {
                          if (widget.onTabSelected != null) {
                            widget.onTabSelected!(0);
                          }
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text('E', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'EMARA',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimaryLight,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('WEB', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 32),

                      // Desktop Navigation Tabs
                      _navTabItem(0, Icons.home_rounded, 'Boga Hore (Home)'),
                      _navTabItem(1, Icons.grid_view_rounded, 'Qaybaha (Categories)'),
                      _navTabItem(2, Icons.storefront_rounded, 'Dukaamada (Stores)'),
                      _navTabItem(3, Icons.widgets_rounded, 'Adeegyada (Services)'),
                      _navTabItem(4, Icons.person_rounded, 'Profile'),

                      const Spacer(),

                      // Search Button Shortcut
                      IconButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchView())),
                        icon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                        tooltip: 'Raadi...',
                      ),

                      const SizedBox(width: 8),

                      // Notifications Button
                      if (auth.isAuthenticated) ...[
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              onPressed: () {
                                notif.load(auth.currentUser!.id);
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsView()));
                              },
                              icon: const Icon(Icons.notifications_outlined, color: Color(0xFF64748B)),
                            ),
                            if (notif.unreadCount > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Cart Button
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartView())),
                            icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF64748B)),
                          ),
                          if (cartCount > 0)
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                child: Text(
                                  '$cartCount',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(width: 16),

                      // Landing Page Toggle Button
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const WebLandingPage()));
                        },
                        icon: const Icon(Icons.web_asset_rounded, size: 16),
                        label: const Text('Landing Page'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Auth / Profile Button
                      if (!auth.isAuthenticated) ...[
                        ElevatedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginView())),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          child: const Text('Soo Gasho'),
                        ),
                      ] else ...[
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Text(
                            auth.currentUser?.name.isNotEmpty == true ? auth.currentUser!.name[0].toUpperCase() : 'U',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Web Content Wrapper
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1380),
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navTabItem(int index, IconData icon, String label) {
    final isSelected = widget.currentTab == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton.icon(
        onPressed: () {
          if (widget.onTabSelected != null) {
            widget.onTabSelected!(index);
          }
        },
        icon: Icon(
          icon,
          size: 18,
          color: isSelected ? AppColors.primary : const Color(0xFF64748B),
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : const Color(0xFF334155),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      ),
    );
  }
}
