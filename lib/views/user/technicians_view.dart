import 'package:flutter/material.dart';
import 'book_technician_view.dart';

class TechniciansView extends StatefulWidget {
  const TechniciansView({super.key});

  @override
  State<TechniciansView> createState() => _TechniciansViewState();
}

class _TechniciansViewState extends State<TechniciansView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Korontada',              'icon': Icons.electrical_services_rounded,     'color': const Color(0xFFFF6B00), 'desc': 'Khabiiro korontada guryaha & ganacsiga'},
    {'name': 'Qaboojiyaha (AC)',       'icon': Icons.ac_unit_rounded,                'color': const Color(0xFF2563EB), 'desc': 'Nadiifinta & hagaajinta AC-yada'},
    {'name': 'Qasaaladaha',            'icon': Icons.local_laundry_service_rounded, 'color': const Color(0xFF0D9488), 'desc': 'Hagaajinta dharka dhaqayaasha'},
    {'name': 'Tuubooyinka (Plumbing)',  'icon': Icons.water_drop_rounded,             'color': const Color(0xFF0284C7), 'desc': 'Hagaajinta tuubooyinka & biyaha'},
    {'name': 'Solar & Batteriga',       'icon': Icons.wb_sunny_rounded,               'color': const Color(0xFFD97706), 'desc': 'Laying & Service Solar Systems'},
    {'name': 'Xirfadaha kale',          'icon': Icons.handyman_rounded,               'color': const Color(0xFF9333EA), 'desc': 'Khabiiro alxanka, rinjiga & dhismaha'},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _categories.where((cat) {
      final name = cat['name'].toString().toLowerCase();
      final desc = cat['desc'].toString().toLowerCase();
      final q    = _searchQuery.toLowerCase();
      return name.contains(q) || desc.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Farsamo Yaqaano',
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w900, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        centerTitle: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Banner
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B00).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('WAAFI PAY API INTEGRATED',
                              style: TextStyle(color: Color(0xFFFF9E43), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                        ),
                        const SizedBox(height: 10),
                        const Text('Farsamo Yaqaano Xirfad Leh',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        const Text('Dooro adeegga aad u baahan tahay, si automatic ahna ugu bixi EVC Plus.',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.3)),
                      ],
                    ),
                  ),
                  Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B00).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.handyman_rounded, color: Color(0xFFFF6B00), size: 28),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Raadi adeegga farsamo yaqaanka...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Category Grid
          filtered.isEmpty
              ? const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text('Adeeg khadkan ku saabsan ma jiro', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final cat = filtered[index];
                        final Color color = cat['color'];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookTechnicianView(category: cat),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: color.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(color: color.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 52, height: 52,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(cat['icon'], size: 28, color: color),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  cat['name'],
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.w900, color: const Color(0xFF1F2937), fontSize: 13.5),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cat['desc'] ?? '',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5, height: 1.2),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
