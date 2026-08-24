import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';

class AdminPaymentSettingsView extends StatefulWidget {
  const AdminPaymentSettingsView({super.key});

  @override
  State<AdminPaymentSettingsView> createState() => _AdminPaymentSettingsViewState();
}

class _AdminPaymentSettingsViewState extends State<AdminPaymentSettingsView> {
  final _evcCtrl = TextEditingController();
  final _edahabCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final market = Provider.of<MarketplaceProvider>(context, listen: false);
    _evcCtrl.text = market.adminEvc;
    _edahabCtrl.text = market.adminEdahab;
  }

  @override
  void dispose() {
    _evcCtrl.dispose();
    _edahabCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final market = Provider.of<MarketplaceProvider>(context, listen: false);
    await market.updateAdminPayments(
      evc: _evcCtrl.text.trim(),
      edahab: _edahabCtrl.text.trim(),
    );
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Lambarrada lacagta si guul leh ayaa loo kaydiyay ✓"),
        backgroundColor: const Color(0xFF00D285),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
        title: const Text("Payment Settings", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true, elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Global Payment Numbers", 
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
          const SizedBox(height: 8),
          const Text("Dhammaan dukaamada waxay isticmaali doonaan lambarradan si ay macaamiishu lacagta ugu soo diraan.",
            style: TextStyle(color: Color(0xFF64748B), height: 1.5, fontWeight: FontWeight.w500)),
          const SizedBox(height: 32),

          _field("EVC Plus Number", Icons.account_balance_wallet_rounded, _evcCtrl, const Color(0xFFFF6B00)),
          const SizedBox(height: 20),
          _field("eDahab Number", Icons.payments_rounded, _edahabCtrl, const Color(0xFF00D285)),
          const SizedBox(height: 48),

          GestureDetector(
            onTap: _loading ? null : _save,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF6B00), Color(0xFFD84315)]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: const Color(0xFFFF6B00).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Center(
                child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save Settings", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
              ),
            ),
          ),

          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFF6B00).withOpacity(0.1)),
            ),
            child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.lock_rounded, color: Color(0xFFFF6B00), size: 18),
              SizedBox(width: 12),
              Expanded(child: Text(
                "Lambarradan waa kuwa rasmiga ah ee nidaamka. Hubi inay sax yihiin ka hor intaadan kaydin.",
                style: TextStyle(color: Color(0xFF7C3A00), fontSize: 13, fontWeight: FontWeight.w600, height: 1.5),
              )),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _field(String label, IconData icon, TextEditingController ctrl, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF334155))),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.phone,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: color),
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: color, width: 2)),
          prefixText: "+252 ", prefixStyle: TextStyle(color: color, fontWeight: FontWeight.w900),
        ),
      ),
    ]);
  }
}
