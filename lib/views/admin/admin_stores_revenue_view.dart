import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';

class AdminStoresRevenueView extends StatelessWidget {
  const AdminStoresRevenueView({super.key});

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final stores = market.stores;

    // Sort by revenue desc
    final sorted = [...stores]..sort((a, b) =>
        market.revenueForStore(b.id).compareTo(market.revenueForStore(a.id)));

    final grossTotal = sorted.fold(0.0, (s, st) => s + market.grossRevenueForStore(st.id));
    final sellerTotal = sorted.fold(0.0, (s, st) => s + market.revenueForStore(st.id));
    final adminFeeTotal = sorted.fold(0.0, (s, st) => s + market.adminCommissionForStore(st.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
        title: const Text("Store Revenue & 7% Fee", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true, elevation: 0,
      ),
      body: Column(
        children: [
          // Total Revenue Banner
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B00).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFFF6B00), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text("Admin 7% Commission",
                        style: TextStyle(color: Color(0xFFFF9E43), fontSize: 13, fontWeight: FontWeight.w700)),
                      Text("\$${adminFeeTotal.toStringAsFixed(2)}",
                        style: const TextStyle(color: Color(0xFF00D285), fontSize: 28, fontWeight: FontWeight.w900)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 16),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text("Seller Net Payout (Base)", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text("\$${sellerTotal.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                    ]),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      const Text("Gross Customer Total", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text("\$${grossTotal.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                    ]),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: stores.isEmpty
              ? const Center(child: Text("No stores yet"))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: sorted.length,
                  itemBuilder: (_, i) {
                    final store      = sorted[i];
                    final netRevenue = market.revenueForStore(store.id);
                    final adminFee   = market.adminCommissionForStore(store.id);
                    final orders     = market.getOrdersByStore(store.id);
                    final paidCount  = orders.where((o) => o.isPaid).length;
                    final pct        = sellerTotal > 0 ? netRevenue / sellerTotal : 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(22),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
                          blurRadius: 14, offset: const Offset(0, 5))],
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(width: 48, height: 48,
                            decoration: BoxDecoration(shape: BoxShape.circle,
                              color: const Color(0xFFF1F5F9),
                              image: store.logo.isNotEmpty
                                ? DecorationImage(image: NetworkImage(store.logo), fit: BoxFit.cover)
                                : null),
                            child: store.logo.isEmpty
                              ? const Icon(Icons.store_rounded, color: Colors.grey) : null),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(store.name,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1F2937))),
                            Text("${orders.length} orders  •  $paidCount paid",
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                          ])),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text("\$${netRevenue.toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFFFF6B00))),
                            Text("Admin 7%: +\$${adminFee.toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF00D285))),
                          ]),
                        ]),
                        const SizedBox(height: 14),
                        // Progress bar
                        Stack(children: [
                          Container(height: 6,
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(3))),
                          FractionallySizedBox(
                            widthFactor: pct.clamp(0.0, 1.0),
                            child: Container(height: 6,
                              decoration: BoxDecoration(
                                color: i == 0 ? const Color(0xFFFFB800) : const Color(0xFFFF6B00),
                                borderRadius: BorderRadius.circular(3))),
                          ),
                        ]),
                        const SizedBox(height: 6),
                        Text("${(pct * 100).toStringAsFixed(1)}% of seller net revenue",
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600)),

                        // Payment numbers
                        if (store.evcNumber != null || store.edahabNumber != null) ...[
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey.shade100),
                          const SizedBox(height: 8),
                          Row(children: [
                            if (store.evcNumber != null)
                              _payNum("EVC", store.evcNumber!, const Color(0xFFFF6B00)),
                            if (store.evcNumber != null && store.edahabNumber != null)
                              const SizedBox(width: 12),
                            if (store.edahabNumber != null)
                              _payNum("eDahab", store.edahabNumber!, const Color(0xFF00D285)),
                          ]),
                        ],
                      ]),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _payNum(String label, String num, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
    child: Text("$label: $num",
      style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11)),
  );
}
