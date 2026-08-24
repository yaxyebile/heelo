import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/hakabo_search_bar.dart';
import '../../models/store.dart';
import '../../providers/marketplace_provider.dart';
import 'cart_view.dart';
import 'store_profile_view.dart';

class StoresListView extends StatefulWidget {
  /// When true, used as bottom-nav tab (no back button).
  final bool rootTab;

  const StoresListView({super.key, this.rootTab = false});

  @override
  State<StoresListView> createState() => _StoresListViewState();
}

class _StoresListViewState extends State<StoresListView> {
  String _query = '';
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final categories = ['All', ...market.categories.map((c) => c.name)];

    var stores = market.stores.where((s) => s.isApproved).toList();
    if (_query.isNotEmpty) {
      stores = stores
          .where((s) => s.name.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: !widget.rootTab,
        leading: widget.rootTab
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          widget.rootTab ? 'Deliveries' : 'Dukaamada',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        centerTitle: widget.rootTab,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const CartView())),
            icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: HakaboSearchBar(
              hint: 'Search stores...',
              showFilter: true,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final label = categories[i];
                final selected = _filter == label;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = label),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: stores.isEmpty
                ? const Center(
                    child: Text('Dukaan lama helin',
                        style: TextStyle(color: AppColors.textSecondaryLight)))
                : RefreshIndicator(
                    onRefresh: () => market.refresh(),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: stores.length,
                      itemBuilder: (_, i) => _storeCard(context, stores[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _storeCard(BuildContext context, Store store) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StoreProfileView(store: store)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: store.logo.isNotEmpty
                  ? Image.network(store.logo, width: 56, height: 56, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _logoPlaceholder())
                  : _logoPlaceholder(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(store.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFB800), size: 16),
                      const SizedBox(width: 4),
                      Text(store.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(width: 8),
                      Text('${store.followers} followers',
                          style: const TextStyle(
                              color: AppColors.textSecondaryLight, fontSize: 12)),
                    ],
                  ),
                  if (store.contact.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(store.contact,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.textSecondaryLight, fontSize: 11)),
                  ],
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.primary, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoPlaceholder() => Container(
        width: 56,
        height: 56,
        color: const Color(0xFFF1F5F9),
        child: const Icon(Icons.storefront_rounded, color: AppColors.primary),
      );
}
