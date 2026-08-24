import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/theme/app_theme.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});
  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  PaymentMethod _method = PaymentMethod.evcPlus;
  bool _processing = false;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _couponCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        _nameCtrl.text = auth.currentUser!.name;
        _phoneCtrl.text = auth.currentUser!.phone ?? "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final auth   = Provider.of<AuthProvider>(context);
    final cart   = market.cart;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Checkout", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF1F2937))),
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Delivery Information ───────────────────────────────────
              const Text("Delivery Information",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.darkBlue)),
              const SizedBox(height: 12),
              CustomTextField(
                label: "Full Name",
                hint: "E.g. Ahmed Ali",
                prefixIcon: Icons.person_outline_rounded,
                controller: _nameCtrl,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Phone Number",
                hint: "E.g. 61XXXXXXX",
                prefixIcon: Icons.phone_android_rounded,
                controller: _phoneCtrl,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Delivery Address",
                hint: "E.g. Hodan, Mogadishu",
                prefixIcon: Icons.location_on_outlined,
                controller: _addressCtrl,
              ),
              const SizedBox(height: 28),

              const Text('Coupon code',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.darkBlue)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _couponCtrl,
                    decoration: const InputDecoration(hintText: 'e.g. HELLO10', filled: true),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final err = await market.applyCouponCode(
                        _couponCtrl.text, market.cartTotal);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(err ?? 'Coupon applied!'),
                      backgroundColor:
                          err == null ? const Color(0xFF00D285) : Colors.red,
                    ));
                  },
                  child: const Text('Apply'),
                ),
              ]),
              if (market.activeCoupon != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${market.activeCoupon!.code} — ${market.activeCoupon!.discountPercent.toStringAsFixed(0)}% off',
                    style: const TextStyle(
                        color: Color(0xFF00D285), fontWeight: FontWeight.w700),
                  ),
                ),

              const SizedBox(height: 28),

              // ── Payment Method Picker ──────────────────────────────
              const Text("Payment Method",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _methodCard(PaymentMethod.evcPlus,
                  "EVC Plus", "Hormuud Telecom",
                  Icons.account_balance_wallet_rounded, const Color(0xFFFF6B00))),
                const SizedBox(width: 12),
                Expanded(child: _methodCard(PaymentMethod.edahab,
                  "eDahab", "Somtel Somalia",
                  Icons.payments_rounded, const Color(0xFF00D285))),
              ]),

              const SizedBox(height: 28),

              // ── Global Payment Info ─────────────────────────────
              const Text("Pay Total Amount",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
              const SizedBox(height: 12),

              _globalPayCard(market.adminEvc, market.adminEdahab, market.cartTotal),

              const SizedBox(height: 16),

              // ── Summary Items ─────────────────────────────────────
              const Text("Order Summary",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
              const SizedBox(height: 8),
              ...cart.entries.map((entry) {
                final store = market.getStoreById(entry.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Text("• ${store?.name ?? 'Store'}", style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                    const Spacer(),
                    Text("${entry.value.length} items", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  ]),
                );
              }),

              const SizedBox(height: 20),

              // ── Info banner ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00D285).withOpacity(0.25)),
                ),
                child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF00D285), size: 18),
                  SizedBox(width: 10),
                  Expanded(child: Text(
                    "Dial the USSD code above to pay the total amount. Admin will verify your payment and process the order.",
                    style: TextStyle(color: Color(0xFF065F46), fontSize: 12, fontWeight: FontWeight.w600, height: 1.5),
                  )),
                ]),
              ),
            ]),
          ),
        ),

        // ── Bottom Bar ───────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Total Payable",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1F2937))),
              Text("\$${market.discountedTotal(market.cartTotal).toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: Color(0xFF00AA5B))),
            ]),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _processing ? null : () async {
                setState(() => _processing = true);
                await Future.delayed(const Duration(milliseconds: 600));
                if (auth.isAuthenticated) {
                  final storeCount = market.cart.length;
                  final orderCount = await market.placeOrder(
                    userId: auth.currentUser!.id,
                    paymentMethod: _method,
                    customerName: _nameCtrl.text.trim(),
                    customerPhone: _phoneCtrl.text.trim(),
                    customerAddress: _addressCtrl.text.trim(),
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    final msg = orderCount > 1
                        ? '$orderCount dalab oo gooni ah ayaa la sameeyay ($storeCount dukaan). Admin wuxuu mid mid u aqbalayaa.'
                        : 'Dalabka waa la gudbiyay! Sug inta uu Admin-ka ka hubinayo lacagta.';
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Row(children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(child: Text(msg,
                          style: const TextStyle(fontWeight: FontWeight.w700))),
                      ]),
                      backgroundColor: const Color(0xFF00D285),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      margin: const EdgeInsets.all(16),
                    ));
                  }
                }
                if (mounted) setState(() => _processing = false);
              },
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF6B00), Color(0xFFD84315)]),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: const Color(0xFFFF6B00).withOpacity(0.4),
                    blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Center(child: _processing
                  ? const SizedBox(width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : const Text("Confirm Order", style: TextStyle(color: Colors.white,
                      fontSize: 18, fontWeight: FontWeight.w900))),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _methodCard(PaymentMethod m, String title, String sub, IconData icon, Color color) {
    bool sel = _method == m;
    return GestureDetector(
      onTap: () => setState(() => _method = m),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: sel ? color : const Color(0xFFE2E8F0), width: sel ? 2 : 1.5),
          boxShadow: sel ? [BoxShadow(color: color.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))] : [],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(width: 38, height: 38,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20)),
            if (sel) Icon(Icons.check_circle_rounded, color: color, size: 20)
            else Container(width: 20, height: 20,
              decoration: BoxDecoration(shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCBD5E1), width: 2))),
          ]),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1F2937))),
          Text(sub, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
        ]),
      ),
    );
  }

  Widget _globalPayCard(String evc, String edahab, double amount) {
    final num    = _method == PaymentMethod.evcPlus ? evc : edahab;
    final ussd   = _method == PaymentMethod.evcPlus
        ? "*712*${num}*${amount.toInt()}#"
        : "*101*${num}*${amount.toInt()}#";
    final color  = _method == PaymentMethod.evcPlus
        ? const Color(0xFFFF6B00) : const Color(0xFF00D285);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            Icon(Icons.qr_code_scanner_rounded, color: color, size: 20),
            const SizedBox(width: 10),
            const Expanded(child: Text("Dial the code below",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1F2937)))),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Row(children: [
                Expanded(child: Text(ussd, style: TextStyle(
                  fontFamily: 'monospace', fontWeight: FontWeight.w900,
                  fontSize: 20, color: color, letterSpacing: 1))),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: ussd));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Copied!"), duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating));
                  },
                  child: Container(padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
                    child: Icon(Icons.copy_rounded, size: 16, color: color)),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.phone_rounded, size: 14, color: color),
              const SizedBox(width: 6),
              Text("Payment number: +252 $num",
                style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w800)),
            ]),
          ]),
        ),
      ]),
    );
  }
}
