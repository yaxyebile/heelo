import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hakabo/core/l10n/app_strings.dart';
import 'package:hakabo/core/l10n/locale_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/category.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/hakabo_logo_title.dart';
import '../../core/widgets/hakabo_search_bar.dart';
import '../../core/constants/colors.dart';
import 'store_profile_view.dart';
import 'departments_view.dart';
import 'category_products_view.dart';
import 'product_details_view.dart';
import 'cart_view.dart';
import 'stores_list_view.dart';
import 'search_view.dart';
import 'notifications_view.dart';
import 'property_listings_view.dart';
import 'second_hand_view.dart';
import 'technicians_view.dart';
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
    final locale = Provider.of<LocaleProvider>(context);
    final cartCount = _cartItemCount(market);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => market.refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                const Expanded(child: HakaboLogoTitle(logoHeight: 26)),
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
                      child: HakaboSearchBar(
                        hint: 'Raadi alaab, dukaamo...',
                      ),
                    ),
                  ),
                ),

                if (market.isLoading) ...[
                   _buildSkeleton(context),
                ] else ...[
                   AnimationLimiter(
                     child: Column(
                       children: AnimationConfiguration.toStaggeredList(
                         duration: const Duration(milliseconds: 600),
                         childAnimationBuilder: (widget) => SlideAnimation(
                           verticalOffset: 50.0,
                           child: FadeInAnimation(child: widget),
                         ),
                         children: [
                            if (market.promos.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: SizedBox(
                                    height: 160,
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

                            // 1. Categories
                            const SizedBox(height: 32),
                            _sectionHeader(locale.t('categories'), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const DepartmentsView()),
                              );
                            }),
                            const SizedBox(height: 16),
                            _buildCategories(context, market.categories),

                            // 2. Top Stores
                            const SizedBox(height: 32),
                            _sectionHeader(locale.t('top_stores'), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const StoresListView()),
                              );
                            }),
                            const SizedBox(height: 16),
                            _buildTopStores(context, market),

                            // 3. New Arrivals
                            const SizedBox(height: 32),
                            _sectionHeader(locale.t('new_arrivals'), () {}),
                            const SizedBox(height: 16),
                            _buildNewArrivals(context, market),

                            // 4. Featured Products
                            const SizedBox(height: 32),
                            _sectionHeader(locale.t('featured'), () {}),
                            const SizedBox(height: 16),
                            _buildFeatured(context, market),

                             // 5. Real Estate Section
                             const SizedBox(height: 32),
                             _sectionHeader('🏠 Guri & Dhul', () {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(builder: (_) => const PropertyListingsView()),
                               );
                             }),
                             const SizedBox(height: 16),
                             _buildRealEstateQuickAccess(context),

                             // 6. Second Hand Section
                             const SizedBox(height: 32),
                             _sectionHeader('♻️ Suuqa Casriga', () {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(builder: (_) => const SecondHandView()),
                               );
                             }),
                             const SizedBox(height: 16),
                             _buildSecondHandBanner(context),

                             // 7. Farsamo Yaqaano
                             const SizedBox(height: 32),
                             _sectionHeader('🔧 Farsamo Yaqaano', () {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(builder: (_) => const TechniciansView()),
                               );
                             }),
                             const SizedBox(height: 16),
                             _buildTechniciansBanner(context),
                         ],
                       ),
                     ),
                   ),
                ],

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSkeleton(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 160, margin: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
          const SizedBox(height: 32),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Container(height: 20, width: 150, color: Colors.white)),
          const SizedBox(height: 16),
          SizedBox(height: 180, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: 3, itemBuilder: (_, __) => Container(width: 250, margin: const EdgeInsets.only(right: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))))),
          const SizedBox(height: 32),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Container(height: 20, width: 120, color: Colors.white)),
          const SizedBox(height: 16),
          SizedBox(height: 80, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: 5, itemBuilder: (_, __) => Container(width: 70, margin: const EdgeInsets.only(right: 16), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)))),
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
            width: 42,
            height: 42,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_outlined,
                color: AppColors.primary, size: 20),
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                color: AppColors.primary, size: 20),
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
    final locale = Provider.of<LocaleProvider>(context);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFF2563EB)],
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
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          Text(AppStrings.translateData(b.title, locale.language),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.1)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              b.btnText.isEmpty ? 'Hadda iibso' : b.btnText,
              style: const TextStyle(
                  color: Color(0xFF1A3A2F),
                  fontWeight: FontWeight.w800,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context, List<Category> categories) {
    final locale = Provider.of<LocaleProvider>(context);
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
      height: 90,
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
              width: 70,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      categories.isNotEmpty
                          ? _getIcon(categories[i].icon)
                          : icons[i % icons.length],
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.translateData(name, locale.language),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
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
    final locale = Provider.of<LocaleProvider>(context);
    final stores = market.stores.where((s) => s.isApproved).take(5).toList();
    if (stores.isEmpty) return _emptyState(locale.t('no_stores'));
    return SizedBox(
      height: 90,
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
                        ? Image.network(s.logo, width: 48, height: 48, fit: BoxFit.cover)
                        : Container(width: 48, height: 48, color: AppColors.primary.withValues(alpha: 0.15), child: const Icon(Icons.store_rounded, color: AppColors.primary)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppStrings.translateData(s.name, locale.language), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5)),
                        Row(children: [
                           const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFB800)),
                           Text(' ${s.rating.toStringAsFixed(1)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                        ]),
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
    final locale = Provider.of<LocaleProvider>(context);
    if (prods.isEmpty) return _emptyState(locale.t('no_items'));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.85, // Even smaller
        ),
        itemCount: prods.length,
        itemBuilder: (_, i) => ProductCard(
          compact: true,
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
    final prods = market.products.where((p) => p.isApproved).toList().reversed.take(6).toList();
    final locale = Provider.of<LocaleProvider>(context);
    if (prods.isEmpty) return _emptyState(locale.t('no_items'));
    return SizedBox(
      height: 180, // Even smaller height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: prods.length,
        itemBuilder: (_, i) {
          final p = prods[i];
          return Padding(
            padding: const EdgeInsets.only(right: 14),
            child: SizedBox(
               width: 140, // Narrower
               child: ProductCard(
                  compact: true,
                  product: p,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProductDetailsView(product: p)),
                  ),
                  onAddToCart: () => market.addToCart(p, 1),
               ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRealEstateQuickAccess(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PropertyListingsView(initialTab: 0)),
              ),
              child: Container(
                height: 110,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.vpn_key_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(height: 10),
                    const Text('Kireysi',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15)),
                    const Text('Guryaha & Dhulalka',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PropertyListingsView(initialTab: 1)),
              ),
              child: Container(
                height: 110,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C1B1B), Color(0xFFEF4444)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.sell_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(height: 10),
                    const Text('Iibsi',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15)),
                    const Text('Guryaha & Dhulalka',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondHandBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SecondHandView()),
        ),
        child: Container(
          height: 110,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('CUSUB', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ),
                    const SizedBox(height: 8),
                    const Text('Suuqa Casriga ah',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16)),
                    const SizedBox(height: 2),
                    const Text('Iibso ama iibi alaabta lasoo isticmaalay',
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechniciansBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TechniciansView()),
        ),
        child: Container(
          height: 110,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEab308), Color(0xFFCa8a04)], // Yellow/Orange mix
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEab308).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('XIRFADO', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ),
                    const SizedBox(height: 8),
                    const Text('Farsamo Yaqaano',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16)),
                    const SizedBox(height: 2),
                    const Text('AC, Koronto, Qasaalad iyo in kale',
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.handyman_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _sectionHeader(String title, VoidCallback onSeeAll) {
    final locale = Provider.of<LocaleProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimaryLight,
                  letterSpacing: -0.4)),
          GestureDetector(
            onTap: onSeeAll,
            child: Text(locale.t('see_all'),
                style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5)),
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
