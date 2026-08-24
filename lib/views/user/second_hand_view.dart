import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/second_hand_item.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_role.dart';
import '../../models/order.dart';
import '../../models/property_booking.dart';
import '../../models/second_hand_booking.dart';
import '../../core/constants/colors.dart';
import '../../core/services/supabase_service.dart';
import '../../core/widgets/video_player_widget.dart';
import 'second_hand_post_view.dart';
import 'package:uuid/uuid.dart';

// ─── Category ikon + midab ─────────────────────────────────────────────────
const _catColors = {
  SecondHandCategory.electronics: Color(0xFF2563EB),
  SecondHandCategory.clothing:    Color(0xFF2563EB),
  SecondHandCategory.furniture:   Color(0xFF92400E),
  SecondHandCategory.vehicles:    Color(0xFF1F2937),
  SecondHandCategory.sports:      Color(0xFF059669),
  SecondHandCategory.books:       Color(0xFFB45309),
  SecondHandCategory.appliances:  Color(0xFFDB2777),
  SecondHandCategory.other:       Color(0xFF64748B),
};

const _catIcons = {
  SecondHandCategory.electronics: Icons.phone_android_rounded,
  SecondHandCategory.clothing:    Icons.checkroom_rounded,
  SecondHandCategory.furniture:   Icons.chair_rounded,
  SecondHandCategory.vehicles:    Icons.directions_car_rounded,
  SecondHandCategory.sports:      Icons.sports_soccer_rounded,
  SecondHandCategory.books:       Icons.menu_book_rounded,
  SecondHandCategory.appliances:  Icons.kitchen_rounded,
  SecondHandCategory.other:       Icons.category_rounded,
};

// ─── Main Listings View ─────────────────────────────────────────────────────
class SecondHandView extends StatefulWidget {
  const SecondHandView({super.key});

  @override
  State<SecondHandView> createState() => _SecondHandViewState();
}

class _SecondHandViewState extends State<SecondHandView> {
  SecondHandCategory? _selectedCat;
  String _search = '';

  List<SecondHandItem> _filter(List<SecondHandItem> all) {
    var res = all;
    if (_selectedCat != null) {
      res = res.where((i) => i.category == _selectedCat).toList();
    }
    if (_search.trim().isNotEmpty) {
      final q = _search.toLowerCase();
      res = res
          .where((i) =>
              i.title.toLowerCase().contains(q) ||
              i.location.toLowerCase().contains(q) ||
              i.categoryLabel.toLowerCase().contains(q))
          .toList();
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final auth   = Provider.of<AuthProvider>(context);
    final items  = _filter(market.secondHandItems);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Suuqa Casriga',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                    Text('Alaabta La Isticmaalay',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
            actions: [
              if (auth.isAuthenticated && auth.currentUser?.role == UserRole.admin)
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SecondHandPostView()));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF3B82F6)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('Iibi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(110),
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: (v) => setState(() => _search = v),
                        decoration: const InputDecoration(
                          hintText: 'Raadi alaab...',
                          hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                          prefixIcon: Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  // Category chips
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      children: [
                        _catChip(null, Icons.apps_rounded, 'Dhammaan'),
                        ...SecondHandCategory.values.map((c) =>
                          _catChip(c, _catIcons[c]!, _shortLabel(c))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: items.isEmpty
            ? _emptyState()
            : RefreshIndicator(
                color: const Color(0xFF2563EB),
                onRefresh: () => Provider.of<MarketplaceProvider>(context, listen: false).refresh(),
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.74,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _itemCard(context, items[i]),
                ),
              ),
      ),
    );
  }

  Widget _catChip(SecondHandCategory? cat, IconData icon, String label) {
    final selected = _selectedCat == cat;
    final color = cat != null ? _catColors[cat]! : const Color(0xFF2563EB);
    return GestureDetector(
      onTap: () => setState(() => _selectedCat = selected ? null : cat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: selected ? Colors.white : const Color(0xFF64748B)),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : const Color(0xFF64748B),
                )),
          ],
        ),
      ),
    );
  }

  Widget _itemCard(BuildContext context, SecondHandItem item) {
    final catColor = _catColors[item.category] ?? const Color(0xFF64748B);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SecondHandDetailView(item: item)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                children: [
                  item.primaryImage.isNotEmpty
                      ? Image.network(item.primaryImage,
                          height: 140, width: double.infinity, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(item, catColor))
                      : _placeholder(item, catColor),
                  // Category badge
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: catColor, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        item.categoryLabel,
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  // Condition badge
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.conditionLabel,
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1F2937))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 11, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(item.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.formattedPrice,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: catColor,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(SecondHandItem item, Color color) {
    return Container(
      height: 140,
      width: double.infinity,
      color: color.withValues(alpha: 0.1),
      child: Icon(_catIcons[item.category] ?? Icons.category_rounded, size: 48, color: color.withValues(alpha: 0.4)),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.swap_horiz_rounded, size: 36, color: Color(0xFF2563EB)),
          ),
          const SizedBox(height: 16),
          const Text('Wax alaab ah lama helin',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
          const SizedBox(height: 8),
          const Text('Riix "+ Iibi" si aad u soo geliso alaabta aad iibineyso',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  String _shortLabel(SecondHandCategory c) {
    switch (c) {
      case SecondHandCategory.electronics: return 'Tignool.';
      case SecondHandCategory.clothing:    return 'Dharka';
      case SecondHandCategory.furniture:   return 'Alaab';
      case SecondHandCategory.vehicles:    return 'Gaadhi';
      case SecondHandCategory.sports:      return 'Cayaar';
      case SecondHandCategory.books:       return 'Buugag';
      case SecondHandCategory.appliances:  return 'Mishiin';
      case SecondHandCategory.other:       return 'Kale';
    }
  }
}

// ─── Detail View ────────────────────────────────────────────────────────────
class SecondHandDetailView extends StatefulWidget {
  final SecondHandItem item;
  const SecondHandDetailView({super.key, required this.item});

  @override
  State<SecondHandDetailView> createState() => _SecondHandDetailViewState();
}

class _SecondHandDetailViewState extends State<SecondHandDetailView> {
  int _activeImage = 0;
  final PageController _pageCtrl = PageController();

  Future<void> _call(BuildContext context) async {
    if (widget.item.sellerPhone.isEmpty) return;
    final url = Uri.parse('tel:${widget.item.sellerPhone}');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _whatsapp(BuildContext context) async {
    final phone = widget.item.sellerPhone.replaceAll(RegExp(r'[^\d+]'), '');
    if (phone.isEmpty) return;
    final url = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final catColor = _catColors[item.category] ?? const Color(0xFF64748B);
    final images = item.images;

    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF1F2937),
            foregroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: (images.isNotEmpty || (item.videoUrl != null && item.videoUrl!.isNotEmpty))
                  ? Stack(
                      children: [
                        PageView.builder(
                          controller: _pageCtrl,
                          itemCount: (item.videoUrl != null && item.videoUrl!.isNotEmpty ? 1 : 0) + images.length,
                          onPageChanged: (i) => setState(() => _activeImage = i),
                          itemBuilder: (_, i) {
                            final hasVideo = item.videoUrl != null && item.videoUrl!.isNotEmpty;
                            if (hasVideo && i == 0) {
                              return SafeArea(
                                child: Container(
                                  color: Colors.black,
                                  alignment: Alignment.center,
                                  child: VideoPlayerWidget(url: item.videoUrl!),
                                ),
                              );
                            }
                            final imageIndex = hasVideo ? i - 1 : i;
                            return Image.network(
                              images[imageIndex],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => Container(
                                color: catColor.withValues(alpha: 0.15),
                                child: Icon(_catIcons[item.category], size: 80, color: catColor.withValues(alpha: 0.4)),
                              ),
                            );
                          },
                        ),
                        // Page dots
                        if ((item.videoUrl != null && item.videoUrl!.isNotEmpty ? 1 : 0) + images.length > 1)
                          Positioned(
                            bottom: 14,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                (item.videoUrl != null && item.videoUrl!.isNotEmpty ? 1 : 0) + images.length,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: i == _activeImage ? 18 : 6,
                                  height: 6,
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  decoration: BoxDecoration(
                                    color: i == _activeImage
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      color: catColor.withValues(alpha: 0.15),
                      child: Icon(_catIcons[item.category], size: 80, color: catColor.withValues(alpha: 0.4)),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Row(
                    children: [
                      _badge(item.categoryLabel, catColor),
                      const SizedBox(width: 8),
                      _badge(item.conditionLabel, const Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      _badge(
                        item.inStock ? 'Stock: ${item.stock}' : 'Dhamaaday',
                        item.inStock ? const Color(0xFF059669) : const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(item.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(item.location,
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Price card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [catColor, catColor.withValues(alpha: 0.7)]),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(color: catColor.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Qiimaha Iibka', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(item.formattedPrice,
                                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(item.currency,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  if (item.description.isNotEmpty) ...[
                    const Text('Faahfaahin', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(item.description,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF374151), height: 1.6)),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Seller info
                  if (item.sellerName.isNotEmpty) ...[
                    const Text('Iibiyaha Xiriirso', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [catColor, catColor.withValues(alpha: 0.7)]),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.sellerName,
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                                if (item.sellerPhone.isNotEmpty)
                                  Text(item.sellerPhone,
                                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Contact buttons
                  Row(
                    children: [
                      Expanded(
                        child: _contactBtn(Icons.call_rounded, 'Wac', const Color(0xFF1F2937), null,
                            () => _call(context)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _contactBtn(Icons.chat_rounded, 'WhatsApp', const Color(0xFF25D366),
                            const LinearGradient(colors: [Color(0xFF25D366), Color(0xFF128C7E)]),
                            () => _whatsapp(context)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!item.inStock)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.remove_shopping_cart_rounded, color: Color(0xFFEF4444), size: 20),
                          SizedBox(width: 8),
                          Text('Alaabtan waa dhamaaday (Out of Stock)',
                              style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w900, fontSize: 14)),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: _contactBtn(
                        Icons.bookmark_border_rounded,
                        'Carbun Dhigo (Deposit 10%)',
                        const Color(0xFF2563EB),
                        const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF3B82F6)]),
                        () => _showBookingSheet(context),
                      ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
    );
  }

  Widget _contactBtn(IconData icon, String label, Color color, LinearGradient? grad, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: grad == null ? color : null,
          gradient: grad,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void _showBookingSheet(BuildContext context) {
    final item = widget.item;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fadlan marka hore gal akoonkaaga si aad u carbunato hantida (Log In).',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final market = Provider.of<MarketplaceProvider>(context, listen: false);
    final deposit = item.price * 0.10; // 10% deposit
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: auth.currentUser?.name ?? '');
    final transPhoneCtrl = TextEditingController(text: auth.currentUser?.phone ?? '');
    PaymentMethod method = PaymentMethod.evcPlus;
    bool isBooking = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          final isEvc = method == PaymentMethod.evcPlus;
          final payNum = isEvc ? market.adminEvc : market.adminEdahab;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header indicator
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sheet Title
                    const Text(
                      'Carbuno Alaabtan',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ku sii bixi carbun dhan 10% si lagugu hayo alaabtan.',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 18),

                    // Summary card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Qiimaha Guud:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                              Text('${item.currency} ${item.price.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                            ],
                          ),
                          const Divider(height: 20, color: Color(0xFFE2E8F0)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Lacagta Carbunta (10%):',
                                  style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${item.currency} ${deposit.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2563EB), fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Payment Method
                    const Text('Qaabka Bixinta', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setSheetState(() => method = PaymentMethod.evcPlus),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isEvc ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text('EVC Plus',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isEvc ? Colors.white : const Color(0xFF64748B),
                                  )),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setSheetState(() => method = PaymentMethod.edahab),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !isEvc ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text('eDahab',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: !isEvc ? Colors.white : const Color(0xFF64748B),
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Payment Instructions
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.amber.shade800, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Fadlan lacagta u dir lambarka:\n$payNum',
                              style: TextStyle(color: Colors.amber.shade900, fontSize: 13, fontWeight: FontWeight.w600, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name Input
                    TextFormField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Magacaaga',
                        prefixIcon: const Icon(Icons.person_rounded, size: 18, color: Color(0xFF2563EB)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Magacaaga ku qor' : null,
                    ),
                    const SizedBox(height: 12),

                    // Phone Input
                    TextFormField(
                      controller: transPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Taleefanka Lacagta Laga Diray',
                        prefixIcon: const Icon(Icons.phone_rounded, size: 18, color: Color(0xFF2563EB)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Taleefanka ku qor' : null,
                    ),
                    const SizedBox(height: 28),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isBooking
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setSheetState(() => isBooking = true);

                                try {
                                  final booking = SecondHandBooking(
                                    id: const Uuid().v4(),
                                    itemId: item.id,
                                    itemTitle: item.title,
                                    userId: auth.currentUser!.id,
                                    userName: nameCtrl.text.trim(),
                                    userPhone: auth.currentUser!.phone ?? '',
                                    totalPrice: item.price,
                                    depositAmount: deposit,
                                    currency: item.currency,
                                    paymentMethod: method,
                                    transactionPhone: transPhoneCtrl.text.trim(),
                                    status: BookingStatus.pending,
                                    createdAt: DateTime.now(),
                                  );

                                  await SupabaseService.upsertSecondHandBooking(booking);
                                  
                                  // Stock-ga kaga jar 1, haddii 0 noqoto status-ka sold dhig
                                  final newStock = item.stock - 1;
                                  final newStatus = newStock <= 0
                                      ? SecondHandStatus.sold
                                      : item.status;
                                  await SupabaseService.upsertSecondHandItem(
                                    item.copyWith(stock: newStock, status: newStatus),
                                  );
                                  
                                  // Provider xogta fresh ka soo qaado
                                  if (context.mounted) {
                                    await Provider.of<MarketplaceProvider>(context, listen: false).refresh();
                                  }

                                  if (sheetCtx.mounted) {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          '✅ Carbuntao-daada waa la diiwaangeliyay!\n\nAlaabtu hadda waxay noqotay: "Waa La Carbuntay". Admin ayaa xaqiijin doona lacagta.',
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 4),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setSheetState(() => isBooking = false);
                                  if (sheetCtx.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Khalad: $e'), backgroundColor: Colors.red),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: isBooking
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Xaqiiji Carbunta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
