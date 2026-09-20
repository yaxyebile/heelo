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
  final _merchantUidCtrl = TextEditingController();
  final _apiUserIdCtrl = TextEditingController();
  final _apiKeyCtrl = TextEditingController();
  bool _waafiAutoEnabled = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final market = Provider.of<MarketplaceProvider>(context, listen: false);
    _evcCtrl.text = market.adminEvc;
    _edahabCtrl.text = market.adminEdahab;
    _merchantUidCtrl.text = market.waafiMerchantUid;
    _apiUserIdCtrl.text = market.waafiApiUserId;
    _apiKeyCtrl.text = market.waafiApiKey;
    _waafiAutoEnabled = market.waafiAutoEnabled;
  }

  @override
  void dispose() {
    _evcCtrl.dispose();
    _edahabCtrl.dispose();
    _merchantUidCtrl.dispose();
    _apiUserIdCtrl.dispose();
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final market = Provider.of<MarketplaceProvider>(context, listen: false);
    await market.updateAdminPayments(
      evc: _evcCtrl.text.trim(),
      edahab: _edahabCtrl.text.trim(),
      waafiMerchantUid: _merchantUidCtrl.text.trim(),
      waafiApiUserId: _apiUserIdCtrl.text.trim(),
      waafiApiKey: _apiKeyCtrl.text.trim(),
      waafiAutoEnabled: _waafiAutoEnabled,
    );
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Settings-ka lacag bixinta si guul leh ayaa loo kaydiyay ✓"),
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
          const Text("Manual Payment Numbers", 
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
          const SizedBox(height: 8),
          const Text("Lambarrada USSD-ka ee macaamiishu lacagta ugu soo diraan marka ay gacanta ku bixinayaan.",
            style: TextStyle(color: Color(0xFF64748B), height: 1.5, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),

          _field("EVC Plus Number", Icons.account_balance_wallet_rounded, _evcCtrl, const Color(0xFFFF6B00), prefix: "+252 "),
          const SizedBox(height: 16),
          _field("eDahab Number", Icons.payments_rounded, _edahabCtrl, const Color(0xFF00D285), prefix: "+252 "),
          
          const SizedBox(height: 32),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 32),

          // ── WAAFI PAY API INTEGRATION ────────────────────────────────────
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("WAAFI Pay API (Automatic EVC)", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
              SizedBox(height: 4),
              Text("Auto PIN Prompt on user phone",
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            ]),
            Switch(
              value: _waafiAutoEnabled,
              activeColor: const Color(0xFFFF6B00),
              onChanged: (val) => setState(() => _waafiAutoEnabled = val),
            ),
          ]),
          const SizedBox(height: 16),

          if (_waafiAutoEnabled) ...[
            _field("Merchant UID", Icons.vpn_key_rounded, _merchantUidCtrl, const Color(0xFFFF6B00)),
            const SizedBox(height: 16),
            _field("API User ID", Icons.person_pin_rounded, _apiUserIdCtrl, const Color(0xFFFF6B00)),
            const SizedBox(height: 16),
            _field("API Key", Icons.lock_outline_rounded, _apiKeyCtrl, const Color(0xFFFF6B00), obscure: true),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
              ),
              child: const Row(children: [
                Icon(Icons.info_rounded, color: Color(0xFF2563EB), size: 18),
                SizedBox(width: 10),
                Expanded(child: Text(
                  "Haddii aad faarujiso fureyaasha, app-ku wuxuu bixinayaa automatic simulation mode si loo tijaabiyo.",
                  style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF), fontWeight: FontWeight.w600),
                )),
              ]),
            ),
          ],

          const SizedBox(height: 40),

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

          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _field(String label, IconData icon, TextEditingController ctrl, Color color, {String? prefix, bool obscure = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF334155))),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl,
        obscureText: obscure,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: color),
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: color, width: 2)),
          prefixText: prefix,
          prefixStyle: TextStyle(color: color, fontWeight: FontWeight.w900),
        ),
      ),
    ]);
  }
}
