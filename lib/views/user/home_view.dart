import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/category.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/helo_logo_title.dart';
import '../../core/widgets/helo_search_bar.dart';
import '../../core/constants/colors.dart';
import 'store_profile_view.dart';
import 'departments_view.dart';
import 'category_products_view.dart';
import 'product_details_view.dart';
import 'cart_view.dart';
import 'stores_list_view.dart';
import 'search_view.dart';
import 'notifications_view.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';

class UserHomeView extends StatefulWidget {
  const UserHomeView({super.key});
  @override
  State<UserHomeView> createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<UserHomeView> {
  int _activeBanner = 0;
  final PageController _bannerController = PageController();

  int _cartItemCount(MarketplaceProvider market) {
    var n = 0;
    for (final items in market.cart.values) {
      n += items.length;
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final notif = Provider.of<NotificationProvider>(context);
    final cartCount = _cartItemCount(market);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                const Expanded(child: HeloLogoTitle(logoHeight: 26)),
                if (auth.isAuthenticated) _notifButton(context, notif.unreadCount),
                _cartButton(context, cartCount),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchView()),
                    ),
                    child: const AbsorbPointer(
                      child: HeloSearchBar(
                        hint: 'Search for products, brands...',
                      ),
                    ),
                  ),
                ),

                if (market.promos.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: SizedBox(
                        height: 170,
                        child: PageView.builder(
                          controller: _bannerController,
                          itemCount: market.promos.length,
                          onPageChanged: (i) => setState(() => _activeBanner = i),
                          itemBuilder: (_, i) => _bannerCard(market.promos[i]),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        market.promos.length,
                        (i) => Container(
                          width: i == _activeBanner ? 20 : 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: i == _activeBanner
                                ? AppColors.primary
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                _sectionHeader('Categories', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DepartmentsView()),
                  );
                }),
                const SizedBox(height: 14),
                _buildCategories(context, market.categories),

                const SizedBox(height: 24),
                _sectionHeader('Top Stores', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StoresListView()),
                  );
                }),
                const SizedBox(height: 14),
                _buildTopStores(context, market),

                const SizedBox(height: 24),
                _sectionHeader('Featured Products', () {}),
                const SizedBox(height: 14),
                _buildFeatured(context, market),

                const SizedBox(height: 24),
                _sectionHeader('New Arrivals', () {}),
                const SizedBox(height: 14),
                _buildNewArrivals(context, market),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notifButton(BuildContext context, int unread) {
    return GestureDetector(
      onTap: () {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        if (auth.currentUser != null) {
          Provider.of<NotificationProvider>(context, listen: false)
              .load(auth.currentUser!.id);
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsView()),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.notifications_outlined,
                color: AppColors.primary, size: 22),
          ),
          if (unread > 0)
            Positioned(
              right: 4,
              top: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cartButton(BuildContext context, int count) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const CartView())),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                color: AppColors.primary, size: 22),
          ),
          if (count > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bannerCard(dynamic b) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00AA5B), Color(0xFF00D285)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        image: b.imageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(b.imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.35), BlendMode.darken))
            : null,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            b.tag.isNotEmpty ? b.tag : 'SUPER SALE',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1),
          ),
          const SizedBox(height: 6),
          Text(b.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.1)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              b.btnText.isEmpty ? 'Shop Now' : b.btnText,
              style: const TextStyle(
                  color: Color(0xFF1A3A2F),
                  fontWeight: FontWeight.w800,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context, List<Category> categories) {
    final icons = [
      Icons.phone_android_rounded,
      Icons.checkroom_rounded,
      Icons.chair_rounded,
      Icons.spa_rounded,
      Icons.sports_esports_rounded,
    ];
    final labels = ['Electronics', 'Fashion', 'Home', 'Health', 'Gaming'];
    final count = categories.isNotEmpty ? categories.length : icons.length;

    return SizedBox(
      height: 92,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: count.clamp(0, 8),
        itemBuilder: (ctx, i) {
          final name = categories.isNotEmpty ? categories[i].name : labels[i % 5];
          return GestureDetector(
            onTap: () {
              if (categories.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CategoryProductsView(category: categories[i]),
                  ),
                );
              }
            },
            child: Container(
              width: 72,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      categories.isNotEmpty
                          ? _getIcon(categories[i].icon)
                          : icons[i % icons.length],
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopStores(BuildContext context, MarketplaceProvider market) {
    final stores = market.stores.where((s) => s.isApproved).take(5).toList();
    if (stores.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text('No stores yet',
            style: TextStyle(color: AppColors.textSecondaryLight)),
      );
    }
    return SizedBox(
      height: 88,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: stores.length,
        itemBuilder: (_, i) {
          final s = stores[i];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StoreProfileView(store: s)),
            ),
            child: Container(
              width: 200,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: s.logo.isNotEmpty
                        ? Image.network(s.logo,
                            width: 48, height: 48, fit: BoxFit.cover)
                        : Container(
                            width: 48,
                            height: 48,
                            color: AppColors.primary.withValues(alpha: 0.15),
                            child: const Icon(Icons.store_rounded,
                                color: AppColors.primary),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 13)),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 12, color: Color(0xFFFFB800)),
                            Text(' ${s.rating.toStringAsFixed(1)}',
                                style: const TextStyle(fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatured(BuildContext context, MarketplaceProvider market) {
    final prods = market.products.where((p) => p.isApproved).take(6).toList();
    if (prods.isEmpty) return _emptyState('No products yet');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        itemCount: prods.length,
        itemBuilder: (_, i) => ProductCard(
          product: prods[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ProductDetailsView(product: prods[i])),
          ),
          onAddToCart: () => market.addToCart(prods[i], 1),
        ),
      ),
    );
  }

  Widget _buildNewArrivals(BuildContext context, MarketplaceProvider market) {
    final prods =
        market.products.where((p) => p.isApproved).toList().reversed.take(6).toList();
    if (prods.isEmpty) return _emptyState('No new listings');
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: prods.length,
        itemBuilder: (_, i) {
          final p = prods[i];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ProductDetailsView(product: p)),
            ),
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: p.image.isNotEmpty
                        ? Image.network(p.image,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover)
                        : Container(
                            height: 120,
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(Icons.image_outlined,
                                color: Color(0xFFCBD5E1)),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 12)),
                        Text('\$${p.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimaryLight)),
          GestureDetector(
            onTap: onSeeAll,
            child: const Text('See All',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(msg,
              style: const TextStyle(color: AppColors.textSecondaryLight)),
        ),
      );

  IconData _getIcon(String name) {
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
}
