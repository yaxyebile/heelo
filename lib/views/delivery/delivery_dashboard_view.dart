import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/order.dart';
import '../chat/chat_screen.dart';
import 'live_tracking_view.dart';

class DeliveryDashboardView extends StatefulWidget {
  const DeliveryDashboardView({super.key});

  @override
  State<DeliveryDashboardView> createState() => _DeliveryDashboardViewState();
}

class _DeliveryDashboardViewState extends State<DeliveryDashboardView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _busyOrderId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureGpsEnabled(context);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<bool> _ensureGpsEnabled(BuildContext context) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!context.mounted) return false;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.location_off_rounded, color: Color(0xFFEF4444), size: 26),
                SizedBox(width: 10),
                Expanded(
                  child: Text('📍 GPS-ka Shid (Qasab)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ],
            ),
            content: const Text(
              'Wadaha Delivery-ga waxaa QASAB ku ah inuu GPS-ka moobaylkiisa shido mar walba.\n\n'
              'Fadlan taabo badhanka hoose si aad u shiddo GPS-ka, ka dibna sii wad gaarsiinta.',
              style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Kansal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await Geolocator.openLocationSettings();
                },
                icon: const Icon(Icons.settings_rounded, size: 18),
                label: const Text('Shid GPS-ka', style: TextStyle(fontWeight: FontWeight.w900)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        if (!context.mounted) return false;
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Location Permission', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            content: const Text(
              'Fadlan sii ogolaansho (Permission) Location-ka si loo ogaado meesha aad marayso.',
              style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Kansal', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await Geolocator.openAppSettings();
                },
                child: const Text('Aad Settings'),
              ),
            ],
          ),
        );
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('_ensureGpsEnabled error: $e');
      return true;
    }
  }

  Future<bool> _confirmDelivered(BuildContext context, Order order) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Color(0xFF00D285), size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text('Macmiilka ma gaaray?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ),
          ],
        ),
        content: Text(
          '${order.customerName ?? "Macmiilka"} — alaabtu ma gaartay?\n\n'
          'Taabo "Haa, waa gaartay" marka aad dhab ahaan u gaarsiisid.\n'
          'Kadib dalabku wuxuu u gudbi doonaa tab-ka 3-aad (La dhammeeyay).',
          style: const TextStyle(height: 1.45, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Maya', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D285),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: const Text('Haa, waa gaartay ✓', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final market = context.watch<MarketplaceProvider>();
    final uid = auth.currentUser!.id;

    final assignedPending = market.getAssignedDeliveries(uid)..sort((a, b) => b.date.compareTo(a.date));
    final availableOrders = market.getUnassignedApprovedOrders()..sort((a, b) => b.date.compareTo(a.date));
    final myOrders = market.getOrdersByDelivery(uid)..sort((a, b) => b.date.compareTo(a.date));
    final gaarsiinOrders = myOrders.where((o) => o.status == OrderStatus.outForDelivery).toList();
    final completedOrders = myOrders.where((o) => o.status == OrderStatus.delivered).toList();

    final totalPoolCount = assignedPending.length + availableOrders.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ── DRIVER HEADER APP BAR ───────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 170,
            backgroundColor: const Color(0xFF4F46E5),
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
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF9333EA)],
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 14),
                                SizedBox(width: 6),
                                Text('DELIVERY DRIVER',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.4)),
                            ),
                            child: const Row(children: [
                              CircleAvatar(radius: 4, backgroundColor: Color(0xFF10B981)),
                              SizedBox(width: 6),
                              Text("Active Driver",
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                            ]),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        Text('Ahlan, ${auth.currentUser?.name ?? "Driver"}! 🛵',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(
                          '$totalPoolCount furan  •  ${gaarsiinOrders.length} gaarsiin  •  ${completedOrders.length} la dhammeeyay',
                          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(54),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF4F46E5),
                  indicatorWeight: 3,
                  labelColor: const Color(0xFF4F46E5),
                  unselectedLabelColor: const Color(0xFF64748B),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("1. Furan"),
                          if (totalPoolCount > 0) ...[
                            const SizedBox(width: 6),
                            _badge(totalPoolCount.toString(), const Color(0xFFFF6B00)),
                          ]
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("2. Gaarsiin"),
                          if (gaarsiinOrders.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            _badge(gaarsiinOrders.length.toString(), const Color(0xFF4F46E5)),
                          ]
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("3. Dhammay"),
                          if (completedOrders.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            _badge(completedOrders.length.toString(), const Color(0xFF00D285)),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // ── TAB 1: DALABYO FURAN (OPEN POOL) ─────────────────────────────
            RefreshIndicator(
              onRefresh: () => market.refresh(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('📦 Dalabyo Furan (Qaad Adigu)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                  const SizedBox(height: 4),
                  const Text(
                    'Wadaha ugu horreeya ee taaba "Qaado alaabta" ayaa helaya dalabkan.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 14),
                  if (assignedPending.isNotEmpty) ...[
                    const Text('Kuugu magacaabay Admin-ka',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFFF6B00))),
                    const SizedBox(height: 8),
                    ...assignedPending.map(
                      (o) => _deliveryCard(
                        o,
                        market,
                        stepLabel: 'QAADO NOW',
                        stepColor: const Color(0xFFFF6B00),
                        primaryBtn: 'Qaado alaabta → U gudub Gaarsiin',
                        primaryColor: const Color(0xFFFF6B00),
                        isLoading: _busyOrderId == o.id,
                        onPrimary: () => _onPickUp(context, market, o.id, uid),
                        onCancel: () => _onCancelDelivery(context, market, o.id),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (availableOrders.isEmpty && assignedPending.isEmpty)
                    _emptyBox('Hada dalab furan ma jiro. Dalabyada cusub halkan ayay ka soo muuqan doonaan.', Icons.inventory_2_outlined)
                  else
                    ...availableOrders.map(
                      (o) => _deliveryCard(
                        o,
                        market,
                        stepLabel: 'POOL OPEN',
                        stepColor: const Color(0xFF8B5CF6),
                        primaryBtn: 'Qaado alaabta → U gudub Gaarsiin',
                        primaryColor: const Color(0xFF8B5CF6),
                        isLoading: _busyOrderId == o.id,
                        onPrimary: () => _onPickUp(context, market, o.id, uid),
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),

            // ── TAB 2: GAARSIIN (IN TRANSIT) ──────────────────────────────────
            RefreshIndicator(
              onRefresh: () => market.refresh(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('🚚 Gaarsi Macmiilka',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                  const SizedBox(height: 4),
                  const Text(
                    'Dalabyada aad dukaanka ka qaadatay — halkan ka taabo marka macmiilka uu gaaro.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 14),
                  if (gaarsiinOrders.isEmpty)
                    _emptyBox(
                      'Weli ma jirto alaab gaarsiin ah.\nMarkaad tab-ka 1-aad ka taabato "Qaado alaabta", halkan ayay u gudbi doontaa.',
                      Icons.local_shipping_outlined,
                    )
                  else
                    ...gaarsiinOrders.map(
                      (o) => _deliveryCard(
                        o,
                        market,
                        stepLabel: 'IN TRANSIT',
                        stepColor: const Color(0xFF00D285),
                        primaryBtn: 'Taabo: Macmiilka wuu gaaray ✓',
                        primaryColor: const Color(0xFF00D285),
                        isLoading: _busyOrderId == o.id,
                        onPrimary: () => _onDelivered(context, market, o),
                        onCancel: () => _onCancelDelivery(context, market, o.id),
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),

            // ── TAB 3: LA DHAMMEEYAY (COMPLETED HISTORY RICH CARD) ───────────
            RefreshIndicator(
              onRefresh: () => market.refresh(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('✅ Dalabyada la Dhammeeyay',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                  const SizedBox(height: 4),
                  const Text(
                    'Faahfaahinta iibka, alaabta, macmiilka iyo ciwaanka dalabyadii aad gaarsiisay.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 14),
                  if (completedOrders.isEmpty)
                    _emptyBox('Weli ma jirto dalab la dhammeeyay.', Icons.check_circle_outline_rounded)
                  else
                    ...completedOrders.map((o) => _richCompletedCard(o, market)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const ChatScreen(otherUserId: 'admin', otherUserName: 'System Admin'))),
        backgroundColor: const Color(0xFF4F46E5),
        icon: const Icon(Icons.support_agent_rounded, color: Colors.white),
        label: const Text("Admin Support", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _badge(String text, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
      );

  Future<void> _onPickUp(
    BuildContext context,
    MarketplaceProvider market,
    String orderId,
    String deliveryPersonId,
  ) async {
    final gpsOk = await _ensureGpsEnabled(context);
    if (!gpsOk) return;

    setState(() => _busyOrderId = orderId);
    final err = await market.markPickedUp(
      orderId,
      deliveryPersonId: deliveryPersonId,
    );
    if (!mounted) return;
    setState(() => _busyOrderId = null);
    if (!context.mounted) return;
    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alaabta waa la qaaday ✓ — Tab-ka 2-aad (Gaarsiin) u gudub'),
          backgroundColor: Color(0xFF00D285),
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _tabController.animateTo(1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _onDelivered(
    BuildContext context,
    MarketplaceProvider market,
    Order order,
  ) async {
    final confirmed = await _confirmDelivered(context, order);
    if (!confirmed || !mounted) return;

    setState(() => _busyOrderId = order.id);
    final err = await market.markDelivered(order.id);
    if (!mounted) return;
    setState(() => _busyOrderId = null);
    if (!context.mounted) return;

    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dalabka waa la dhammeeyay ✓ — Tab-ka 3-aad ka eeg faahfaahinta'),
          backgroundColor: Color(0xFF00D285),
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _tabController.animateTo(2);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _onCancelDelivery(
    BuildContext context,
    MarketplaceProvider market,
    String orderId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 26),
            SizedBox(width: 8),
            Text('Kansal Gaarsiinta?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Ma ziideysaa in aad kansasho gaarsiinta dalabkan? Dalabku wuxuu dib ugu noqon doonaa list-ga furan si driver kale u qaado.',
          style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Maya', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Haa, Kansal', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _busyOrderId = orderId);
    final err = await market.unassignDeliveryDriver(orderId);
    if (!mounted) return;
    setState(() => _busyOrderId = null);

    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gaarsiinta waa la kansalay, dalabkuna waa la fasaxay.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
      );
    }
  }

  Widget _deliveryCard(
    Order order,
    MarketplaceProvider market, {
    String? stepLabel,
    Color? stepColor,
    required String primaryBtn,
    required Color primaryColor,
    required VoidCallback onPrimary,
    VoidCallback? onCancel,
    bool isLoading = false,
  }) {
    final store = market.getStoreById(order.storeId);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF1F5F9),
                    image: (store?.logo.isNotEmpty ?? false)
                        ? DecorationImage(image: NetworkImage(store!.logo), fit: BoxFit.cover)
                        : null,
                  ),
                  child: (store?.logo.isEmpty ?? true) ? const Icon(Icons.store_rounded, color: Colors.grey) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store?.name ?? 'Dukaan',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1F2937))),
                      Text('\$${order.totalAmount.toStringAsFixed(2)}  •  ${order.items.length} items',
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                if (stepLabel != null && stepColor != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: stepColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: stepColor.withOpacity(0.3)),
                    ),
                    child: Text(stepLabel, style: TextStyle(color: stepColor, fontWeight: FontWeight.w900, fontSize: 10)),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.isPickup ? const Color(0xFFF0FDF4) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: order.isPickup ? const Color(0xFF00D285) : const Color(0xFF2563EB)),
                  ),
                  child: Text(
                    order.isPickup ? '🚶‍♂️ PICKUP' : '🚚 DELIVERY',
                    style: TextStyle(
                      color: order.isPickup ? const Color(0xFF00D285) : const Color(0xFF2563EB),
                      fontWeight: FontWeight.w900,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items List (Grouped by Store)
          Builder(
            builder: (_) {
              final Map<String, List<OrderItem>> groupedByStore = {};
              for (var item in order.items) {
                final sName = (item.storeName.isNotEmpty) ? item.storeName : (store?.name ?? 'Dukaan');
                groupedByStore.putIfAbsent(sName, () => []).add(item);
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.storefront_rounded, size: 15, color: Color(0xFF4F46E5)),
                          const SizedBox(width: 6),
                          Text(
                            'Dukaamada & Alaabaha (${groupedByStore.length} Dukaamood):',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...groupedByStore.entries.map((entry) {
                        final storeName = entry.key;
                        final items = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.store_rounded, size: 14, color: Color(0xFF00D285)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      storeName,
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF1F2937)),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 10, color: Color(0xFFF1F5F9)),
                              ...items.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${item.quantity}x',
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF4F46E5)),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item.productName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                                        ),
                                      ),
                                      Text(
                                        '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),

          // Customer delivery info
          if (order.customerName != null || order.customerPhone != null || (order.customerAddress?.isNotEmpty ?? false))
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF4F46E5)),
                        SizedBox(width: 6),
                        Text('Macmiilka & Meesha',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF3730A3))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (order.customerName != null)
                      Text(order.customerName!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    if (order.customerPhone != null && order.customerPhone!.isNotEmpty)
                      Text(order.customerPhone!, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                    if (order.customerAddress != null && order.customerAddress!.isNotEmpty)
                      Text(order.customerAddress!, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (order.customerPhone != null && order.customerPhone!.isNotEmpty)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _callPhone(order.customerPhone!),
                              icon: const Icon(Icons.phone_rounded, size: 16),
                              label: const Text('Wac Macmiilka', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF4F46E5),
                                side: const BorderSide(color: Color(0xFF818CF8)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        if (order.customerAddress != null && order.customerAddress!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _openMaps(order.customerAddress!),
                              icon: const Icon(Icons.map_rounded, size: 16),
                              label: const Text('Maps Nav', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF4F46E5),
                                side: const BorderSide(color: Color(0xFF818CF8)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (order.status == OrderStatus.outForDelivery) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LiveTrackingView(
                                orderId: order.id,
                                isDriver: true,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.my_location_rounded, size: 18),
                          label: const Text('Live Tracking (Raad-raac)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
            child: Row(
              children: [
                if (onCancel != null) ...[
                  OutlinedButton(
                    onPressed: isLoading ? null : onCancel,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(80, 48),
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Kansal ✕', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onPrimary,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : Text(primaryBtn, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// RICH COMPLETED ORDER CARD — Includes Customer Name, Phone, Address, Items & Store details
  Widget _richCompletedCard(Order order, MarketplaceProvider market) {
    final store = market.getStoreById(order.storeId);
    final dur = order.deliveredAt != null && order.pickedUpAt != null
        ? order.deliveredAt!.difference(order.pickedUpAt!).inMinutes
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Store Name & Delivered Badge
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDF4),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF00D285), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store?.name ?? 'Dukaan',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF065F46))),
                      Text('Order #${order.id.substring(0, 8).toUpperCase()} ${dur != null ? "• Delivered in ${dur}min" : ""}',
                          style: const TextStyle(color: Color(0xFF047857), fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF00D285)),
                ),
              ],
            ),
          ),

          // Customer Info Section (Name, Phone, Address)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.person_rounded, size: 16, color: Color(0xFF4F46E5)),
                      SizedBox(width: 6),
                      Text('Xogta Macmiilka:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.account_circle_outlined, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Text('Magaca: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                      Text(order.customerName ?? "Aan la cayimin",
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1F2937))),
                    ],
                  ),
                  if (order.customerPhone != null && order.customerPhone!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text('Taleefanka: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                        Text(order.customerPhone!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF4F46E5))),
                      ],
                    ),
                  ],
                  if (order.customerAddress != null && order.customerAddress!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text('Ciwaanka: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                        Expanded(
                          child: Text(order.customerAddress!,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF334155))),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Items List Section
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 16, color: Color(0xFFFF6B00)),
                      SizedBox(width: 6),
                      Text('Alaabta la gaarsiisay:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Text('${item.quantity}x', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF00D285))),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(item.productName,
                                maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          ),
                          Text('\$${(item.price * item.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  static Future<void> _openMaps(String address) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _emptyBox(String msg, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(vertical: 36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        child: Center(
          child: Column(
            children: [
              Icon(icon, size: 44, color: const Color(0xFFCBD5E1)),
              const SizedBox(height: 10),
              Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      );
}
