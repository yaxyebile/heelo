import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/category.dart';
import '../../core/widgets/product_card.dart';

class CategoryProductsView extends StatelessWidget {
  final Category category;
  const CategoryProductsView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final products = market.products.where((p) => p.categoryId == category.id && p.isApproved).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Text(
          category.name,
          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
      body: products.isEmpty
          ? const Center(
              child: Text(
                "No products in this category yet.",
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16, fontWeight: FontWeight.w600),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.68,
              ),
              itemCount: products.length,
              itemBuilder: (context, i) => ProductCard(
                product: products[i],
                onTap: () {},
                onAddToCart: () => market.addToCart(products[i], 1),
              ),
            ),
    );
  }
}
