import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/store.dart';
import '../../core/widgets/product_card.dart';
import '../../core/constants/colors.dart';

class StoreProfileView extends StatefulWidget {
  final Store store;
  const StoreProfileView({super.key, required this.store});

  @override
  State<StoreProfileView> createState() => _StoreProfileViewState();
}

class _StoreProfileViewState extends State<StoreProfileView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final allProducts = market.getApprovedProductsByStore(widget.store.id);

    final products = _searchQuery.isEmpty
        ? allProducts
        : allProducts.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Hero AppBar ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            leading: Padding(
              padding: const EdgeInsets.all(10),
              child: CircleAvatar(
                backgroundColor: Colors.black38,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: CircleAvatar(
                  backgroundColor: Colors.black38,
                  child: IconButton(
                    icon: const Icon(Icons.ios_share_rounded, color: Colors.white, size: 18),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.store.banner.isNotEmpty
                      ? Image.network(widget.store.banner, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: const Color(0xFF00884A)))
                      : Container(color: const Color(0xFF00884A)),
                  // Gradient overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                  // Store info
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 12)],
                            color: const Color(0xFFF1F5F9),
                            image: widget.store.logo.isNotEmpty
                                ? DecorationImage(image: NetworkImage(widget.store.logo), fit: BoxFit.cover)
                                : null,
                          ),
                          child: widget.store.logo.isEmpty ? const Icon(Icons.store_rounded, size: 30, color: Colors.grey) : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.store.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.verified_rounded, color: Colors.blueAccent, size: 16),
                                  const SizedBox(width: 5),
                                  const Text("Verified Seller", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Body ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats card
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Row(
                    children: [
                      _stat("${widget.store.rating}", "Rating", Icons.star_rounded, const Color(0xFFFFB800)),
                      _divider(),
                      _stat("${widget.store.followers}", "Followers", Icons.people_rounded, AppColors.primary),
                      _divider(),
                      _stat("${allProducts.length}", "Products", Icons.shopping_bag_rounded, const Color(0xFF00D285)),
                    ],
                  ),
                ),
                // About
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("About Store", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                      const SizedBox(height: 10),
                      Text(widget.store.description,
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500, height: 1.6)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const Text("Products", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: const InputDecoration(
                              hintText: "Search in store...",
                              hintStyle: TextStyle(color: Color(0xFFADB5BD), fontSize: 13, fontWeight: FontWeight.w500),
                              prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                if (products.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text("No products found", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
              ],
            ),
          ),

          // Products grid
          if (products.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.68,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => ProductCard(
                    product: products[i],
                    onTap: () {},
                    onAddToCart: () => market.addToCart(products[i], 1),
                  ),
                  childCount: products.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text("Message", style: TextStyle(fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  foregroundColor: const Color(0xFF1F2937),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
                label: const Text("Follow", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1F2937))),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 50, color: const Color(0xFFF1F5F9));
}
