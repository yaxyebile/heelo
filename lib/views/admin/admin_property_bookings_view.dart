import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/property_booking.dart';
import '../../models/order.dart'; // For PaymentMethod

class AdminPropertyBookingsView extends StatefulWidget {
  const AdminPropertyBookingsView({super.key});

  @override
  State<AdminPropertyBookingsView> createState() => _AdminPropertyBookingsViewState();
}

class _AdminPropertyBookingsViewState extends State<AdminPropertyBookingsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _approveBooking(BuildContext context, MarketplaceProvider market, PropertyBooking booking) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ansixi Carbun', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Ma xaqiijisay in xawilaad dhan ${booking.currency} ${booking.depositAmount.toStringAsFixed(0)} EVC/eDahab oo ka timid "${booking.transactionPhone}" ay ku soo gaartay?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Maya')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00AA5B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Haa, Ansixi'),
          ),
        ],
      ),
    );

    if (ok == true) {
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      try {
        await market.approvePropertyBooking(booking.id);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Carbuntia "${booking.propertyTitle}" waa la ansixiyay!'),
            backgroundColor: const Color(0xFF00AA5B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (context.mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text('Khalad: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _rejectBooking(BuildContext context, MarketplaceProvider market, PropertyBooking booking) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Diid Carbun', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text('Ma hubtaa inaad diidayso oo aad burinayso codsiga carbun ee "${booking.propertyTitle}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Maya')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Diid/Buri'),
          ),
        ],
      ),
    );

    if (ok == true) {
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      try {
        await market.cancelPropertyBooking(booking.id);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Carbuntia waa la diiday/buriyay!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (context.mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text('Khalad: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final bookings = market.propertyBookings;

    final pending = bookings.where((b) => b.status == BookingStatus.pending).toList();
    final resolved = bookings.where((b) => b.status != BookingStatus.pending).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1F2937)),
          ),
        ),
        title: const Text(
          'Maamulka Carbunta (Bookings)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFFFF6B00),
          labelColor: const Color(0xFFFF6B00),
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(text: 'Sugaya Ansixin (${pending.length})'),
            Tab(text: 'La Xalliyay (${resolved.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildList(context, pending, market),
          _buildList(context, resolved, market),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<PropertyBooking> list, MarketplaceProvider market) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3E0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.book_online_rounded, color: Color(0xFFFF6B00), size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Wax codsi carbun ah ma jiraan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final b = list[i];
        final isPending = b.status == BookingStatus.pending;
        final isEvc = b.paymentMethod == PaymentMethod.evcPlus;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        b.propertyTitle,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1F2937)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: b.status == BookingStatus.approved
                            ? const Color(0xFFE8F5E9)
                            : b.status == BookingStatus.cancelled
                                ? const Color(0xFFFFEBEE)
                                : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        b.statusLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: b.status == BookingStatus.approved
                              ? const Color(0xFF2E7D32)
                              : b.status == BookingStatus.cancelled
                                  ? Colors.red
                                  : const Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Content Details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    _rowDetail('Macamiilka (Buyer):', '${b.userName} (${b.userPhone})'),
                    const SizedBox(height: 6),
                    _rowDetail('Nooca Hantida:', b.propertyTypeLabel),
                    const SizedBox(height: 6),
                    _rowDetail('Habka Xayeysiis:', b.listingTypeLabel),
                    const SizedBox(height: 6),
                    _rowDetail('Qiimaha Hantida:', '${b.currency} ${b.totalPrice.toStringAsFixed(0)}'),
                    const SizedBox(height: 8),
                    
                    // Deposit highlighting
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Lacagta Carbunta (20%):',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFFF6B00)),
                          ),
                          Text(
                            '${b.currency} ${b.depositAmount.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFFFF6B00)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Payment details
                    Row(
                      children: [
                        Icon(
                          isEvc ? Icons.account_balance_wallet_rounded : Icons.offline_bolt_rounded,
                          size: 16,
                          color: isEvc ? const Color(0xFFFF6B00) : const Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Payment: ${b.paymentMethod.name.toUpperCase()} (${b.transactionPhone})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isEvc ? const Color(0xFFB34700) : const Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons for Pending
              if (isPending) ...[
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _rejectBooking(context, market, b),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Diid / Ka Jooji', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _approveBooking(context, market, b),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00AA5B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: const Text('Ansixi Lacabta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _rowDetail(String label, String val) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            val,
            style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.bold),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
