import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/hakabo_search_bar.dart';
import 'book_technician_view.dart';

class TechniciansView extends StatefulWidget {
  const TechniciansView({super.key});

  @override
  State<TechniciansView> createState() => _TechniciansViewState();
}

class _TechniciansViewState extends State<TechniciansView> {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Korontada', 'icon': Icons.electrical_services_rounded, 'color': Colors.orange},
    {'name': 'Qaboojiyaha (AC)', 'icon': Icons.ac_unit_rounded, 'color': Colors.blue},
    {'name': 'Qasaaladaha', 'icon': Icons.local_laundry_service_rounded, 'color': Colors.teal},
    {'name': 'Tuubooyinka (Plumbing)', 'icon': Icons.water_drop_rounded, 'color': Colors.cyan},
    {'name': 'Xirfadaha kale', 'icon': Icons.handyman_rounded, 'color': Colors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Farsamo Yaqaano',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: const HakaboSearchBar(
                hint: 'Raadi farsamo yaqaan...',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = _categories[index];
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
                      decoration: BoxDecoration(
                        color: cat['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cat['color'].withOpacity(0.2)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            cat['icon'],
                            size: 40,
                            color: cat['color'],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            cat['name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: cat['color'],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _categories.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }
}
