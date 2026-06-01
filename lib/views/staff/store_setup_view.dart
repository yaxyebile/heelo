import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/store.dart';

class StoreSetupView extends StatefulWidget {
  const StoreSetupView({super.key});

  @override
  State<StoreSetupView> createState() => _StoreSetupViewState();
}

class _StoreSetupViewState extends State<StoreSetupView> {
  final _nameController     = TextEditingController();
  final _descController     = TextEditingController();
  final _contactController  = TextEditingController();
  final _logoController     = TextEditingController();
  final _bannerController   = TextEditingController();
  final _evcController      = TextEditingController();
  final _edahabController   = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // 3 steps: 0=Basic Info, 1=Branding, 2=Payment Numbers
  int _step = 0;
  static const int _totalSteps = 3;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _contactController.dispose();
    _logoController.dispose();
    _bannerController.dispose();
    _evcController.dispose();
    _edahabController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final auth   = Provider.of<AuthProvider>(context, listen: false);
      final market = Provider.of<MarketplaceProvider>(context, listen: false);

      final newStore = Store(
        id:          const Uuid().v4(),
        name:        _nameController.text.trim(),
        logo:        _logoController.text.trim(),
        banner:      _bannerController.text.trim(),
        description: _descController.text.trim(),
        contact:     _contactController.text.trim(),
        ownerId:     auth.currentUser!.id,
        isApproved:  false,
        evcNumber:   _evcController.text.trim().isEmpty ? null : _evcController.text.trim(),
        edahabNumber: _edahabController.text.trim().isEmpty ? null : _edahabController.text.trim(),
      );

      await market.registerStore(newStore);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text("Store submitted! Waiting for admin approval.", style: TextStyle(fontWeight: FontWeight.w700))),
            ]),
            backgroundColor: const Color(0xFF00D285),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _next() {
    if (_step == 0) {
      // validate step 1 fields manually
      if (_nameController.text.trim().isEmpty ||
          _descController.text.trim().isEmpty ||
          _contactController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Please fill all required fields", style: TextStyle(fontWeight: FontWeight.w700)),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }
    }
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      _handleRegister();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background gradient top
          Positioned(
            top: 0, left: 0, right: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B00), Color(0xFFD84315)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Start Selling Today",
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _stepSubtitle(),
                            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
                        child: const Text("Logout", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Step Indicator ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: List.generate(_totalSteps, (i) {
                      final bool done = i < _step;
                      final bool active = i == _step;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: i < _totalSteps - 1 ? 6 : 0),
                          height: 5,
                          decoration: BoxDecoration(
                            color: done || active ? Colors.white : Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Step ${_step + 1} of $_totalSteps",
                      style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Form Card ────────────────────────────────────────────
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 15)),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(28),
                        physics: const BouncingScrollPhysics(),
                        child: _buildCurrentStep(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Navigation Buttons ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      if (_step > 0)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _step--),
                            child: Container(
                              height: 58,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                              ),
                              child: const Center(
                                child: Text("Back", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF374151))),
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: _next,
                          child: Container(
                            height: 58,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFFF6B00), Color(0xFFD84315)]),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFFFF6B00).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _step < _totalSteps - 1 ? "Next Step  →" : "Launch My Store 🚀",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _stepSubtitle() {
    switch (_step) {
      case 0:  return "Set up your store in minutes";
      case 1:  return "Add your branding";
      default: return "Set up your payment numbers";
    }
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:  return _buildStep1();
      case 1:  return _buildStep2();
      default: return _buildStep3();
    }
  }

  // ── Step 1: Basic Info ──────────────────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader("Basic Information", "Tell us about your store"),
        const SizedBox(height: 28),
        CustomTextField(
          label: "Store Name *",
          hint: "E.g. Mogadishu Electronics",
          prefixIcon: Icons.storefront_outlined,
          controller: _nameController,
          validator: (v) => v == null || v.isEmpty ? "Store name is required" : null,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: "Description *",
          hint: "What products do you sell?",
          prefixIcon: Icons.description_outlined,
          controller: _descController,
          validator: (v) => v == null || v.isEmpty ? "Description is required" : null,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: "Contact (Phone/Email) *",
          hint: "+252 61 123 4567",
          prefixIcon: Icons.phone_outlined,
          controller: _contactController,
          validator: (v) => v == null || v.isEmpty ? "Contact is required" : null,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── Step 2: Branding ─────────────────────────────────────────────────────
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader("Store Branding", "Add your store logo and banner"),
        const SizedBox(height: 28),
        if (_logoController.text.isNotEmpty)
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFF6B00), width: 3),
                image: DecorationImage(image: NetworkImage(_logoController.text), fit: BoxFit.cover),
              ),
            ),
          ),
        CustomTextField(
          label: "Store Logo URL",
          hint: "https://example.com/logo.png",
          prefixIcon: Icons.image_outlined,
          controller: _logoController,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: "Store Banner URL",
          hint: "https://example.com/banner.png",
          prefixIcon: Icons.panorama_outlined,
          controller: _bannerController,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── Step 3: Payment Numbers ───────────────────────────────────────────────
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader("Payment Numbers", "Customers will send money to these numbers"),
        const SizedBox(height: 24),

        // EVC Plus
        _paymentNumberField(
          title: "EVC Plus Number",
          subtitle: "Hormuud Telecom",
          hint: "e.g. 610000000",
          controller: _evcController,
          color: const Color(0xFFFF6B00),
          icon: Icons.account_balance_wallet_rounded,
          ussdPreview: "*712*{number}*{amount}#",
        ),
        const SizedBox(height: 20),

        // eDahab
        _paymentNumberField(
          title: "eDahab Number",
          subtitle: "Somtel Somalia",
          hint: "e.g. 625000000",
          controller: _edahabController,
          color: const Color(0xFF00D285),
          icon: Icons.payments_rounded,
          ussdPreview: "*101*{number}*{amount}#",
        ),
        const SizedBox(height: 28),

        // Info banner
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFF6B00).withOpacity(0.3)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: Color(0xFFFF6B00), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Customers choosing EVC Plus will see your EVC number with a ready-to-dial USSD code. Same for eDahab. You can add at least one.",
                  style: TextStyle(color: Color(0xFF7C3A00), fontSize: 13, fontWeight: FontWeight.w600, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _paymentNumberField({
    required String title,
    required String subtitle,
    required String hint,
    required TextEditingController controller,
    required Color color,
    required IconData icon,
    required String ussdPreview,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
                Text(subtitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.5),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontWeight: FontWeight.w500),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: color, width: 2),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Text("+252", style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 14)),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
        // Live USSD preview
        if (controller.text.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.dialpad_rounded, size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ussdPreview.replaceAll("{number}", controller.text.trim()),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _stepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
