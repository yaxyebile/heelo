import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/order.dart';
import '../../models/app_user.dart';

class AdminOrdersView extends StatefulWidget {
  const AdminOrdersView({super.key});
  @override
  State<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView> {
  OrderStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final market  = Provider.of<MarketplaceProvider>(context);
    var orders    = market.orders;
    if (_filterStatus != null) orders = orders.where((o) => o.status == _filterStatus).toList();
    // Most recent first
    orders = [...orders]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text("Manage Orders", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true, elevation: 0,
      ),
      body: Column(children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(children: [
            _filterChip("All", null),
            _filterChip("Pending",   OrderStatus.pending),
            _filterChip("Paid",      OrderStatus.paymentConfirmed),
            _filterChip("Approved",  OrderStatus.approved),
            _filterChip("Delivering",OrderStatus.outForDelivery),
            _filterChip("Delivered", OrderStatus.delivered),
            _filterChip("Cancelled", OrderStatus.cancelled),
          ]),
        ),
        Expanded(
          child: orders.isEmpty
            ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.inbox_rounded, size: 60, color: Color(0xFFCBD5E1)),
                SizedBox(height: 12),
                Text("No orders found", style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                itemCount: orders.length,
                itemBuilder: (_, i) => _orderCard(context, market, orders[i]),
              ),
        ),
      ]),
    );
  }

  Widget _filterChip(String label, OrderStatus? status) {
    final bool selected = _filterStatus == status;
    Color c = _statusColor(status);
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? c : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? c : const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Text(label, style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF64748B),
          fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }

  Widget _orderCard(BuildContext context, MarketplaceProvider market, Order order) {
    final store         = market.getStoreById(order.storeId);
    final drivers       = market.getDeliveryPersons();
    final statusColor   = _statusColor(order.status);
    final statusLabel   = _statusLabel(order.status);
    final statusBg      = statusColor.withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Order #${order.id.substring(0, 8).toUpperCase()}",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A))),
              const SizedBox(height: 2),
              Text("${store?.name ?? 'Store'}  •  ${order.items.length} items",
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
              child: Text(statusLabel,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
            ),
          ]),
        ),
        Divider(height: 1, color: Colors.grey.shade100),

        // Items — dukaan walba alaabtiisa
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Alaabta dukaankan:',
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
                              color: Color(0xFFFF6B00))),
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

        // Detail row
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          child: Row(children: [
            _detailChip(Icons.account_balance_wallet_rounded,
              order.paymentMethod == PaymentMethod.evcPlus ? "EVC Plus" : "eDahab",
              const Color(0xFFFF6B00)),
            const SizedBox(width: 12),
            _detailChip(Icons.attach_money_rounded,
              "\$${order.totalAmount.toStringAsFixed(2)}", const Color(0xFF00D285)),
            const Spacer(),
            Text(_formatDate(order.date),
              style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
        ),

        // Customer Info Row
        if (order.customerName != null || order.customerPhone != null || order.customerAddress != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.person_pin_circle_rounded, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Text(order.customerName ?? "Unknown Customer",
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF334155))),
                    if (order.customerPhone != null && order.customerPhone!.isNotEmpty)
                      Expanded(
                        child: Text("  •  ${order.customerPhone}",
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF0F172A)),
                          overflow: TextOverflow.ellipsis),
                      ),
                  ]),
                  if (order.customerAddress != null && order.customerAddress!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.location_city_rounded, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(order.customerAddress!,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
                    ]),
                  ]
                ],
              ),
            ),
          ),

        // Action buttons based on status
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          child: _actionRow(context, market, order, drivers),
        ),
      ]),
    );
  }

  Widget _actionRow(BuildContext context, MarketplaceProvider market, Order order, List<AppUser> drivers) {
    switch (order.status) {
      case OrderStatus.pending:
        return Row(children: [
          Expanded(child: _btn("Confirm Payment ✓", const Color(0xFF00D285),
            () => market.confirmPayment(order.id))),
          const SizedBox(width: 10),
          _iconBtn(Icons.cancel_outlined, const Color(0xFFEF4444),
            () => market.cancelOrder(order.id)),
        ]);

      case OrderStatus.paymentConfirmed:
        return _approveWithDriverPicker(context, market, order, drivers);

      case OrderStatus.approved:
      case OrderStatus.outForDelivery:
        return Row(children: [
          Expanded(child: _btn(
            order.status == OrderStatus.approved ? "Awaiting pickup..." : "Out for delivery...",
            const Color(0xFF8B5CF6), null, disabled: true)),
        ]);

      case OrderStatus.delivered:
        final dur = order.deliveredAt != null && order.pickedUpAt != null
          ? order.deliveredAt!.difference(order.pickedUpAt!).inMinutes
          : null;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF00D285), size: 18),
            const SizedBox(width: 8),
            Text("Delivered${dur != null ? " in ${dur}min" : ""}",
              style: const TextStyle(color: Color(0xFF00D285), fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        );

      case OrderStatus.cancelled:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(12)),
          child: const Row(children: [
            Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 18),
            SizedBox(width: 8),
            Text("Cancelled", style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
          ]),
        );
    }
  }

  Widget _approveWithDriverPicker(BuildContext context, MarketplaceProvider market, Order order, List<AppUser> drivers) {
    if (drivers.isEmpty) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(
          'Dalabkan waa dukaan gooni ah. Ku dar delivery driver marka hore.',
          style: TextStyle(fontSize: 12, color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        _btn('Aqbal (driver la\'aan) →', const Color(0xFFFF6B00),
            () => market.approveOrder(order.id)),
      ]);
    }

    return _ApproveWithDriverForm(
      drivers: drivers,
      onApprove: (driverId) =>
          market.approveOrder(order.id, deliveryPersonId: driverId),
    );
  }

  Widget _btn(String label, Color color, VoidCallback? onTap, {bool disabled = false}) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: disabled ? Colors.grey.shade100 : color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: disabled ? Colors.grey.shade200 : color.withOpacity(0.3)),
        ),
        child: Center(child: Text(label, style: TextStyle(
          color: disabled ? Colors.grey : color,
          fontWeight: FontWeight.w800, fontSize: 13))),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _detailChip(IconData icon, String label, Color color) => Row(children: [
    Icon(icon, size: 14, color: color),
    const SizedBox(width: 4),
    Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
  ]);

  Color _statusColor(OrderStatus? s) {
    switch (s) {
      case OrderStatus.pending:          return const Color(0xFFFFB800);
      case OrderStatus.paymentConfirmed: return const Color(0xFF3B82F6);
      case OrderStatus.approved:         return const Color(0xFFFF6B00);
      case OrderStatus.outForDelivery:   return const Color(0xFF8B5CF6);
      case OrderStatus.delivered:        return const Color(0xFF00D285);
      case OrderStatus.cancelled:        return const Color(0xFFEF4444);
      default:                           return const Color(0xFF94A3B8);
    }
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:          return "PENDING";
      case OrderStatus.paymentConfirmed: return "PAID";
      case OrderStatus.approved:         return "APPROVED";
      case OrderStatus.outForDelivery:   return "DELIVERING";
      case OrderStatus.delivered:        return "DELIVERED";
      case OrderStatus.cancelled:        return "CANCELLED";
    }
  }

  String _formatDate(DateTime d) {
    return "${d.day}/${d.month}/${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  }
}

/// Admin must pick a driver, then approve — one order per store.
class _ApproveWithDriverForm extends StatefulWidget {
  final List<AppUser> drivers;
  final void Function(String driverId) onApprove;

  const _ApproveWithDriverForm({
    required this.drivers,
    required this.onApprove,
  });

  @override
  State<_ApproveWithDriverForm> createState() => _ApproveWithDriverFormState();
}

class _ApproveWithDriverFormState extends State<_ApproveWithDriverForm> {
  String? _selectedDriverId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dooro delivery, kadib aqbal dalabkan dukaanka',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedDriverId,
              isExpanded: true,
              hint: const Text('Dooro driver',
                  style: TextStyle(fontSize: 13, color: Color(0xFFCBD5E1))),
              items: widget.drivers
                  .map((d) => DropdownMenuItem<String>(
                        value: d.id,
                        child: Text(d.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13)),
                      ))
                  .toList(),
              onChanged: (id) => setState(() => _selectedDriverId = id),
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _selectedDriverId == null
              ? null
              : () => widget.onApprove(_selectedDriverId!),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: _selectedDriverId == null
                  ? Colors.grey.shade100
                  : const Color(0xFFFF6B00).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedDriverId == null
                    ? Colors.grey.shade200
                    : const Color(0xFFFF6B00).withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Text(
                'Aqbal & u dir delivery →',
                style: TextStyle(
                  color: _selectedDriverId == null
                      ? Colors.grey
                      : const Color(0xFFFF6B00),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
