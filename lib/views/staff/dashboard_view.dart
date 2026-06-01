import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/store.dart';
import '../../models/order.dart';
import '../chat/chat_screen.dart';
import 'add_product_view.dart';
import 'seller_stats_view.dart';
import '../../core/constants/colors.dart';

class SellerDashboardView extends StatelessWidget {
  const SellerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth   = Provider.of<AuthProvider>(context);
    final market = Provider.of<MarketplaceProvider>(context);
    final user   = auth.currentUser!;

    // Find store owned by this user
    final store = market.stores.firstWhere(
      (s) => s.ownerId == user.id,
      orElse: () => Store(id: '', name: '', logo: '', banner: '', description: '', contact: '', ownerId: ''),
    );

    if (store.id.isEmpty) return _noStoreView(context, auth);

    final allProducts    = market.getProductsByStore(store.id);
    final approvedProds  = allProducts.where((p) => p.isApproved).toList();
    final pendingProds   = allProducts.where((p) => !p.isApproved).toList();
    
    // Seller sees orders for their store that are confirmed/approved/etc (not pending payment)
    final storeOrders    = market.getOrdersByStore(store.id)
        .where((o) => o.status != OrderStatus.pending)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
      
    final revenue        = market.revenueForStore(store.id);
    final lowStock       = market.lowStockProducts(store.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────────────
          SliverAppBar(
            pinned: true, expandedHeight: 230,
            backgroundColor: const Color(0xFFFF6B00),
            elevation: 0, automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.15),
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
                    colors: [Color(0xFFFF6B00), Color(0xFFD84315)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(width: 60, height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            color: const Color(0xFFF1F5F9),
                            image: store.logo.isNotEmpty
                              ? DecorationImage(image: NetworkImage(store.logo), fit: BoxFit.cover)
                              : null,
                          ),
                          child: store.logo.isEmpty
                            ? const Icon(Icons.storefront_rounded, color: Colors.grey, size: 26) : null),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(store.name,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D285).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.verified_rounded, size: 12, color: Color(0xFF00D285)),
                              SizedBox(width: 5),
                              Text("Active Store",
                                style: TextStyle(color: Color(0xFF00D285), fontSize: 11, fontWeight: FontWeight.w700)),
                            ]),
                          ),
                        ])),
                      ]),
                      const SizedBox(height: 20),
                      // Revenue row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.trending_up_rounded, color: Color(0xFF00D285), size: 20),
                          const SizedBox(width: 10),
                          const Text("My Revenue",
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text("\$${revenue.toStringAsFixed(2)}",
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                if (lowStock.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFB800)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB800)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Low stock: ${lowStock.length} product(s)',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ]),
                  ),

                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SellerStatsView(store: store)),
                  ),
                  icon: const Icon(Icons.bar_chart_rounded, color: AppColors.primary),
                  label: const Text('Sales stats',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Stats ────────────────────────────────────────────
                Row(children: [
                  Expanded(child: _statCard("${approvedProds.length}", "Active",
                    Icons.inventory_2_rounded, const Color(0xFF00D285), const Color(0xFFF0FDF4))),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard("${pendingProds.length}", "Pending",
                    Icons.hourglass_top_rounded, const Color(0xFFFFB800), const Color(0xFFFFFBEB))),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard("${storeOrders.length}", "Orders",
                    Icons.receipt_long_rounded, const Color(0xFFFF6B00), const Color(0xFFFFF3E0))),
                ]),

                const SizedBox(height: 28),

                if (store.isApproved) ...[
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => AddProductView(store: store))),
                    child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF6B00), Color(0xFFD84315)]),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: const Color(0xFFFF6B00).withOpacity(0.4),
                        blurRadius: 18, offset: const Offset(0, 8))],
                    ),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.add_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text("Add New Product", style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w900, fontSize: 16)),
                    ]),
                  ),
                ),
              ],
                
                const SizedBox(height: 32),

                // ── Products List ─────────────────────────────────────
                if (pendingProds.isNotEmpty) ...[
                  _sectionHeader("⏳ Pending Approval"),
                  const SizedBox(height: 12),
                  ...pendingProds.map((p) => _productTile(p, isPending: true)),
                  const SizedBox(height: 28),
                ],

                _sectionHeader("✅ Live Products"),
                const SizedBox(height: 12),
                approvedProds.isEmpty
                  ? _emptyBox("No live products", Icons.inventory_2_outlined)
                  : Column(children: approvedProds.map((p) => _productTile(p)).toList()),

                const SizedBox(height: 32),

                // ── Recent Orders ─────────────────────────────────────
                _sectionHeader("📦 Recent Orders"),
                const SizedBox(height: 12),
                storeOrders.isEmpty
                  ? _emptyBox("No orders yet", Icons.shopping_bag_outlined)
                  : Column(children: storeOrders.take(10).map((o) => _orderTile(o)).toList()),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => 
          const ChatScreen(otherUserId: 'admin', otherUserName: 'System Admin'))),
        backgroundColor: const Color(0xFF0F172A),
        child: const Icon(Icons.support_agent_rounded, color: Colors.white),
      ),
    );
  }

  Widget _noStoreView(BuildContext context, AuthProvider auth) => Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(color: const Color(0xFFFFF3E0), shape: BoxShape.circle),
            child: const Icon(Icons.storefront_rounded, size: 60, color: Color(0xFFFF6B00)),
          ),
          const SizedBox(height: 32),
          const Text("No Store Assigned", 
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          const Text(
            "Wali laguma qorin dukaan. Fadlan la xiriir Admin-ka si uu dukaanka kuugu diiwaangeliyo.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), height: 1.5, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => auth.logout(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Logout", style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ]),
      ),
    ),
  );


  Widget _sectionHeader(String title) => Text(title,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)));

  Widget _emptyBox(String msg, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(vertical: 28),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
    child: Center(child: Column(children: [
      Icon(icon, size: 40, color: const Color(0xFFCBD5E1)),
      const SizedBox(height: 8),
      Text(msg, style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
    ])),
  );

  Widget _statCard(String v, String l, IconData icon, Color color, Color bg) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))]),
    child: Column(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20)),
      const SizedBox(height: 8),
      Text(v, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A))),
      const SizedBox(height: 2),
      Text(l, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w700),
        textAlign: TextAlign.center),
    ]),
  );

  Widget _productTile(dynamic p, {bool isPending = false}) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
      border: isPending ? Border.all(color: const Color(0xFFFFB800).withOpacity(0.3)) : null,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
    ),
    child: Row(children: [
      Container(width: 50, height: 50,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: const Color(0xFFF1F5F9),
          image: p.image.isNotEmpty ? DecorationImage(image: NetworkImage(p.image), fit: BoxFit.cover) : null)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        Text("\$${p.price.toStringAsFixed(2)}  •  Stock: ${p.stock}",
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
      ])),
      Icon(isPending ? Icons.hourglass_top_rounded : Icons.check_circle_rounded, 
        color: isPending ? const Color(0xFFFFB800) : const Color(0xFF00D285), size: 20),
    ]),
  );

  Widget _orderTile(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
      child: Row(children: [
        Text("#${order.id.substring(0, 6).toUpperCase()}",
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        const Spacer(),
        Text("\$${order.totalAmount.toStringAsFixed(2)}",
          style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFFF6B00))),
      ]),
    );
  }
}
