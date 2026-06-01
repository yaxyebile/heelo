import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/store.dart';

class AdminRegisterStoreView extends StatefulWidget {
  const AdminRegisterStoreView({super.key});

  @override
  State<AdminRegisterStoreView> createState() => _AdminRegisterStoreViewState();
}

class _AdminRegisterStoreViewState extends State<AdminRegisterStoreView> {
  final _nameCtrl   = TextEditingController();
  final _descCtrl   = TextEditingController();
  final _logoCtrl   = TextEditingController();
  final _bannerCtrl = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose(); _logoCtrl.dispose();
    _bannerCtrl.dispose(); _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
      _snack("Magaca iyo Lambarka telefoonka ayaa muhiim ah", isError: true);
      return;
    }

    setState(() => _loading = true);
    final market = Provider.of<MarketplaceProvider>(context, listen: false);

    final newStore = Store(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      logo: _logoCtrl.text.trim(),
      banner: _bannerCtrl.text.trim(),
      contact: _phoneCtrl.text.trim(),
      ownerId: 'admin', // Placeholder until seller is assigned
      isApproved: true,
      rating: 0.0,
      followers: 0,
    );

    await market.registerStore(newStore);
    
    setState(() => _loading = false);
    if (mounted) {
      _snack("Dukaanka ${newStore.name} waa ladiiwaangeliyay ✓");
      Navigator.pop(context);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF00D285),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text("Diiwaangeli Dukaan Cusub", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true, elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Macluumaadka Dukaanka", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 20),
          
          _field("Magaca Dukaanka", Icons.store_rounded, _nameCtrl),
          const SizedBox(height: 16),
          _field("Sharaxaadda", Icons.description_outlined, _descCtrl, lines: 3),
          const SizedBox(height: 16),
          _field("Tel. Dukaanka", Icons.phone_android_rounded, _phoneCtrl),
          const SizedBox(height: 24),

          const Text("Muuqaalka ( URLs )", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          _field("Sawirka Logo-ka (URL)", Icons.image_outlined, _logoCtrl),
          const SizedBox(height: 12),
          _field("Sawirka Banner-ka (URL)", Icons.style_outlined, _bannerCtrl),
          const SizedBox(height: 40),

          GestureDetector(
            onTap: _loading ? null : _submit,
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
                  : const Text("Diiwaangeli Dukaanka", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text("Fadlan ogow: Markaad dukaanka diiwaangeliso ka dib ayaad Seller-ka u xilsaari kartaa.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _field(String label, IconData icon, TextEditingController ctrl, {int lines = 1}) {
    return TextFormField(
      controller: ctrl, maxLines: lines,
      decoration: InputDecoration(
        labelText: label, prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 2)),
      ),
    );
  }
}
