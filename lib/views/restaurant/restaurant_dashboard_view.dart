import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/store.dart';
import '../../models/product.dart';
import '../../models/order.dart';
import '../chat/chat_screen.dart';
import '../staff/add_product_view.dart';
import '../../core/services/supabase_service.dart';

class RestaurantDashboardView extends StatefulWidget {
  const RestaurantDashboardView({super.key});

  @override
  State<RestaurantDashboardView> createState() => _RestaurantDashboardViewState();
}

class _RestaurantDashboardViewState extends State<RestaurantDashboardView> {
  bool _isCreatingOrder = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final market = context.watch<MarketplaceProvider>();
    final user = auth.currentUser!;

    // Find restaurant store owned by this user
    final store = market.stores.firstWhere(
      (s) => s.ownerId == user.id,
      orElse: () => Store(
        id: '',
        name: '',
        logo: '',
        banner: '',
        description: '',
        contact: '',
        ownerId: '',
        isRestaurant: true,
      ),
    );

    if (store.id.isEmpty) return _noRestaurantView(context, auth);

    final allFood = market.getProductsByStore(store.id);
    final liveFood = allFood.where((p) => p.isApproved).toList();
    final orders = market.getOrdersByStore(store.id)
      ..sort((a, b) => b.date.compareTo(a.date));
    final revenue = market.revenueForStore(store.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── RESTAURANT APP BAR ───────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: const Color(0xFFE11D48),
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.18),
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
                    colors: [Color(0xFFE11D48), Color(0xFFBE123C), Color(0xFF9F1239)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              color: Colors.white,
                              image: store.logo.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(store.logo), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: store.logo.isEmpty
                                ? const Icon(Icons.restaurant_rounded, color: Color(0xFFE11D48), size: 26)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(store.name,
                                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Text('🍔 MAQAAYAD PORTAL',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                                ),
                              ],
                            ),
                          ),
                        ]),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.25)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD700), size: 22),
                              const SizedBox(width: 10),
                              const Text('Dakhliga Maqaayadda:',
                                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Text('\$${revenue.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── MANUAL POS ORDER BUTTON (Order Samayn) ──────────────────
                  GestureDetector(
                    onTap: () => _openManualOrderDialog(context, market, store, liveFood),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 22),
                          SizedBox(width: 10),
                          Text('➕ Dalab Cusub Samay (POS / Phone Order)',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── STATS CARDS ───────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                          child: _statCard('${liveFood.length}', 'Cuntooyinka', Icons.restaurant_menu_rounded,
                              const Color(0xFFE11D48), const Color(0xFFFFE4E6))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _statCard('${orders.length}', 'Dalabyo', Icons.receipt_long_rounded, const Color(0xFFFF6B00),
                              const Color(0xFFFFF3E0))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _statCard(
                              '${liveFood.where((f) => f.hasDiscount).length}',
                              'Discounts',
                              Icons.local_offer_rounded,
                              const Color(0xFF8B5CF6),
                              const Color(0xFFF5F3FF))),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── MENU & DISCOUNT MANAGEMENT ──────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('🍕 Menuga Cuntooyinka & Discounts',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                            context, MaterialPageRoute(builder: (_) => AddProductView(store: store))),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Cunto Cusub', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (liveFood.isEmpty)
                    _emptyBox('Weli ma jirto cunto lagu daray menuga.', Icons.restaurant_rounded)
                  else
                    ...liveFood.map((food) => _foodTile(food, market)),

                  const SizedBox(height: 32),

                  // ── INCOMING RESTAURANT ORDERS ──────────────────────────────
                  const Text('📦 Dalabyada Cuntada ee Soo Dhacay',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                  const SizedBox(height: 12),
                  if (orders.isEmpty)
                    _emptyBox('Weli ma jiro dalab soo dhacay.', Icons.shopping_bag_outlined)
                  else
                    ...orders.map((o) => _orderCard(o)),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ChatScreen(otherUserId: 'admin', otherUserName: 'System Admin'))),
        backgroundColor: const Color(0xFFE11D48),
        child: const Icon(Icons.support_agent_rounded, color: Colors.white),
      ),
    );
  }

  Widget _statCard(String v, String l, IconData icon, Color color, Color bg) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 20)),
            const SizedBox(height: 6),
            Text(v, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF1F2937))),
            Text(l, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Widget _foodTile(Product food, MarketplaceProvider market) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFF1F5F9),
              image: food.image.isNotEmpty ? DecorationImage(image: NetworkImage(food.image), fit: BoxFit.cover) : null,
            ),
            child: food.image.isEmpty ? const Icon(Icons.fastfood_rounded, color: Colors.grey) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (food.hasDiscount) ...[
                      Text('\$${food.originalPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(
                              decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                    ],
                    Text('\$${food.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFE11D48), fontSize: 13)),
                    if (food.hasDiscount) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFFFE4E6), borderRadius: BorderRadius.circular(6)),
                        child: Text('${food.discountPercent}% OFF',
                            style: const TextStyle(color: Color(0xFFE11D48), fontSize: 9, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _openDiscountDialog(context, food, market),
            icon: const Icon(Icons.local_offer_rounded, size: 14),
            label: const Text('Discount', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF8B5CF6),
              side: const BorderSide(color: Color(0xFFDDD6FE)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('#${order.id.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              const Spacer(),
              Text('\$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFE11D48), fontSize: 15)),
            ],
          ),
          const SizedBox(height: 6),
          if (order.customerName != null)
            Text('Macmiilka: ${order.customerName} (${order.customerPhone ?? ""})',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          ...order.items.map((i) => Text('${i.quantity}x ${i.productName}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _openDiscountDialog(BuildContext context, Product food, MarketplaceProvider market) {
    final priceCtrl = TextEditingController(text: food.price.toStringAsFixed(2));
    final origCtrl = TextEditingController(text: (food.originalPrice ?? food.price).toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.local_offer_rounded, color: Color(0xFF8B5CF6)),
            const SizedBox(width: 8),
            Expanded(
                child: Text('Discount: ${food.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: origCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Lacagta Asliga ah (\$)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Lacagta la dhimay (\$)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kansal')),
          ElevatedButton(
            onPressed: () async {
              final newPrice = double.tryParse(priceCtrl.text) ?? food.price;
              final newOrig = double.tryParse(origCtrl.text);
              final updated = food.copyWith(price: newPrice, originalPrice: newOrig);
              await SupabaseService.upsertProduct(updated);
              await market.refresh();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
            child: const Text('Save Discount', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _openManualOrderDialog(
      BuildContext context, MarketplaceProvider market, Store store, List<Product> foodMenu) {
    if (foodMenu.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fadlan marka hore cunto ku dar menuga!'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    Product selectedFood = foodMenu.first;
    int qty = 1;
    PaymentMethod payment = PaymentMethod.evcPlus;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.point_of_sale_rounded, color: Color(0xFF10B981), size: 24),
                  SizedBox(width: 10),
                  Text('POS Order Samayn (Direct Customer Order)',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Product>(
                value: selectedFood,
                decoration: const InputDecoration(labelText: 'Dooro Cuntada', border: OutlineInputBorder()),
                items: foodMenu
                    .map((f) => DropdownMenuItem(
                          value: f,
                          child: Text('${f.name} — \$${f.price.toStringAsFixed(2)}'),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedFood = val);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Qadarka (Quantity):', style: TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: qty > 1 ? () => setModalState(() => qty--) : null,
                  ),
                  Text('$qty', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setModalState(() => qty++),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Magaca Macmiilka', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Taleefanka Macmiilka', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'Ciwaanka / Meesha loo geynayo', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fadlan geli magaca iyo taleefanka macmiilka!')),
                      );
                      return;
                    }

                    final item = OrderItem(
                      productId: selectedFood.id,
                      productName: selectedFood.name,
                      price: selectedFood.price,
                      quantity: qty,
                      storeId: store.id,
                      storeName: store.name,
                      image: selectedFood.image,
                    );

                    final order = await market.createDirectStoreOrder(
                      storeId: store.id,
                      items: [item],
                      customerName: nameCtrl.text.trim(),
                      customerPhone: phoneCtrl.text.trim(),
                      customerAddress: addressCtrl.text.trim().isEmpty ? 'Mogadishu' : addressCtrl.text.trim(),
                      paymentMethod: payment,
                      isPaid: true,
                    );

                    if (ctx.mounted) Navigator.pop(ctx);
                    if (order != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dalabka waa la samaysay ✓ — Wuxuu u dhacay Delivery Pool-ka!'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Gudbi Dalabka (Place Order)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noRestaurantView(BuildContext context, AuthProvider auth) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(color: Color(0xFFFFE4E6), shape: BoxShape.circle),
                child: const Icon(Icons.restaurant_rounded, size: 60, color: Color(0xFFE11D48)),
              ),
              const SizedBox(height: 32),
              const Text('Wali laguma qorin Maqaayad',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
              const SizedBox(height: 12),
              const Text(
                'Fadlan la xiriir Admin-ka si maqaayaddaada loogu diiwaangeliyo nidaamka.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), height: 1.5, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => auth.logout(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2937),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ]),
          ),
        ),
      );

  Widget _emptyBox(String msg, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
        child: Center(
            child: Column(children: [
          Icon(icon, size: 40, color: const Color(0xFFCBD5E1)),
          const SizedBox(height: 8),
          Text(msg, style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
        ])),
      );
}
