import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/category.dart';
import '../../providers/marketplace_provider.dart';
import '../../core/theme/app_theme.dart';

class AdminCategoriesView extends StatefulWidget {
  const AdminCategoriesView({super.key});

  @override
  State<AdminCategoriesView> createState() => _AdminCategoriesViewState();
}

class _AdminCategoriesViewState extends State<AdminCategoriesView> {
  void _showCategoryDialog({Category? category}) {
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    final iconCtrl = TextEditingController(text: category?.icon ?? 'shopping-bag');
    final isEditing = category != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEditing ? 'Hagaaji Category' : 'Kudhi Category Cusub',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Magaca Category-ga',
                hintText: 'Tusaale: Electronics, Fashion',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: iconCtrl,
              decoration: InputDecoration(
                labelText: 'Icon Key (FontAwesome/Material)',
                hintText: 'Tusaale: bolt, shirt, utensils',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kansal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final icon = iconCtrl.text.trim().isEmpty ? 'shopping-bag' : iconCtrl.text.trim();
              if (name.isEmpty) return;

              final market = Provider.of<MarketplaceProvider>(context, listen: false);
              if (isEditing) {
                final updated = category.copyWith(name: name, icon: icon);
                await market.updateCategory(updated);
              } else {
                final newCat = Category(
                  id: const Uuid().v4(),
                  name: name,
                  icon: icon,
                );
                await market.addCategory(newCat);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(isEditing ? 'Cusboonaysii' : 'Kaydi DB', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final categories = market.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maamulka Categories (Database)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: categories.isEmpty
          ? const Center(child: Text('Ma jiraan categories database-ka ka muuqda.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.category_rounded, color: AppColors.primary),
                    ),
                    title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('ID: ${cat.id} | Icon: ${cat.icon}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                          onPressed: () => _showCategoryDialog(category: cat),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Ma hubtaa?'),
                                content: Text('Ma meel u dhaxeysa inaad tirtirto category-ga "${cat.name}" database-ka?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Haa leeyahay')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Tirtir', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await market.removeCategory(cat.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Category Cusub', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
