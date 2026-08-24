import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/hakabo_search_bar.dart';
import '../../core/widgets/product_card.dart';
import '../../providers/marketplace_provider.dart';
import 'product_details_view.dart';
import 'store_profile_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final products = market.searchProducts(_query);
    final stores = market.searchStores(_query);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Search', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: HakaboSearchBar(
              hint: 'Search products, brands...',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? const Center(
                    child: Text('Type to search',
                        style: TextStyle(color: AppColors.textSecondaryLight)))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    children: [
                      if (stores.isNotEmpty) ...[
                        const Text('Stores',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 16)),
                        const SizedBox(height: 12),
                        ...stores.map((s) => ListTile(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => StoreProfileView(store: s)),
                              ),
                              leading: CircleAvatar(
                                backgroundImage: s.logo.isNotEmpty
                                    ? NetworkImage(s.logo)
                                    : null,
                                child: s.logo.isEmpty
                                    ? const Icon(Icons.store_rounded)
                                    : null,
                              ),
                              title: Text(s.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                            )),
                        const SizedBox(height: 20),
                      ],
                      const Text('Products',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 16)),
                      const SizedBox(height: 12),
                      if (products.isEmpty && stores.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: Text('Nothing found')),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: products.length,
                          itemBuilder: (_, i) => ProductCard(
                            product: products[i],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailsView(product: products[i]),
                              ),
                            ),
                            onAddToCart: () =>
                                market.addToCart(products[i], 1),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
