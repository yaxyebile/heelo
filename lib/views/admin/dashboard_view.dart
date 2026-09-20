import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/order.dart';
import '../../models/user_role.dart';
import 'manage_promos_view.dart';
import 'admin_restaurants_view.dart';
import 'admin_register_user_view.dart';
import 'admin_register_store_view.dart';
import 'admin_orders_view.dart';
import 'admin_stores_revenue_view.dart';
import 'admin_payment_settings_view.dart';
import 'admin_coupons_view.dart';
import 'admin_users_view.dart';
import 'admin_cargo_ads_view.dart';
import 'admin_property_listings_view.dart';
import 'admin_property_bookings_view.dart';
import 'admin_second_hand_view.dart';
import '../chat/admin_chat_list_view.dart';
import 'roles_management/admin_roles_dashboard.dart';
import 'admin_technician_pricing_view.dart';
import 'admin_technician_bookings_view.dart';
import 'admin_register_technician_view.dart';
import 'admin_categories_view.dart';
import 'admin_broadcast_notifications_view.dart';
import '../../core/widgets/colorful_hello.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final market = Provider.of<MarketplaceProvider>(context);

    final totalRevenue = market.orders.where((o) => o.isPaid).fold(0.0, (s, o) => s + o.totalAmount);
    final pendingOrders = market.orders.where((o) => o.status == OrderStatus.pending).length;
    final pendingStores = market.stores.where((s) => !s.isApproved).toList();
    final pendingProducts = market.getPendingProducts();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () => market.refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            // ── PREMIUM SLIVER APP BAR ──────────────────────────────────────
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              backgroundColor: const Color(0xFF0F172A),
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 8),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.12),
                    child: IconButton(
                      icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                      onPressed: () => auth.logout(),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFF6B00).withOpacity(0.08),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B00).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFFF6B00).withOpacity(0.4)),
                              ),
                              child: const Row(children: [
                                Icon(Icons.shield_rounded, color: Color(0xFFFF6B00), size: 14),
                                SizedBox(width: 6),
                                Text("SYSTEM COMMAND CENTER",
                                    style: TextStyle(
                                        color: Color(0xFFFF9E43),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1)),
                              ]),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00D285).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(children: [
                                CircleAvatar(radius: 4, backgroundColor: Color(0xFF00D285)),
                                SizedBox(width: 6),
                                Text("Live WAAFI API Active",
                                    style: TextStyle(color: Color(0xFF00D285), fontSize: 10, fontWeight: FontWeight.w800)),
                              ]),
                            ),
                          ]),
                          const SizedBox(height: 14),
                          const ColorfulHello(fontSize: 26),
                          const SizedBox(height: 4),
                          Text("Logged as ${auth.currentUser?.name ?? 'Admin'} • System Administrator",
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500)),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // ── OVERVIEW STATS GRID ─────────────────────────────────────
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.45,
                    children: [
                      _statCard(
                        "\$${totalRevenue.toStringAsFixed(0)}",
                        "Total Revenue",
                        Icons.analytics_rounded,
                        const Color(0xFF00D285),
                        const Color(0xFFF0FDF4),
                        trend: "Verified Paid",
                      ),
                      _statCard(
                        "$pendingOrders",
                        "Pending Orders",
                        Icons.pending_actions_rounded,
                        const Color(0xFFFFB800),
                        const Color(0xFFFFFBEB),
                        trend: pendingOrders > 0 ? "Needs Review" : "All Clear",
                      ),
                      _statCard(
                        "${market.allStores.length}",
                        "Registered Stores",
                        Icons.storefront_rounded,
                        const Color(0xFFFF6B00),
                        const Color(0xFFFFF3E0),
                        trend: "${pendingStores.length} Pending",
                      ),
                      _statCard(
                        "${market.users.where((u) => u.role == UserRole.delivery).length}",
                        "Active Drivers",
                        Icons.delivery_dining_rounded,
                        const Color(0xFF8B5CF6),
                        const Color(0xFFF5F3FF),
                        trend: "First-Come Pool",
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── CATEGORY 1: PAYMENTS & REVENUE ─────────────────────────
                  _categoryTitle("⚡ Payments & Finance", "WAAFI Pay API, Revenue & Discounts"),
                  const SizedBox(height: 12),
                  _actionGrid([
                    _actionCard(
                      Icons.payments_rounded,
                      "WAAFI Pay API",
                      "EVC Auto Settings",
                      const Color(0xFFFF6B00),
                      const Color(0xFFFFF3E0),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPaymentSettingsView())),
                    ),
                    _actionCard(
                      Icons.receipt_long_rounded,
                      "All Orders",
                      "${market.orders.length} Total Orders",
                      const Color(0xFF3B82F6),
                      const Color(0xFFEFF6FF),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrdersView())),
                    ),
                    _actionCard(
                      Icons.bar_chart_rounded,
                      "Store Revenue",
                      "Earnings & Payouts",
                      const Color(0xFF8B5CF6),
                      const Color(0xFFF5F3FF),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminStoresRevenueView())),
                    ),
                    _actionCard(
                      Icons.local_offer_rounded,
                      "Coupons",
                      "Promotional Codes",
                      const Color(0xFF00AA5B),
                      const Color(0xFFF0FDF4),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCouponsView())),
                    ),
                  ]),

                  const SizedBox(height: 28),

                  // ── CATEGORY 2: USERS & STORES MANAGEMENT ─────────────────
                  _categoryTitle("🛍️ Stores & User Accounts", "Registration, Moderation & Roles"),
                  const SizedBox(height: 12),
                  _actionGrid([
                    _actionCard(
                      Icons.person_add_rounded,
                      "Register User",
                      "Add Customer / Admin",
                      const Color(0xFFFF6B00),
                      const Color(0xFFFFF3E0),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRegisterUserView())),
                    ),
                    _actionCard(
                      Icons.restaurant_rounded,
                      "Maqaayadaha",
                      "Cuntooyinka & Dakhliga",
                      const Color(0xFFE11D48),
                      const Color(0xFFFFE4E6),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRestaurantsView())),
                    ),
                    _actionCard(
                      Icons.store_rounded,
                      "Register Store",
                      "New Vendor Setup",
                      const Color(0xFF00D285),
                      const Color(0xFFF0FDF4),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRegisterStoreView())),
                    ),
                    _actionCard(
                      Icons.manage_accounts_rounded,
                      "Roles & Access",
                      "Permissions Mgmt",
                      const Color(0xFF6366F1),
                      const Color(0xFFEEF2FF),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRolesDashboard())),
                    ),
                    _actionCard(
                      Icons.block_rounded,
                      "Manage Users",
                      "Ban & Filter Profiles",
                      const Color(0xFFEF4444),
                      const Color(0xFFFFF1F2),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersView())),
                    ),
                    _actionCard(
                      Icons.category_rounded,
                      "Categories",
                      "Manage Categories",
                      const Color(0xFF0284C7),
                      const Color(0xFFF0F9FF),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCategoriesView())),
                    ),
                    _actionCard(
                      Icons.view_carousel_outlined,
                      "Home Banners",
                      "Manage Promos",
                      const Color(0xFFFFB800),
                      const Color(0xFFFFFBEB),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManagePromosView())),
                    ),
                    _actionCard(
                      Icons.chat_bubble_rounded,
                      "Support Chat",
                      "Live Messages",
                      const Color(0xFF3B82F6),
                      const Color(0xFFEFF6FF),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminChatListView())),
                    ),
                  ]),

                  const SizedBox(height: 28),

                  // ── CATEGORY 3: CARGO & REAL ESTATE ──────────────────────
                  _categoryTitle("🚚 Logistics, Real Estate & Market", "Cargo, House Listings & Second Hand"),
                  const SizedBox(height: 12),
                  _actionGrid([
                    _actionCard(
                      Icons.flight_takeoff_rounded,
                      "Cargo Ads",
                      "International Shipping",
                      const Color(0xFF0A0E27),
                      const Color(0xFFEFF6FF),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCargoAdsView())),
                    ),
                    _actionCard(
                      Icons.home_work_rounded,
                      "Real Estate",
                      "Property Listings",
                      const Color(0xFFFF6B00),
                      const Color(0xFFFFF3E0),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPropertyListingsView())),
                    ),
                    _actionCard(
                      Icons.bookmark_added_rounded,
                      "Bookings",
                      "House Reservations",
                      const Color(0xFFE65100),
                      const Color(0xFFFFF3E0),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPropertyBookingsView())),
                    ),
                    _actionCard(
                      Icons.swap_horiz_rounded,
                      "Second Hand",
                      "Pre-owned Listings",
                      const Color(0xFF2563EB),
                      const Color(0xFFF5F3FF),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSecondHandView())),
                    ),
                  ]),

                  const SizedBox(height: 28),

                  // ── CATEGORY 4: FARSAMO / SERVICES ───────────────────────
                  _categoryTitle("🛠️ Farsamo (Services & Techs)", "Technicians & Booking Approvals"),
                  const SizedBox(height: 12),
                  _actionGrid([
                    _actionCard(
                      Icons.price_change_rounded,
                      "Farsamo Pricing",
                      "Service Categories",
                      const Color(0xFFF97316),
                      const Color(0xFFFFF3E0),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTechnicianPricingView())),
                    ),
                    _actionCard(
                      Icons.assignment_rounded,
                      "Farsamo Bookings",
                      "Technician Requests",
                      const Color(0xFF2563EB),
                      const Color(0xFFEFF6FF),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTechnicianBookingsView())),
                    ),
                    _actionCard(
                      Icons.handyman_rounded,
                      "Register Tech",
                      "Add New Specialist",
                      const Color(0xFF10B981),
                      const Color(0xFFECFDF5),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRegisterTechnicianView())),
                    ),
                    _actionCard(
                      Icons.send_rounded,
                      "Broadcast Alert",
                      "Push Notifications",
                      const Color(0xFF0F172A),
                      const Color(0xFFF1F5F9),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBroadcastNotificationsView())),
                    ),
                  ]),

                  const SizedBox(height: 28),

                  // ── CATEGORY 5: UTILITIES ───────────────────────────────
                  _categoryTitle("📊 Utilities & Reports", "System Exports & Backup"),
                  const SizedBox(height: 12),
                  _actionGrid([
                    _actionCard(
                      Icons.upload_file_rounded,
                      "Export Orders CSV",
                      "Download Spreadsheet",
                      const Color(0xFF64748B),
                      const Color(0xFFF1F5F9),
                      () => Share.share(market.exportOrdersCsv(), subject: 'EMARA System Orders'),
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // ── PENDING APPROVALS SECTIONS ─────────────────────────────
                  if (pendingProducts.isNotEmpty) ...[
                    _sectionHeader("Pending Products Approval", "${pendingProducts.length} awaiting review"),
                    const SizedBox(height: 12),
                    ...pendingProducts.take(5).map((p) => _pendingProductTile(context, market, p)),
                    const SizedBox(height: 28),
                  ],

                  _sectionHeader("Pending Store Approvals", pendingStores.isEmpty ? "All Verified" : "${pendingStores.length} Pending"),
                  const SizedBox(height: 12),
                  pendingStores.isEmpty
                      ? _emptyCard("Dhammaan dukaamada waa la ansixiyay ✓", Icons.check_circle_outline_rounded, const Color(0xFF00D285))
                      : Column(children: pendingStores.map((s) => _pendingStoreTile(market, s)).toList()),

                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryTitle(String title, String subtitle) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
      const SizedBox(height: 2),
      Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _sectionHeader(String title, String sub) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(20)),
            child: Text(sub, style: const TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.w800, fontSize: 11)),
          ),
        ],
      );

  Widget _emptyCard(String msg, IconData icon, Color color) => Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Center(
            child: Column(children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(msg, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700, fontSize: 13)),
        ])),
      );

  Widget _statCard(String value, String label, IconData icon, Color color, Color bg, {required String trend}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.18)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 20),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Text(trend, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
          ),
        ]),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF1F2937))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _actionGrid(List<Widget> children) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.1,
      children: children,
    );
  }

  Widget _actionCard(IconData icon, String title, String sub, Color color, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1F2937))),
                const SizedBox(height: 2),
                Text(sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                image: product.image.isNotEmpty ? DecorationImage(image: NetworkImage(product.image), fit: BoxFit.cover) : null),
            child: product.image.isEmpty ? const Icon(Icons.image_outlined, color: Color(0xFFCBD5E1)) : null),
        const SizedBox(width: 14),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(product.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          Text(product.storeName, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          Text("\$${product.price.toStringAsFixed(2)}",
              style: const TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.w900)),
        ])),
        ElevatedButton(
          onPressed: () => market.approveProduct(product.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00D285),
            foregroundColor: Colors.white,
            minimumSize: const Size(80, 36),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
            textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Row(children: [
        Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF1F5F9),
                image: store.logo.isNotEmpty ? DecorationImage(image: NetworkImage(store.logo), fit: BoxFit.cover) : null),
            child: store.logo.isEmpty ? const Icon(Icons.store_rounded, color: Colors.grey, size: 24) : null),
        const SizedBox(width: 14),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(store.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1F2937))),
          const SizedBox(height: 3),
          Text(store.description,
              maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        ])),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => market.approveStore(store.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00D285),
            foregroundColor: Colors.white,
            minimumSize: const Size(86, 38),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
            textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
          child: const Text("Approve"),
        ),
      ]),
    );
  }
}
