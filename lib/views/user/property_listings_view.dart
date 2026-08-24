import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/property_listing.dart';
import '../../providers/marketplace_provider.dart';
import '../../core/constants/colors.dart';
import 'property_detail_view.dart';
import 'add_property_view.dart';

class PropertyListingsView extends StatefulWidget {
  final int initialTab; // 0 = rent, 1 = sale
  const PropertyListingsView({super.key, this.initialTab = 0});

  @override
  State<PropertyListingsView> createState() => _PropertyListingsViewState();
}

class _PropertyListingsViewState extends State<PropertyListingsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _search = '';
  PropertyType? _filterType;

  final _currencies = ['Dhami', 'USD', 'SOS', 'ETB', 'AED', 'SAR'];
  String? _filterCurrency;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<PropertyListing> _filter(List<PropertyListing> list) {
    var result = list;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      result = result
          .where((p) =>
              p.title.toLowerCase().contains(q) ||
              p.location.toLowerCase().contains(q))
          .toList();
    }
    if (_filterType != null) {
      result = result.where((p) => p.propertyType == _filterType).toList();
    }
    if (_filterCurrency != null && _filterCurrency != 'Dhami') {
      result = result.where((p) => p.currency == _filterCurrency).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final rentals = _filter(market.rentalListings);
    final sales = _filter(market.saleListings);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const SizedBox.shrink(),
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00AA5B), Color(0xFF00D285)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Guri & Dhul',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1F2937))),
                    Text('Kireeyso ama Iibso',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
            actions: const [],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(108),
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              onChanged: (v) => setState(() => _search = v),
                              decoration: const InputDecoration(
                                hintText: 'Raadi guri, dhul, location...',
                                hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                prefixIcon: Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _filterButton(context),
                      ],
                    ),
                  ),
                  // Tabs
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: const Color(0xFF94A3B8),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.vpn_key_rounded, size: 16),
                              SizedBox(width: 6),
                              Text('Kireysi'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sell_rounded, size: 16),
                              SizedBox(width: 6),
                              Text('Iibsi'),
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
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildList(context, rentals, isRental: true),
            _buildList(context, sales, isRental: false),
          ],
        ),
      ),
    );
  }

  Widget _filterButton(BuildContext context) {
    final hasFilter = _filterType != null ||
        (_filterCurrency != null && _filterCurrency != 'Dhami');
    return GestureDetector(
      onTap: () => _showFilterSheet(context),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: hasFilter ? AppColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.tune_rounded,
            color: hasFilter ? Colors.white : const Color(0xFF94A3B8), size: 20),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Shaandheynta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              const Text('Nooca Hantida', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: PropertyType.values.map((t) {
                    final selected = _filterType == t;
                    return GestureDetector(
                      onTap: () {
                        setSheetState(() {});
                        setState(() => _filterType = selected ? null : t);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _typeLabel(t),
                          style: TextStyle(
                              color: selected ? Colors.white : const Color(0xFF374151),
                              fontWeight: FontWeight.w700,
                              fontSize: 13),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Lacagta', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _currencies.map((c) {
                    final selected = _filterCurrency == c;
                    return GestureDetector(
                      onTap: () {
                        setSheetState(() {});
                        setState(
                            () => _filterCurrency = selected ? null : c);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF3B82F6) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          c,
                          style: TextStyle(
                              color: selected ? Colors.white : const Color(0xFF374151),
                              fontWeight: FontWeight.w700,
                              fontSize: 13),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filterType = null;
                      _filterCurrency = null;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF374151),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Saafi Geli', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _typeLabel(PropertyType t) {
    switch (t) {
      case PropertyType.house:
        return 'Guri';
      case PropertyType.apartment:
        return 'Apartment';
      case PropertyType.land:
        return 'Dhul';
      case PropertyType.villa:
        return 'Villa';
      case PropertyType.shop:
        return 'Dukaanka';
    }
  }

  Widget _buildList(BuildContext context, List<PropertyListing> listings, {required bool isRental}) {
    if (listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isRental ? Icons.vpn_key_rounded : Icons.sell_rounded,
                size: 36,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isRental ? 'Hantida kiraynta\nmadhan tahay' : 'Hantida iibka\nmadhan tahay',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),
            const Text('Ku dar hantidaada iyadoo aad gujineyso + Ku Dar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => Provider.of<MarketplaceProvider>(context, listen: false).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: listings.length,
        itemBuilder: (_, i) => _propertyCard(context, listings[i]),
      ),
    );
  }

  Widget _propertyCard(BuildContext context, PropertyListing p) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PropertyDetailView(listing: p)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: p.primaryImage.isNotEmpty
                      ? Image.network(
                          p.primaryImage,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(p),
                        )
                      : _imagePlaceholder(p),
                ),
                // Type badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: p.listingType == PropertyListingType.rent
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      p.listingTypeLabel.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ),
                ),
                // Property type
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      p.propertyTypeLabel,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                // Price chip
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF00AA5B), Color(0xFF00D285)]),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00AA5B).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      p.formattedPrice + (p.listingType == PropertyListingType.rent ? '/bil' : ''),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(p.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (p.areaSqm > 0) ...[
                        _infoChip(Icons.square_foot_rounded, '${p.areaSqm.toStringAsFixed(0)} m²'),
                        const SizedBox(width: 8),
                      ],
                      if (p.bedrooms > 0) ...[
                        _infoChip(Icons.bed_rounded, '${p.bedrooms} Qol'),
                        const SizedBox(width: 8),
                      ],
                      if (p.bathrooms > 0)
                        _infoChip(Icons.bathroom_rounded, '${p.bathrooms} Musqul'),
                      const Spacer(),
                      // Currency badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(p.currency,
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF374151))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(PropertyListing p) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: p.listingType == PropertyListingType.rent
              ? [const Color(0xFF1E3A5F), const Color(0xFF2563EB)]
              : [const Color(0xFF1A1A2E), const Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Icon(
        p.propertyType == PropertyType.land
            ? Icons.terrain_rounded
            : Icons.home_work_rounded,
        size: 60,
        color: Colors.white.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
        ],
      ),
    );
  }
}
