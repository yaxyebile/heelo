import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/order.dart';
import '../../models/user_role.dart';
import 'manage_promos_view.dart';
import 'admin_register_user_view.dart';
import 'admin_register_store_view.dart';
import 'admin_orders_view.dart';
import 'admin_stores_revenue_view.dart';
import 'admin_payment_settings_view.dart';
import 'admin_coupons_view.dart';
import 'admin_users_view.dart';
import '../chat/admin_chat_list_view.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/widgets/colorful_hello.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth   = Provider.of<AuthProvider>(context);
    final market = Provider.of<MarketplaceProvider>(context);

    final totalRevenue   = market.orders.where((o) => o.isPaid).fold(0.0, (s, o) => s + o.totalAmount);
    final pendingOrders  = market.orders.where((o) => o.status == OrderStatus.pending).length;
    final pendingStores  = market.stores.where((s) => !s.isApproved).toList();
    final pendingProducts= market.getPendingProducts();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ────────────────────────────────────────────────
          SliverAppBar(
            pinned: true, expandedHeight: 180,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0F172A),
            elevation: 0, automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.15),
                child: IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Color(0xFF0F172A), size: 20),
                  onPressed: () => auth.logout(),
                ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Stack(children: [
                  Positioned(right: -40, top: -40,
                    child: Container(width: 200, height: 200,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        color: const Color(0xFFFF6B00).withOpacity(0.05)),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB800).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(children: [
                            Icon(Icons.shield_rounded, color: Color(0xFFFFB800), size: 14),
                            SizedBox(width: 6),
                            Text("ADMIN PANEL", style: TextStyle(color: Color(0xFFFFB800), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          ]),
                        ),
                        const SizedBox(height: 14),
                        const ColorfulHello(fontSize: 28),
                        const SizedBox(height: 4),
                        Text("Welcome, ${auth.currentUser?.name ?? 'Admin'}",
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                      ]),
                    ),
                  ),
                ]),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── Stats ────────────────────────────────────────────
                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 1.45,
                  children: [
                    _statCard("\$${totalRevenue.toStringAsFixed(0)}", "Total Revenue",
                      Icons.analytics_rounded, const Color(0xFF00D285), const Color(0xFFF0FDF4)),
                    _statCard("$pendingOrders", "Pending Orders",
                      Icons.pending_actions_rounded, const Color(0xFFFFB800), const Color(0xFFFFFBEB)),
                    _statCard("${market.allStores.length}", "Total Stores",
                      Icons.storefront_rounded, const Color(0xFFFF6B00), const Color(0xFFFFF3E0)),
                    _statCard("${market.users.where((u) => u.role == UserRole.delivery).length}", "Delivery Staff",
                      Icons.delivery_dining_rounded, const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Quick Actions ─────────────────────────────────────
                const Text("Quick Actions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.1,
                  children: [
                    _actionCard(Icons.person_add_rounded, "Register User",
                      const Color(0xFFFF6B00), const Color(0xFFFFF3E0),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRegisterUserView()))),
                    _actionCard(Icons.store_rounded, "Register Store",
                      const Color(0xFF00D285), const Color(0xFFF0FDF4),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRegisterStoreView()))),
                    _actionCard(Icons.receipt_long_rounded, "All Orders",
                      const Color(0xFF3B82F6), const Color(0xFFEFF6FF),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrdersView()))),
                    _actionCard(Icons.bar_chart_rounded, "Store Revenue",
                      const Color(0xFF8B5CF6), const Color(0xFFF5F3FF),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminStoresRevenueView()))),
                    _actionCard(Icons.view_carousel_outlined, "Promos",
                      const Color(0xFFFFB800), const Color(0xFFFFFBEB),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManagePromosView()))),
                    _actionCard(Icons.payments_rounded, "Payments",
                      const Color(0xFFEF4444), const Color(0xFFFEF2F2),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPaymentSettingsView()))),
                    _actionCard(Icons.chat_bubble_rounded, "Messages",
                      const Color(0xFF3B82F6), const Color(0xFFEFF6FF),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminChatListView()))),
                    _actionCard(Icons.local_offer_rounded, "Coupons",
                      const Color(0xFF00AA5B), const Color(0xFFF0FDF4),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCouponsView()))),
                    _actionCard(Icons.upload_file_rounded, "Export Orders",
                      const Color(0xFF64748B), const Color(0xFFF1F5F9),
                      () => Share.share(market.exportOrdersCsv(), subject: 'Helo Market Orders')),
                    _actionCard(Icons.block_rounded, "Ban Users",
                      const Color(0xFFEF4444), const Color(0xFFFFF1F2),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersView()))),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Pending Products ──────────────────────────────────
                if (pendingProducts.isNotEmpty) ...[
                  _sectionHeader("Pending Products", "${pendingProducts.length} awaiting"),
                  const SizedBox(height: 12),
                  ...pendingProducts.take(5).map((p) => _pendingProductTile(context, market, p)),
                  const SizedBox(height: 32),
                ],

                // ── Pending Stores ────────────────────────────────────
                _sectionHeader("Pending Store Approvals",
                  pendingStores.isEmpty ? "None" : "${pendingStores.length} pending"),
                const SizedBox(height: 12),
                pendingStores.isEmpty
                  ? _emptyCard("All stores are approved", Icons.check_circle_outline_rounded, const Color(0xFF00D285))
                  : Column(children: pendingStores.map((s) => _pendingStoreTile(market, s)).toList()),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String sub) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(20)),
        child: Text(sub, style: const TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.w800, fontSize: 11)),
      ),
    ],
  );

  Widget _emptyCard(String msg, IconData icon, Color color) => Container(
    padding: const EdgeInsets.symmetric(vertical: 32),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(22),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: Center(child: Column(children: [
      Icon(icon, size: 44, color: color),
      const SizedBox(height: 10),
      Text(msg, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
    ])),
  );

  Widget _statCard(String value, String label, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: color, size: 22)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF0F172A))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _actionCard(IconData icon, String label, Color color, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)))),
          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 18),
        ]),
      ),
    );
  }

  Widget _pendingProductTile(BuildContext context, MarketplaceProvider market, dynamic product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        Container(width: 54, height: 54,
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(14),
            image: product.image.isNotEmpty
              ? DecorationImage(image: NetworkImage(product.image), fit: BoxFit.cover) : null),
          child: product.image.isEmpty ? const Icon(Icons.image_outlined, color: Color(0xFFCBD5E1)) : null),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(product.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          Text(product.storeName,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          Text("\$${product.price.toStringAsFixed(2)}",
            style: const TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.w900)),
        ])),
        ElevatedButton(
          onPressed: () => market.approveProduct(product.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00D285), foregroundColor: Colors.white,
            minimumSize: const Size(80, 36),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0, textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
          child: const Text("Approve"),
        ),
      ]),
    );
  }

  Widget _pendingStoreTile(MarketplaceProvider market, dynamic store) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Row(children: [
        Container(width: 52, height: 52,
          decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFF1F5F9),
            image: store.logo.isNotEmpty
              ? DecorationImage(image: NetworkImage(store.logo), fit: BoxFit.cover) : null),
          child: store.logo.isEmpty ? const Icon(Icons.store_rounded, color: Colors.grey, size: 24) : null),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(store.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
          const SizedBox(height: 3),
          Text(store.description, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        ])),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => market.approveStore(store.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00D285), foregroundColor: Colors.white,
            minimumSize: const Size(86, 38),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0, textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
          child: const Text("Approve"),
        ),
      ]),
    );
  }
}
