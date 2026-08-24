import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';

class AdminTechnicianPricingView extends StatefulWidget {
  const AdminTechnicianPricingView({super.key});

  @override
  State<AdminTechnicianPricingView> createState() => _AdminTechnicianPricingViewState();
}

class _AdminTechnicianPricingViewState extends State<AdminTechnicianPricingView> {
  final List<String> _levels = ['Sare', 'Dhex Dhexaad', 'Hoose'];
  final List<String> _categories = [
    'Korontada',
    'Qaboojiyaha (AC)',
    'Qasaaladaha',
    'Tuubooyinka (Plumbing)',
    'Xirfadaha kale',
  ];

  Map<String, Map<String, TextEditingController>> _controllers = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final pricing = await SupabaseService.fetchTechPricing();
    final ctrls = <String, Map<String, TextEditingController>>{};
    for (final cat in _categories) {
      ctrls[cat] = {};
      final levels = pricing[cat] ?? {};
      for (final lvl in _levels) {
        ctrls[cat]![lvl] = TextEditingController(
          text: (levels[lvl] ?? 0).toStringAsFixed(0),
        );
      }
    }
    setState(() {
      _controllers = ctrls;
      _loading = false;
    });
  }

  @override
  void dispose() {
    for (final map in _controllers.values) {
      for (final ctrl in map.values) ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    for (final cat in _categories) {
      final sare  = double.tryParse(_controllers[cat]!['Sare']!.text.trim()) ?? 0;
      final dhex  = double.tryParse(_controllers[cat]!['Dhex Dhexaad']!.text.trim()) ?? 0;
      final hoose = double.tryParse(_controllers[cat]!['Hoose']!.text.trim()) ?? 0;
      await SupabaseService.upsertTechPricing(cat, sare, dhex, hoose);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Lacagaha waa la keydiiyay Supabase!'),
        backgroundColor: Color(0xFFF97316),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Lacagaha Farsamada', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_rounded, color: Color(0xFFF97316)),
            label: const Text('Keydi', style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF97316), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Lacagaha halkan aad u qorto ayaa user-ka ka soo jeeda marka uu farsamo dalbanayo.',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                ..._categories.map((cat) {
                  if (_controllers[cat] == null) return const SizedBox();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🔧 $cat', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                        const SizedBox(height: 14),
                        ..._levels.map((lvl) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 110,
                                child: Text('Heer $lvl', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _controllers[cat]![lvl],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    prefixText: '\$',
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Keydi Dhamaan Lacagaha', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
                ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }
}
