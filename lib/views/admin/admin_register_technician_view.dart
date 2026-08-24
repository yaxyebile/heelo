import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/supabase_service.dart';

class AdminRegisterTechnicianView extends StatefulWidget {
  const AdminRegisterTechnicianView({super.key});

  @override
  State<AdminRegisterTechnicianView> createState() => _AdminRegisterTechnicianViewState();
}

class _AdminRegisterTechnicianViewState extends State<AdminRegisterTechnicianView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController     = TextEditingController();
  final _phoneController    = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedSpecialty = 'Korontada';
  String _selectedLevel     = 'Sare';
  bool   _saving            = false;

  List<Map<String, dynamic>> _technicians = [];
  bool _loading = true;

  final List<String> _specialties = [
    'Korontada', 'Qaboojiyaha (AC)', 'Qasaaladaha',
    'Tuubooyinka (Plumbing)', 'Xirfadaha kale',
  ];
  final List<String> _levels = ['Sare', 'Dhex Dhexaad', 'Hoose'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await SupabaseService.fetchTechnicians();
    setState(() { _technicians = data; _loading = false; });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final tech = {
      'id':        const Uuid().v4(),
      'name':      _nameController.text.trim(),
      'phone':     _phoneController.text.trim(),
      'location':  _locationController.text.trim(),
      'specialty': _selectedSpecialty,
      'level':     _selectedLevel,
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
    };

    await SupabaseService.upsertTechnician(tech);
    await _load();

    _nameController.clear();
    _phoneController.clear();
    _locationController.clear();
    setState(() { _saving = false; _selectedSpecialty = 'Korontada'; _selectedLevel = 'Sare'; });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Farsamo Yaqaanka waa la diiwaangaliyay!'), backgroundColor: Color(0xFFF97316)),
    );
  }

  Future<void> _delete(String id) async {
    await SupabaseService.deleteTechnician(id);
    await _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Diiwaangali Farsamo Yaqaan', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded), color: const Color(0xFFF97316)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Form Card ──────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF97316), Color(0xFF2563EB)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(children: [
                        Icon(Icons.handyman_rounded, color: Colors.white, size: 28),
                        SizedBox(width: 12),
                        Text('Macluumaadka Farsamo Yaqaanka',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                      ]),
                    ),
                    const SizedBox(height: 20),

                    // Name
                    const Text('Magaca', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDeco('Magaca buuxa', Icons.person_rounded),
                      validator: (v) => v == null || v.isEmpty ? 'Magaca waa loo baahan yahay' : null,
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    const Text('Nambarka Taleefanka', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDeco('61XXXXXXX', Icons.phone_rounded),
                      validator: (v) => v == null || v.isEmpty ? 'Nambarka waa loo baahan yahay' : null,
                    ),
                    const SizedBox(height: 16),

                    // Location
                    const Text('Goobta / Location', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _locationController,
                      decoration: _inputDeco('Tusaale: Hodan, Mogadishu', Icons.location_on_rounded),
                      validator: (v) => v == null || v.isEmpty ? 'Goobta waa loo baahan yahay' : null,
                    ),
                    const SizedBox(height: 16),

                    // Specialty
                    const Text('Xirfada (Specialty)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedSpecialty,
                      decoration: _inputDeco('', Icons.build_circle_rounded),
                      items: _specialties.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => _selectedSpecialty = v!),
                    ),
                    const SizedBox(height: 16),

                    // Level
                    const Text('Heerka (Level)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: _levels.map((lvl) {
                        final isSel = _selectedLevel == lvl;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedLevel = lvl),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFFF97316) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSel ? const Color(0xFFF97316) : Colors.grey.shade200),
                              ),
                              child: Text(
                                lvl,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w800, color: isSel ? Colors.white : Colors.black54, fontSize: 12),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _saving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Diiwaangeli', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Technicians list ────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Farsamo Yaqaanada', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${_technicians.length} Qof', style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (_loading)
                const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)))
              else if (_technicians.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: const Center(child: Text('Wali farsamo yaqaan lama diiwaangalin', style: TextStyle(color: Colors.grey))),
                )
              else
                ..._technicians.map((t) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFF97316).withOpacity(0.1),
                        child: const Icon(Icons.handyman_rounded, color: Color(0xFFF97316), size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            Text('📞 ${t['phone'] ?? ''}  📍 ${t['location'] ?? ''}',
                              style: const TextStyle(color: Colors.black54, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(t['specialty'] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                          Text('Heer ${t['level'] ?? ''}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      IconButton(
                        onPressed: () => _delete(t['id']),
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                      ),
                    ],
                  ),
                )).toList(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: Colors.grey, size: 20),
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
  );
}
