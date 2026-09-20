import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../core/widgets/product_card.dart';
import 'product_details_view.dart';

class CategoryProductsView extends StatelessWidget {
  final Category? category;
  final String? title;
  final List<Product>? customProducts;

  const CategoryProductsView({
    super.key,
    this.category,
    this.title,
    this.customProducts,
  });

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final displayTitle = title ?? category?.name ?? "Products";
    final products = customProducts ??
        (category != null
            ? market.products.where((p) => p.categoryId == category!.id && p.isApproved).toList()
            : market.nonRestaurantProducts);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1F2937), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          displayTitle,
          style: const TextStyle(color: Color(0xFF1F2937), fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => market.refresh(),
        child: products.isEmpty
            ? const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 400,
                  child: Center(
                    child: Text(
                      "No products found.",
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(24),
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.68,
                ),
                itemCount: products.length,
                itemBuilder: (context, i) => ProductCard(
                  product: products[i],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsView(product: products[i]),
                      ),
                    );
                  },
                  onAddToCart: () => market.addToCart(products[i], 1),
                ),
              ),
      ),
    );
  }
}
