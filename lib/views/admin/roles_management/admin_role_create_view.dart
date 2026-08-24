import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/marketplace_provider.dart';
import '../../../models/user_role.dart';

class AdminRoleCreateView extends StatefulWidget {
  const AdminRoleCreateView({super.key});

  @override
  State<AdminRoleCreateView> createState() => _AdminRoleCreateViewState();
}

class _AdminRoleCreateViewState extends State<AdminRoleCreateView> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // All roles EXCEPT user
  UserRole _selectedRole = UserRole.seller;
  String? _selectedStoreId;
  bool _loading = false;
  bool _obscure = true;

  static const _roles = [
    (UserRole.seller,   'Seller',   Icons.storefront_rounded,         Color(0xFF00D285), Color(0xFF002D1A)),
    (UserRole.delivery, 'Delivery', Icons.delivery_dining_rounded,    Color(0xFF8B5CF6), Color(0xFF1A0D2D)),
    (UserRole.admin,    'Admin',    Icons.shield_rounded,             Color(0xFFFFB800), Color(0xFF2D1F00)),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _phoneCtrl.dispose();
    super.dispose();
  }

  String _roleLabel(UserRole r) {
    switch (r) {
      case UserRole.seller:   return 'Seller';
      case UserRole.delivery: return 'Delivery Staff';
      case UserRole.admin:    return 'Admin';
      default:                return 'User';
    }
  }

  Color _roleColor(UserRole r) {
    switch (r) {
      case UserRole.admin:    return const Color(0xFFFFB800);
      case UserRole.delivery: return const Color(0xFF8B5CF6);
      default:                return const Color(0xFF00D285);
    }
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.trim().isEmpty) {
      _snack('Fadlan buuxi dhammaan meelaha', isError: true);
      return;
    }
    setState(() => _loading = true);
    final auth   = Provider.of<AuthProvider>(context, listen: false);
    final market = Provider.of<MarketplaceProvider>(context, listen: false);

    final error = await auth.adminRegisterUser(
      name:     _nameCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      role:     _selectedRole,
      storeId:  _selectedRole == UserRole.seller ? _selectedStoreId : null,
    );

    await market.refreshUsers();
    setState(() => _loading = false);

    if (error != null) {
      _snack(error, isError: true);
    } else {
      _snack('${_roleLabel(_selectedRole)} si guul leh ayaa loo diiwaangeliyay ✓');
      _nameCtrl.clear(); _emailCtrl.clear();
      _passCtrl.clear(); _phoneCtrl.clear();
      setState(() => _selectedStoreId = null);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) Navigator.pop(context);
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
    final market = Provider.of<MarketplaceProvider>(context);
    final approvedStores = market.stores.where((s) => s.isApproved).toList();
    final activeColor = _roleColor(_selectedRole);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Staff Member', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Role Selector ─────────────────────────────────────────────
            const _SectionLabel('Select Role'),
            const SizedBox(height: 12),
            ...(_roles.map((r) => _RoleOption(
              role: r.$1, label: r.$2, icon: r.$3, color: r.$4, bg: r.$5,
              selected: _selectedRole == r.$1,
              onTap: () => setState(() { _selectedRole = r.$1; _selectedStoreId = null; }),
            ))),

            const SizedBox(height: 28),

            // ── Form ─────────────────────────────────────────────────────
            const _SectionLabel('Account Details'),
            const SizedBox(height: 14),
            _DarkField(label: 'Full Name',            icon: Icons.person_outline_rounded, controller: _nameCtrl,  color: activeColor),
            const SizedBox(height: 14),
            _DarkField(label: 'Email Address',        icon: Icons.email_outlined,          controller: _emailCtrl, color: activeColor, type: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _DarkField(label: 'Phone (optional)',     icon: Icons.phone_outlined,          controller: _phoneCtrl, color: activeColor, type: TextInputType.phone),
            const SizedBox(height: 14),
            _DarkPasswordField(controller: _passCtrl, color: activeColor, obscure: _obscure, onToggle: () => setState(() => _obscure = !_obscure)),

            // ── Store Assignment ─────────────────────────────────────────
            if (_selectedRole == UserRole.seller) ...[
              const SizedBox(height: 14),
              const _SectionLabel('Assign Store (optional)'),
              const SizedBox(height: 10),
              _StoreDropdown(
                approvedStores: approvedStores,
                selectedId: _selectedStoreId,
                color: activeColor,
                onChanged: (v) => setState(() => _selectedStoreId = v),
              ),
            ],

            // ── Admin Warning ─────────────────────────────────────────────
            if (_selectedRole == UserRole.admin) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFB800).withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB800), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Admin accounts have full access to all system features. Use with caution.',
                        style: TextStyle(color: Color(0xFFFFB800), fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // ── Submit ────────────────────────────────────────────────────
            GestureDetector(
              onTap: _loading ? null : _submit,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [activeColor, activeColor.withOpacity(0.7)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: activeColor.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Center(
                  child: _loading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Register ${_roleLabel(_selectedRole)}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── ROLE OPTION ───────────────────────────────────────────────────────────────

class _RoleOption extends StatelessWidget {
  final UserRole role;
  final String label;
  final IconData icon;
  final Color color, bg;
  final bool selected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.role, required this.label, required this.icon,
    required this.color, required this.bg, required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: selected ? bg : const Color(0xFF111827),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? color : Colors.white.withOpacity(0.06), width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: selected ? color : Colors.white38, size: 22),
            ),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: selected ? color : Colors.white54)),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? color : Colors.transparent,
                border: Border.all(color: selected ? color : Colors.white24, width: 2),
              ),
              child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── SECTION LABEL ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white60, letterSpacing: 0.3));
  }
}

// ── DARK FIELD ────────────────────────────────────────────────────────────────

class _DarkField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final Color color;
  final TextInputType type;

  const _DarkField({required this.label, required this.icon, required this.controller, required this.color, this.type = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF4B5563)),
        filled: true, fillColor: const Color(0xFF111827),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.06))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: color, width: 2)),
      ),
    );
  }
}

// ── DARK PASSWORD FIELD ───────────────────────────────────────────────────────

class _DarkPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final Color color;
  final bool obscure;
  final VoidCallback onToggle;

  const _DarkPasswordField({required this.controller, required this.color, required this.obscure, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: Color(0xFF4B5563)),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20, color: const Color(0xFF4B5563)),
          onPressed: onToggle,
        ),
        filled: true, fillColor: const Color(0xFF111827),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.06))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: color, width: 2)),
      ),
    );
  }
}

// ── STORE DROPDOWN ────────────────────────────────────────────────────────────

class _StoreDropdown extends StatelessWidget {
  final List<dynamic> approvedStores;
  final String? selectedId;
  final Color color;
  final ValueChanged<String?> onChanged;

  const _StoreDropdown({required this.approvedStores, required this.selectedId, required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedId,
          dropdownColor: const Color(0xFF1E293B),
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          hint: const Text('Select a store', style: TextStyle(color: Color(0xFF64748B))),
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('None', style: TextStyle(color: Color(0xFF64748B)))),
            ...approvedStores.map((s) => DropdownMenuItem<String?>(value: s.id, child: Text(s.name))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
