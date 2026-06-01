import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/user_role.dart';

class AdminRegisterUserView extends StatefulWidget {
  const AdminRegisterUserView({super.key});

  @override
  State<AdminRegisterUserView> createState() => _AdminRegisterUserViewState();
}

class _AdminRegisterUserViewState extends State<AdminRegisterUserView> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  UserRole _role = UserRole.seller;
  String? _selectedStoreId;
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty) {
      _snack("Fadlan buuxi dhammaan meelaha", isError: true);
      return;
    }

    setState(() => _loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final market = Provider.of<MarketplaceProvider>(context, listen: false);

    final error = await auth.adminRegisterUser(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      role: _role,
      storeId: _role == UserRole.seller ? _selectedStoreId : null,
    );

    await market.refreshUsers();

    setState(() => _loading = false);

    if (error != null) {
      _snack(error, isError: true);
    } else {
      _snack("${_roleLabel(_role)} si guul leh ayaa loo diiwaangeliyay ✓");
      _nameCtrl.clear(); _emailCtrl.clear(); _passCtrl.clear();
      setState(() { _selectedStoreId = null; });
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

  String _roleLabel(UserRole r) {
    switch (r) {
      case UserRole.seller:   return "Seller";
      case UserRole.delivery: return "Delivery";
      default:                return "User";
    }
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final approvedStores = market.stores.where((s) => s.isApproved).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text("Register New User", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Existing Users ─────────────────────────────────────────
          _existingUsersSection(market),

          const SizedBox(height: 32),
          const Text("Register New Account",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 20),

          // ── Role Picker ────────────────────────────────────────────
          const Text("Role", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF374151))),
          const SizedBox(height: 10),
          Row(children: [
            _rolePill(UserRole.seller,   "Seller",   Icons.storefront_rounded,    const Color(0xFFFF6B00)),
            const SizedBox(width: 10),
            _rolePill(UserRole.delivery, "Delivery", Icons.delivery_dining_rounded, const Color(0xFF8B5CF6)),
          ]),
          const SizedBox(height: 20),

          // ── Name ──────────────────────────────────────────────────
          _field("Full Name", Icons.person_outline_rounded, _nameCtrl),
          const SizedBox(height: 16),
          _field("Email", Icons.email_outlined, _emailCtrl, type: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _passwordField(),
          const SizedBox(height: 16),

          // ── Store assignment for sellers ───────────────────────────
          if (_role == UserRole.seller) ...[
            const Text("Assign Store (optional)",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF374151))),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _selectedStoreId,
                  isExpanded: true,
                  hint: const Text("Select a store", style: TextStyle(color: Color(0xFFCBD5E1))),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text("None")),
                    ...approvedStores.map((s) => DropdownMenuItem<String?>(
                      value: s.id,
                      child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    )),
                  ],
                  onChanged: (v) => setState(() => _selectedStoreId = v),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 12),
          GestureDetector(
            onTap: _loading ? null : _submit,
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFFD84315)]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 8))],
              ),
              child: Center(
                child: _loading
                  ? const SizedBox(width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Text("Register ${_roleLabel(_role)}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _existingUsersSection(MarketplaceProvider market) {
    final sellers   = market.getSellers();
    final drivers   = market.getDeliveryPersons();
    if (sellers.isEmpty && drivers.isEmpty) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Registered Staff", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
      const SizedBox(height: 12),
      ...sellers.map((u) => _userTile(u, const Color(0xFFFF6B00), Icons.storefront_rounded, "Seller")),
      ...drivers.map((u) => _userTile(u, const Color(0xFF8B5CF6), Icons.delivery_dining_rounded, "Delivery")),
    ]);
  }

  Widget _userTile(dynamic user, Color color, IconData icon, String roleLabel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          Text(user.email, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(roleLabel, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11)),
        ),
      ]),
    );
  }

  Widget _rolePill(UserRole role, String label, IconData icon, Color color) {
    final bool selected = _role == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? color : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? color : const Color(0xFFE2E8F0), width: 2),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: selected ? Colors.white : color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(
              fontWeight: FontWeight.w800, fontSize: 14,
              color: selected ? Colors.white : color)),
          ]),
        ),
      ),
    );
  }

  Widget _field(String label, IconData icon, TextEditingController ctrl,
      {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF6B7280)),
        filled: true, fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 2)),
      ),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _passCtrl,
      obscureText: _obscure,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: Color(0xFF6B7280)),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            size: 20, color: const Color(0xFF6B7280)),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        filled: true, fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 2)),
      ),
    );
  }
}
