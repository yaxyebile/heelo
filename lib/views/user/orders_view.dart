import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../models/property_booking.dart';
import '../delivery/live_tracking_view.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final auth   = Provider.of<AuthProvider>(context);

    if (!auth.isAuthenticated) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: Text("Please login to view your orders",
          style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w700))),
      );
    }

    final myOrders = market.getOrdersByUser(auth.currentUser!.id)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    final myBookings = market.propertyBookings
        .where((b) => b.userId == auth.currentUser!.id)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text("My Orders & Bookings",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF1F2937))),
          bottom: const TabBar(
            indicatorColor: Color(0xFF2563EB),
            labelColor: Color(0xFF2563EB),
            unselectedLabelColor: Color(0xFF64748B),
            labelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: [
              Tab(text: "Dalabyada"),
              Tab(text: "Carbunta"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ── Tab 1: Orders ───────────────────────────────────────────
            RefreshIndicator(
              onRefresh: () => market.refresh(),
              child: myOrders.isEmpty
                ? _empty("No orders yet", "Your orders will appear here", Icons.receipt_long_outlined)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: myOrders.length,
                    itemBuilder: (_, i) => _orderCard(context, market, auth, myOrders[i]),
                  ),
            ),
            // ── Tab 2: Property Bookings ────────────────────────────────
            RefreshIndicator(
              onRefresh: () => market.refresh(),
              child: myBookings.isEmpty
                ? _empty("Wax carbun ah ma jiraan", "Halkan ayaa lagu soo bandhigayaa guryaha aad carbunto", Icons.bookmark_border_rounded)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: myBookings.length,
                    itemBuilder: (_, i) => _bookingCard(myBookings[i]),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(String title, String subtitle, IconData icon) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 100, height: 100,
      decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
      child: Icon(icon, size: 48, color: const Color(0xFFCBD5E1))),
    const SizedBox(height: 20),
    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF94A3B8))),
    const SizedBox(height: 8),
    Text(subtitle, style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14)),
  ]));

  Widget _bookingCard(PropertyBooking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Carbun #${booking.id.substring(0, 8).toUpperCase()}",
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1F2937))),
                const SizedBox(height: 3),
                Text(_formatDate(booking.createdAt),
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _bookingStatusColor(booking.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
                child: Text(_bookingStatusLabel(booking.status).toUpperCase(),
                  style: TextStyle(color: _bookingStatusColor(booking.status),
                    fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
              ),
            ]),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.propertyTitle,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1F2937))),
                const SizedBox(height: 4),
                Text("${booking.listingType == 'sale' ? 'Guri Iib Ah' : 'Guri Kiro Ah'} • ${booking.propertyType}",
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // Footer
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0), // Orange tint for properties
              borderRadius: BorderRadius.circular(14)
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text("Lacagta Carbunta (20%)", style: TextStyle(fontSize: 10, color: Color(0xFFB45309), fontWeight: FontWeight.bold)),
                   Text(booking.paymentMethod == 'evc' ? "EVC Plus" : "eDahab",
                      style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFE65100), fontSize: 12)),
                ],
              ),
              Text("\$${booking.depositAmount.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFFFF6B00))),
            ]),
          ),
        ],
      ),
    );
  }

  Color _bookingStatusColor(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:   return const Color(0xFFFFB800);
      case BookingStatus.approved:  return const Color(0xFF00AA5B);
      case BookingStatus.cancelled: return const Color(0xFFEF4444);
    }
  }

  String _bookingStatusLabel(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:   return "Sugeysa";
      case BookingStatus.approved:  return "La Ansixiyay";
      case BookingStatus.cancelled: return "La Diiday";
    }
  }

  Widget _orderCard(
      BuildContext context, MarketplaceProvider market, AuthProvider auth, Order order) {
    final store = market.getStoreById(order.storeId);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Order #${order.id.substring(0, 8).toUpperCase()}",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1F2937))),
              const SizedBox(height: 3),
              Text(_formatDate(order.date),
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
              child: Text(_statusLabel(order.status).toUpperCase(),
                style: TextStyle(color: _statusColor(order.status),
                  fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
            ),
          ]),
        ),

        // ── Order Timeline ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: _timeline(order),
        ),

        // ── Items ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(children: order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Container(width: 28, height: 28,
                decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text("${item.quantity}x",
                  style: const TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.w900, fontSize: 11)))),
              const SizedBox(width: 12),
              Expanded(child: Text(item.productName, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF374151)))),
              Text("\$${(item.price * item.quantity).toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1F2937))),
            ]),
          )).toList()),
        ),

        // ── Footer ────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Icon(
                order.paymentMethod == PaymentMethod.evcPlus
                  ? Icons.account_balance_wallet_rounded : Icons.payments_rounded,
                size: 16,
                color: order.paymentMethod == PaymentMethod.evcPlus
                  ? const Color(0xFFFF6B00) : const Color(0xFF00D285)),
              const SizedBox(width: 6),
              Text(
                order.paymentMethod == PaymentMethod.evcPlus ? "EVC Plus" : "eDahab",
                style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B), fontSize: 13)),
            ]),
            Text("\$${order.totalAmount.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF00AA5B))),
          ]),
        ),
        if (order.status == OrderStatus.outForDelivery)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LiveTrackingView(
                      orderId: order.id,
                      isDriver: false,
                    ),
                  ),
                ),
                icon: const Icon(Icons.location_on_rounded, size: 18),
                label: const Text('Live Tracking (Raad-raac)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        if (order.status == OrderStatus.delivered && order.items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showReviewDialog(context, market, auth, order.items.first),
                icon: const Icon(Icons.star_rounded),
                label: const Text('Qiimee alaabta'),
              ),
            ),
          ),
      ]),
    );
  }

  void _showReviewDialog(
    BuildContext context,
    MarketplaceProvider market,
    AuthProvider auth,
    OrderItem item,
  ) {
    var rating = 5;
    final commentCtrl = TextEditingController();
  showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Qiimee alaabta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return IconButton(
                    onPressed: () => setS(() => rating = i + 1),
                    icon: Icon(
                      i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: const Color(0xFFFFB800),
                    ),
                  );
                }),
              ),
              TextField(
                controller: commentCtrl,
                decoration: const InputDecoration(hintText: 'Comment (optional)'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (auth.currentUser == null) return;
                await market.submitReview(
                  productId: item.productId,
                  userId: auth.currentUser!.id,
                  rating: rating,
                  comment: commentCtrl.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  // 5-step visual progress
  Widget _timeline(Order order) {
    final steps = [
      (OrderStatus.pending,          "Order Placed",     Icons.shopping_bag_outlined),
      (OrderStatus.paymentConfirmed, "Payment Verified", Icons.check_circle_outlined),
      (OrderStatus.approved,         "Approved",         Icons.thumb_up_outlined),
      (OrderStatus.outForDelivery,   "Out for Delivery", Icons.delivery_dining_rounded),
      (OrderStatus.delivered,        "Delivered",        Icons.home_rounded),
    ];

    if (order.status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(12)),
        child: const Row(children: [
          Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 18),
          SizedBox(width: 8),
          Text("Order Cancelled", style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
        ]),
      );
    }

    final currentIdx = steps.indexWhere((s) => s.$1 == order.status);

    return Column(children: [
      Row(children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // connector line
          final stepIdx = i ~/ 2;
          final done = stepIdx < currentIdx;
          return Expanded(child: Container(height: 2,
            color: done ? const Color(0xFF00D285) : const Color(0xFFE2E8F0)));
        }
        final stepIdx = i ~/ 2;
        final done    = stepIdx <= currentIdx;
        final current = stepIdx == currentIdx;
        final color   = done ? const Color(0xFF00D285) : const Color(0xFFCBD5E1);
        return Container(width: 28, height: 28,
          decoration: BoxDecoration(
            color: done ? color : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: current ? 2.5 : 1.5),
          ),
          child: Icon(steps[stepIdx].$3, size: 14,
            color: done ? Colors.white : const Color(0xFFCBD5E1)));
      })),
      const SizedBox(height: 6),
      // Label for current step
      Align(
        alignment: Alignment.centerLeft,
        child: Text(currentIdx >= 0 ? steps[currentIdx].$2 : "",
          style: const TextStyle(color: Color(0xFF00D285), fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    ]);
  }

  String _formatDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return "${d.day} ${m[d.month - 1]} ${d.year}  ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}";
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:          return const Color(0xFFFFB800);
      case OrderStatus.paymentConfirmed: return const Color(0xFF3B82F6);
      case OrderStatus.approved:         return const Color(0xFFFF6B00);
      case OrderStatus.outForDelivery:   return const Color(0xFF8B5CF6);
      case OrderStatus.delivered:        return const Color(0xFF00D285);
      case OrderStatus.cancelled:        return const Color(0xFFEF4444);
    }
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:          return "Pending";
      case OrderStatus.paymentConfirmed: return "Payment Confirmed";
      case OrderStatus.approved:         return "Approved";
      case OrderStatus.outForDelivery:   return "Out for Delivery";
      case OrderStatus.delivered:        return "Delivered";
      case OrderStatus.cancelled:        return "Cancelled";
    }
  }
}
