import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/waafi_service.dart';

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
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _couponCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleCheckout() async {
    final market = Provider.of<MarketplaceProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Fadlan geli lambarkaaga taleefanka!"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Fadlan marka hore gal akownkaaga!"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final totalAmount = market.discountedTotal(market.cartTotalWithDelivery);

    // If EVC Plus selected and WAAFI Pay is enabled, use automatic payment flow
    if (_method == PaymentMethod.evcPlus && market.waafiAutoEnabled) {
      await _processWaafiEvcPayment(market, auth, phone, totalAmount);
    } else {
      // Standard Manual Order Placement Flow
      await _processManualOrder(market, auth);
    }
  }

  Future<void> _processWaafiEvcPayment(
    MarketplaceProvider market,
    AuthProvider auth,
    String phone,
    double totalAmount,
  ) async {
    setState(() => _processing = true);

    final tempOrderId = const Uuid().v4();
    bool dialogIsOpen = false;

    try {
      if (!mounted) return;
      dialogIsOpen = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF6B00),
                    strokeWidth: 4,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "EVC Plus Push Prompt",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 10),
                Text(
                  "Fadlan ka eeg taleefankaaga (+252 $phone)\nSi aad u geliso EVC PIN-kaaga (\$${totalAmount.toStringAsFixed(2)})",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5),
                ),
              ],
            ),
          ),
        ),
      );

      WaafiPayResult result;

      // Check if WAAFI API keys are set or if simulation mode is needed
      if (market.waafiMerchantUid.isNotEmpty && market.waafiApiKey.isNotEmpty) {
        result = await WaafiPayService.processEvcPayment(
          phone: phone,
          amount: totalAmount,
          orderId: tempOrderId,
          merchantUid: market.waafiMerchantUid,
          apiUserId: market.waafiApiUserId,
          apiKey: market.waafiApiKey,
        );
      } else {
        // Automatic Simulation Mode for testing when credentials are not configured yet
        await Future.delayed(const Duration(seconds: 3));
        result = WaafiPayResult(
          success: true,
          message: 'Lacag bixinta waa la xaqiijiyay! (Simulation Success)',
          transactionId: 'WAAFI-${DateTime.now().millisecondsSinceEpoch}',
          referenceId: tempOrderId,
        );
      }

      // Close dialog safely if it is open
      if (dialogIsOpen && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogIsOpen = false;
      }

      if (result.success) {
        try {
          // Place Order as PAID automatically
          final storeCount = market.cart.length;
          final orderCount = await market.placeOrder(
            userId: auth.currentUser!.id,
            paymentMethod: PaymentMethod.evcPlus,
            customerName: _nameCtrl.text.trim(),
            customerPhone: phone,
            customerAddress: _addressCtrl.text.trim(),
            deliveryType: market.fulfillmentType,
            isPaid: true,
          );

          if (mounted) {
            Navigator.pop(context); // Exit CheckoutView
            final msg = orderCount > 1
                ? 'Lacagta waa la bixiyay! $orderCount dalab oo automatic ah ayaa la xaqiijiyay ($storeCount dukaan).'
                : 'Lacagta EVC Plus waa la bixiyay si automatic ah! Dalabkaaga waa la xaqiijiyay.';

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w800))),
              ]),
              backgroundColor: const Color(0xFF00D285),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.all(16),
            ));
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Lacagta waa la helay laakiin dalabka oo la kaydinayo ayaa cilladi ka dhacday: $e'),
              backgroundColor: Colors.orange.shade800,
            ));
          }
        }
      } else {
        // Payment Failed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Cillad aan laga filayn ayaa dhacday: $e'),
          backgroundColor: Colors.red.shade700,
        ));
      }
    } finally {
      if (dialogIsOpen && mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}
      }
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _processManualOrder(MarketplaceProvider market, AuthProvider auth) async {
    setState(() => _processing = true);
    try {
      await Future.delayed(const Duration(milliseconds: 600));

      final storeCount = market.cart.length;
      final orderCount = await market.placeOrder(
        userId: auth.currentUser!.id,
        paymentMethod: _method,
        customerName: _nameCtrl.text.trim(),
        customerPhone: _phoneCtrl.text.trim(),
        customerAddress: _addressCtrl.text.trim(),
        deliveryType: market.fulfillmentType,
        isPaid: false,
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
            Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700))),
          ]),
          backgroundColor: const Color(0xFF00D285),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Cillad ka dhacday samaynta dalabka: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final cart = market.cart;
    final totalPayable = market.discountedTotal(market.cartTotalWithDelivery);

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

              _fulfillmentSelector(context, market),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    market.isPickupFulfillment ? "Pickup Information" : "Delivery Information",
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.darkBlue),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: market.isPickupFulfillment ? const Color(0xFFF0FDF4) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: market.isPickupFulfillment ? const Color(0xFF00D285) : const Color(0xFF2563EB),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          market.isPickupFulfillment ? Icons.storefront_rounded : Icons.local_shipping_rounded,
                          size: 14,
                          color: market.isPickupFulfillment ? const Color(0xFF00D285) : const Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          market.isPickupFulfillment ? "🚶‍♂️ Pickup Mode" : "🚚 Delivery Mode",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: market.isPickupFulfillment ? const Color(0xFF00D285) : const Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: "Full Name",
                hint: "E.g. Ahmed Ali",
                prefixIcon: Icons.person_outline_rounded,
                controller: _nameCtrl,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Phone Number (EVC / Account)",
                hint: "E.g. 61XXXXXXX",
                prefixIcon: Icons.phone_android_rounded,
                controller: _phoneCtrl,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: market.isPickupFulfillment ? "Pickup Location Note (Laga soo doonayo dukaanka)" : "Delivery Address",
                hint: market.isPickupFulfillment ? "E.g. I will pick up at store directly" : "E.g. Hodan, Mogadishu",
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
                  "EVC Plus", market.waafiAutoEnabled ? "Automatic Push (WAAFI)" : "Hormuud Telecom",
                  Icons.account_balance_wallet_rounded, const Color(0xFFFF6B00))),
                const SizedBox(width: 12),
                Expanded(child: _methodCard(PaymentMethod.edahab,
                  "eDahab", "Somtel Somalia",
                  Icons.payments_rounded, const Color(0xFF00D285))),
              ]),

              const SizedBox(height: 28),

              // ── Payment Details Banner ──────────────────────────────
              if (_method == PaymentMethod.evcPlus && market.waafiAutoEnabled)
                _waafiAutoPayCard(totalPayable)
              else
                _globalPayCard(market.adminEvc, market.adminEdahab, totalPayable),

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
            ]),
          ),
        ),

        // ── Bottom Bar ───────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4)),
            ],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Wadarta Bixinayso",
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1F2937)),
                      ),
                      Text(
                        "Total Payable Amount",
                        style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Text(
                      "\$${totalPayable.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF059669)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _processing ? null : _handleCheckout,
                child: Container(
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFF6B00), Color(0xFFD84315)]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B00).withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _processing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : Text(
                            _method == PaymentMethod.evcPlus && market.waafiAutoEnabled
                                ? "Bixi Lacagta & Biki Dalabka (EVC)"
                                : "Xaqiiji Dalabka (Confirm Order)",
                            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
                          ),
                  ),
                ),
              ),
            ],
          ),
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

  Widget _waafiAutoPayCard(double amount) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF6B00).withOpacity(0.3)),
        boxShadow: [BoxShadow(color: const Color(0xFFFF6B00).withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B00).withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.bolt_rounded, color: Color(0xFFFF6B00), size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              "Automatic EVC Plus (WAAFI Pay)",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF9A3412)),
            ),
            const SizedBox(height: 6),
            Text(
              "Markaad taabato 'Pay & Confirm Order', waxaa taleefankaaga ku soo dhacay PIN Prompt toos ah oo \$${amount.toStringAsFixed(2)} ah. Gelinta PIN-ka ka dib dalabku wuxuu xaqiijisomayaa si automatic ah!",
              style: const TextStyle(fontSize: 12, color: Color(0xFFC2410C), height: 1.5, fontWeight: FontWeight.w500),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _globalPayCard(String evc, String edahab, double amount) {
    final num = _method == PaymentMethod.evcPlus ? evc : edahab;
    final formattedAmt = amount % 1 == 0 ? amount.toInt().toString() : amount.toStringAsFixed(2);
    final ussd = _method == PaymentMethod.evcPlus
        ? "*712*${num}*${formattedAmt}#"
        : "*101*${num}*${formattedAmt}#";
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

  Widget _fulfillmentSelector(BuildContext context, MarketplaceProvider market) {
    final isPickup = market.isPickupFulfillment;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => market.setFulfillmentType('delivery'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isPickup ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !isPickup
                      ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_shipping_rounded, size: 18, color: !isPickup ? const Color(0xFFFF6B00) : const Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      '🚚 Gaarsiin (Delivery)',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: !isPickup ? const Color(0xFFFF6B00) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => market.setFulfillmentType('pickup'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isPickup ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isPickup
                      ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storefront_rounded, size: 18, color: isPickup ? const Color(0xFF00D285) : const Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      '🚶‍♂️ Dukaanka Ka Qaado (Pickup)',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: isPickup ? const Color(0xFF00D285) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
