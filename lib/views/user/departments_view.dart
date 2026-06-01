import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/category.dart';
import '../../providers/marketplace_provider.dart';
import 'category_products_view.dart';

/// Qaybaha Dukaanka — design screen 4
class DepartmentsView extends StatefulWidget {
  const DepartmentsView({super.key});

  @override
  State<DepartmentsView> createState() => _DepartmentsViewState();
}

class _DepartmentsViewState extends State<DepartmentsView> {
  int _tabIndex = 0;

  IconData _icon(String name) {
    switch (name) {
      case 'bolt':
        return Icons.bolt_rounded;
      case 'shirt':
        return Icons.checkroom_rounded;
      case 'basket-shopping':
        return Icons.shopping_basket_rounded;
      case 'utensils':
        return Icons.restaurant_rounded;
      case 'sparkles':
        return Icons.auto_awesome_rounded;
      case 'house':
        return Icons.home_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  List<Category> _filtered(List<Category> all) {
    if (_tabIndex == 0 || all.isEmpty) return all;
    final tabName = _tabLabel(_tabIndex);
    return all.where((c) => c.name.toLowerCase().contains(tabName.toLowerCase())).toList();
  }

  String _tabLabel(int i) {
    const tabs = ['Overview', 'Fashion', 'Electronics'];
    return tabs[i.clamp(0, tabs.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final all = market.categories;
    final categories = _filtered(all);
    final featured = categories.isNotEmpty ? categories.first : null;

    final gridItems = _tabIndex == 0 && featured != null
        ? categories.skip(1).toList()
        : categories;

    final deptMeta = [
      ('Fashion', Icons.checkroom_rounded, Color(0xFFE8F5E9)),
      ('Furniture', Icons.chair_rounded, Color(0xFFFFF3E0)),
      ('Beauty', Icons.spa_rounded, Color(0xFFFCE4EC)),
      ('Gaming', Icons.sports_esports_rounded, Color(0xFFEDE7F6)),
      ('Sports', Icons.fitness_center_rounded, Color(0xFFE3F2FD)),
      ('Warehouse', Icons.warehouse_rounded, Color(0xFFF1F5F9)),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Qaybaha Dukaanka',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimaryLight)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 38,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: List.generate(3, (i) {
                          final selected = _tabIndex == i;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () => setState(() => _tabIndex = i),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Text(
                                  _tabLabel(i),
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textSecondaryLight,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (featured != null && _tabIndex == 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CategoryProductsView(category: featured),
                      ),
                    ),
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00AA5B), Color(0xFF00D285)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(featured.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Shop now →',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.92,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    if (gridItems.isNotEmpty && i < gridItems.length) {
                      final cat = gridItems[i];
                      return _deptCard(
                        context,
                        cat.name,
                        _icon(cat.icon),
                        const Color(0xFFF1F5F9),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CategoryProductsView(category: cat),
                          ),
                        ),
                      );
                    }
                    final meta = deptMeta[i % deptMeta.length];
                    return _deptCard(
                      context,
                      meta.$1,
                      meta.$2,
                      meta.$3,
                      () {},
                    );
                  },
                  childCount: gridItems.isNotEmpty
                      ? gridItems.length
                      : deptMeta.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deptCard(
    BuildContext context,
    String title,
    IconData icon,
    Color bg,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 14),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.textPrimaryLight)),
          ],
        ),
      ),
    );
  }
}
