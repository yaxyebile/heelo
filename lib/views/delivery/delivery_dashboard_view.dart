import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/order.dart';
import '../chat/chat_screen.dart';

class DeliveryDashboardView extends StatefulWidget {
  const DeliveryDashboardView({super.key});

  @override
  State<DeliveryDashboardView> createState() => _DeliveryDashboardViewState();
}

class _DeliveryDashboardViewState extends State<DeliveryDashboardView> {
  final _scrollController = ScrollController();
  final _gaarsiinSectionKey = GlobalKey();
  final _completedSectionKey = GlobalKey();
  String? _busyOrderId;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollTo(GlobalKey key) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    final ctx = key.currentContext;
    if (ctx != null) {
      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    }
  }

  Future<void> _scrollToGaarsiin() => _scrollTo(_gaarsiinSectionKey);

  Future<void> _scrollToCompleted() => _scrollTo(_completedSectionKey);

  Future<bool> _confirmDelivered(BuildContext context, Order order) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: Color(0xFF00D285), size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text('Macmiilka ma gaaray?',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ),
          ],
        ),
        content: Text(
          '${order.customerName ?? "Macmiilka"} — alaabtu ma gaartay?\n\n'
          'Taabo "Haa, waa gaartay" marka aad dhab ahaan u gaarsiisid.\n'
          'Kadib dalabku wuxuu u gudbi doonaa "La dhammeeyay".',
          style: const TextStyle(height: 1.45, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Maya', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D285),
              foregroundColor: Colors.white,
            ),
            child: const Text('Haa, waa gaartay ✓',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final auth   = Provider.of<AuthProvider>(context);
    final market = context.watch<MarketplaceProvider>();
    final uid    = auth.currentUser!.id;

    final assignedPending = market.getAssignedDeliveries(uid)
      ..sort((a, b) => b.date.compareTo(a.date));
    final availableOrders = market.getUnassignedApprovedOrders()
      ..sort((a, b) => b.date.compareTo(a.date));
    final myOrders = market.getOrdersByDelivery(uid)
      ..sort((a, b) => b.date.compareTo(a.date));
    final gaarsiinOrders = myOrders
        .where((o) => o.status == OrderStatus.outForDelivery)
        .toList();
    final completed = myOrders
        .where((o) => o.status == OrderStatus.delivered)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            backgroundColor: const Color(0xFF8B5CF6),
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  child: IconButton(
                    icon: const Icon(Icons.logout_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => auth.logout(),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.delivery_dining_rounded,
                                  color: Colors.white, size: 14),
                              SizedBox(width: 6),
                              Text('DELIVERY DRIVER',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('Ahlan, ${auth.currentUser?.name}!',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(
                          '${assignedPending.length} qaado  •  ${gaarsiinOrders.length} gaarsiin  •  ${completed.length} dhammay',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _stat(
                              '${assignedPending.length}',
                              'Kuugu magacaabay',
                              Icons.assignment_ind_rounded,
                              const Color(0xFFFF6B00),
                              const Color(0xFFFFF3E0))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _stat(
                              '${gaarsiinOrders.length}',
                              'Gaarsiin',
                              Icons.delivery_dining_rounded,
                              const Color(0xFF8B5CF6),
                              const Color(0xFFF5F3FF))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _stat(
                              '${completed.length}',
                              'Dhammay',
                              Icons.check_circle_rounded,
                              const Color(0xFF00D285),
                              const Color(0xFFF0FDF4))),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Tallaabada 2: Gaarsi macmiilka (ka dib marka la qaado)
                  KeyedSubtree(
                    key: _gaarsiinSectionKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🚚 Tallaabada 2: Gaarsi macmiilka',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 6),
                        const Text(
                          'Dalabyada aad dukaanka ka qaadatay — halkan ku gaarsi',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 12),
                        if (gaarsiinOrders.isEmpty)
                          _emptyBox(
                            'Weli ma jirto alaab gaarsiin ah.\nMarkaad taabato "Qaado alaabta", halkan ayay u gudbi doontaa.',
                            Icons.local_shipping_outlined,
                          )
                        else
                          ...gaarsiinOrders.map(
                            (o) => _deliveryCard(
                              o,
                              market,
                              stepLabel: 'GAARSIIN',
                              stepColor: const Color(0xFF8B5CF6),
                              primaryBtn: 'Taabo: Macmiilka wuu gaaray ✓',
                              primaryColor: const Color(0xFF00D285),
                              isLoading: _busyOrderId == o.id,
                              onPrimary: () =>
                                  _onDelivered(context, market, o),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Tallaabada 1: Qaado dukaanka
                  const Text('📋 Tallaabada 1: Qaado dukaanka',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  const Text(
                    'Taabo "Qaado alaabta" — kadib waxay u gudbi doontaa Gaarsiin',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 12),
                  if (assignedPending.isNotEmpty) ...[
                    const Text('Kuugu magacaabay (admin)',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF6B00))),
                    const SizedBox(height: 8),
                    ...assignedPending.map(
                      (o) => _deliveryCard(
                        o,
                        market,
                        stepLabel: 'QAADO',
                        stepColor: const Color(0xFFFF6B00),
                        primaryBtn: 'Qaado alaabta → U gudub Gaarsiin',
                        primaryColor: const Color(0xFFFF6B00),
                        isLoading: _busyOrderId == o.id,
                        onPrimary: () => _onPickUp(context, market, o.id, uid),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (assignedPending.isEmpty &&
                      availableOrders.isEmpty)
                    _emptyBox('Dalab qaado ah ma jiro',
                        Icons.inventory_2_outlined),

                  const SizedBox(height: 12),
                  const Text('📦 Dalabyo furan (qaad adigu)',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 12),
                  availableOrders.isEmpty
                      ? _emptyBox('Dalab furan ma jiro',
                          Icons.check_circle_outline_rounded)
                      : Column(
                          children: availableOrders
                              .map(
                                (o) => _deliveryCard(
                                  o,
                                  market,
                                  stepLabel: 'QAADO',
                                  stepColor: const Color(0xFF8B5CF6),
                                  primaryBtn: 'Qaado alaabta → U gudub Gaarsiin',
                                  primaryColor: const Color(0xFF8B5CF6),
                                  isLoading: _busyOrderId == o.id,
                                  onPrimary: () =>
                                      _onPickUp(context, market, o.id, uid),
                                ),
                              )
                              .toList(),
                        ),

                  const SizedBox(height: 28),
                  KeyedSubtree(
                    key: _completedSectionKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✅ Tallaabada 3: La dhammeeyay',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 6),
                        const Text(
                          'Dalabyada aad gaarsiisay — halkan ayay ku dhamaadaan',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 12),
                        if (completed.isEmpty)
                          _emptyBox(
                            'Weli ma jirto dalab la dhammeeyay.\nMarkaad taabato "Macmiilka wuu gaaray", halkan ayuu u gudbi doonaa.',
                            Icons.check_circle_outline_rounded,
                          )
                        else
                          ...completed.take(10).map((o) => _completedTile(o)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const ChatScreen(
                    otherUserId: 'admin',
                    otherUserName: 'System Admin'))),
        backgroundColor: const Color(0xFF8B5CF6),
        child: const Icon(Icons.support_agent_rounded, color: Colors.white),
      ),
    );
  }

  Future<void> _onPickUp(
    BuildContext context,
    MarketplaceProvider market,
    String orderId,
    String deliveryPersonId,
  ) async {
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
          content: Text(
            'Alaabta waa la qaaday ✓ — Hoos u eeg "Gaarsi macmiilka"',
          ),
          backgroundColor: Color(0xFF00D285),
          duration: Duration(seconds: 4),
        ),
      );
      await _scrollToGaarsiin();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.redAccent),
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
          content: Text(
            'Dalabka waa la dhammeeyay ✓ — Hoos u eeg "La dhammeeyay"',
          ),
          backgroundColor: Color(0xFF00D285),
          duration: Duration(seconds: 4),
        ),
      );
      await _scrollToCompleted();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.redAccent),
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
    bool isLoading = false,
  }) {
    final store = market.getStoreById(order.storeId);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF1F5F9),
                    image: (store?.logo.isNotEmpty ?? false)
                        ? DecorationImage(
                            image: NetworkImage(store!.logo),
                            fit: BoxFit.cover)
                        : null,
                  ),
                  child: (store?.logo.isEmpty ?? true)
                      ? const Icon(Icons.store_rounded, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store?.name ?? 'Dukaan',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Color(0xFF0F172A))),
                      Text(
                          '\$${order.totalAmount.toStringAsFixed(2)}  •  ${order.items.length} alaab',
                          style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                if (stepLabel != null && stepColor != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: stepColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: stepColor.withValues(alpha: 0.35)),
                    ),
                    child: Text(stepLabel,
                        style: TextStyle(
                            color: stepColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 10)),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.paymentMethod == PaymentMethod.evcPlus
                        ? const Color(0xFFFFF3E0)
                        : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.paymentMethod == PaymentMethod.evcPlus
                        ? 'EVC'
                        : 'eDahab',
                    style: TextStyle(
                      color: order.paymentMethod == PaymentMethod.evcPlus
                          ? const Color(0xFFFF6B00)
                          : const Color(0xFF00D285),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Waxa la qaadayaa — items list
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Waxaad qaadaysaa:',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Text('${item.quantity}x',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  color: Color(0xFF8B5CF6))),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(item.productName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF334155))),
                          ),
                          Text(
                              '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Customer delivery address
          if (order.customerName != null ||
              order.customerPhone != null ||
              (order.customerAddress != null &&
                  order.customerAddress!.isNotEmpty))
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDDD6FE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 16, color: Color(0xFF8B5CF6)),
                        SizedBox(width: 6),
                        Text('Macmiilka',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF6D28D9))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (order.customerName != null)
                      Text(order.customerName!,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                    if (order.customerPhone != null &&
                        order.customerPhone!.isNotEmpty)
                      Text(order.customerPhone!,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF475569))),
                    if (order.customerAddress != null &&
                        order.customerAddress!.isNotEmpty)
                      Text(order.customerAddress!,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF475569))),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (order.customerPhone != null &&
                            order.customerPhone!.isNotEmpty)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _callPhone(order.customerPhone!),
                              icon: const Icon(Icons.phone_rounded, size: 18),
                              label: const Text('Wac',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        if (order.customerAddress != null &&
                            order.customerAddress!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _openMaps(order.customerAddress!),
                              icon: const Icon(Icons.map_rounded, size: 18),
                              label: const Text('Khariidad',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: isLoading ? null : onPrimary,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: primaryColor.withValues(alpha: 0.12),
                  foregroundColor: primaryColor,
                  disabledBackgroundColor:
                      primaryColor.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                        color: primaryColor.withValues(alpha: 0.3)),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: primaryColor,
                        ),
                      )
                    : Text(primaryBtn,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _completedTile(Order order) {
    final dur = order.deliveredAt != null && order.pickedUpAt != null
        ? order.deliveredAt!.difference(order.pickedUpAt!).inMinutes
        : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)
          ]),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.check_rounded,
                color: Color(0xFF00D285), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#${order.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 13)),
                Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}${dur != null ? '  •  ${dur}min' : ''}',
                    style: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF00D285), size: 20),
        ],
      ),
    );
  }

  Widget _stat(String v, String l, IconData icon, Color color, Color bg) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)
            ]),
        child: Column(
          children: [
            Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20)),
            const SizedBox(height: 8),
            Text(v,
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 2),
            Text(l,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 9,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );

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
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
            ]),
        child: Center(
          child: Column(
            children: [
              Icon(icon, size: 40, color: const Color(0xFFCBD5E1)),
              const SizedBox(height: 8),
              Text(msg,
                  style: const TextStyle(
                      color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}
