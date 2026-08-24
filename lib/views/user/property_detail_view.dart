import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/property_listing.dart';
import '../../models/property_booking.dart';
import '../../models/order.dart'; // For PaymentMethod
import '../../providers/marketplace_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/colors.dart';
import '../../core/services/supabase_service.dart';
import '../../core/widgets/video_player_widget.dart';

class PropertyDetailView extends StatefulWidget {
  final PropertyListing listing;
  const PropertyDetailView({super.key, required this.listing});

  @override
  State<PropertyDetailView> createState() => _PropertyDetailViewState();
}

class _PropertyDetailViewState extends State<PropertyDetailView> {
  int _activeImage = 0;
  final PageController _pageCtrl = PageController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _callPhone(BuildContext context) async {
    final phone = widget.listing.ownerPhone;
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telefoon lama dhisin xayeysiiskan')),
      );
      return;
    }
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final phone = widget.listing.ownerPhone.replaceAll(RegExp(r'[^\d+]'), '');
    if (phone.isEmpty) return;
    final url = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.listing;
    final images = p.images.isNotEmpty ? p.images : <String>[];
    final isRent = p.listingType == PropertyListingType.rent;

    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Image AppBar ─────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 320,
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
              background: (images.isNotEmpty || (p.videoUrl != null && p.videoUrl!.isNotEmpty))
                  ? Stack(
                      children: [
                        PageView.builder(
                          controller: _pageCtrl,
                          itemCount: (p.videoUrl != null && p.videoUrl!.isNotEmpty ? 1 : 0) + images.length,
                          onPageChanged: (i) => setState(() => _activeImage = i),
                          itemBuilder: (_, i) {
                            final hasVideo = p.videoUrl != null && p.videoUrl!.isNotEmpty;
                            if (hasVideo && i == 0) {
                              return SafeArea(
                                child: Container(
                                  color: Colors.black,
                                  alignment: Alignment.center,
                                  child: VideoPlayerWidget(url: p.videoUrl!),
                                ),
                              );
                            }
                            final imageIndex = hasVideo ? i - 1 : i;
                            return Image.network(
                              images[imageIndex],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => _imgPlaceholder(p),
                            );
                          },
                        ),
                        // Gradient overlay
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF1F2937).withValues(alpha: 0.8)
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Page dots
                        if (images.length > 1)
                          Positioned(
                            bottom: 14,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                (p.videoUrl != null && p.videoUrl!.isNotEmpty ? 1 : 0) + images.length,
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
                  : _imgPlaceholder(p),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges row
                  Row(
                    children: [
                      _badge(
                        isRent ? 'KIREYSI' : 'IIBSI',
                        isRent ? const Color(0xFF3B82F6) : const Color(0xFFEF4444),
                        isRent ? Icons.vpn_key_rounded : Icons.sell_rounded,
                      ),
                      const SizedBox(width: 8),
                      _badge(
                        p.propertyTypeLabel.toUpperCase(),
                        const Color(0xFF64748B),
                        Icons.home_work_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(p.title,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1F2937),
                          height: 1.2)),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(p.location,
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Price card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00AA5B), Color(0xFF00D285)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00AA5B).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isRent ? 'Kirada Bil kasta' : 'Qiimaha Iibka',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p.formattedPrice + (isRent ? '/bil' : ''),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    height: 1),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            p.currency,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats row
                  Row(
                    children: [
                      if (p.areaSqm > 0)
                        Expanded(
                          child: _statBox(Icons.square_foot_rounded,
                              '${p.areaSqm.toStringAsFixed(0)} m²', 'Qiyaas'),
                        ),
                      if (p.bedrooms > 0) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statBox(Icons.bed_rounded, '${p.bedrooms}', 'Qol'),
                        ),
                      ],
                      if (p.bathrooms > 0) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statBox(Icons.bathroom_rounded, '${p.bathrooms}', 'Musqul'),
                        ),
                      ],
                    ],
                  ),

                  // Description
                  if (p.description.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Faahfaahin',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(p.description,
                          style: const TextStyle(
                              fontSize: 15, color: Color(0xFF374151), height: 1.6)),
                    ),
                  ],

                  // Amenities
                  if (p.amenities.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Sifooyin',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: p.amenities
                          .map((a) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppColors.primary.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded,
                                        size: 14, color: AppColors.primary),
                                    const SizedBox(width: 5),
                                    Text(a,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1F2937))),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Contact
                  if (p.ownerName.isNotEmpty) ...[
                    const Text('Xiriir Lala Xiriiro',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
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
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Color(0xFF00AA5B), Color(0xFF00D285)]),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.ownerName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900, fontSize: 15)),
                                if (p.ownerPhone.isNotEmpty)
                                  Text(p.ownerPhone,
                                      style: const TextStyle(
                                          color: Color(0xFF64748B), fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _actionBtn(
                          icon: Icons.call_rounded,
                          label: 'Wac',
                          color: const Color(0xFF1F2937),
                          onTap: () => _callPhone(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _actionBtn(
                          icon: Icons.chat_rounded,
                          label: 'WhatsApp',
                          color: const Color(0xFF25D366),
                          gradient: const LinearGradient(
                              colors: [Color(0xFF25D366), Color(0xFF128C7E)]),
                          onTap: () => _openWhatsApp(context),
                        ),
                      ),
                    ],
                  ),

                  // Carbuno Section
                  if (p.isAvailable) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _showBookingSheet(context, p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B00), Color(0xFFFF9E00)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B00).withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bookmark_added_rounded, color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Carbuno Hantida (Carbun 20%)',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder(PropertyListing p) {
    return Container(
      color: const Color(0xFF1E293B),
      child: Center(
        child: Icon(
          p.propertyType == PropertyType.land
              ? Icons.terrain_rounded
              : Icons.home_work_rounded,
          size: 72,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _badge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _statBox(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1F2937))),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  void _showBookingSheet(BuildContext context, PropertyListing p) {
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
    final deposit = p.price * 0.20;
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
                      'Carbuno Hantidan',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ku sii bixi carbun dhan 20% si lagugu hayo hantida.',
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
                              Text('${p.currency} ${p.price.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                            ],
                          ),
                          const Divider(height: 20, color: Color(0xFFE2E8F0)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text('Carbunta ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6B00))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('20%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFFF6B00))),
                                  ),
                                ],
                              ),
                              Text('${p.currency} ${deposit.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFFF6B00))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Send payment prompt
                    Text(
                      '1. Fadlan lacagta Carbunta u dir Lambarkan:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isEvc ? const Color(0xFFFFF8F2) : const Color(0xFFF2F7FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isEvc ? const Color(0xFFFFDAB9) : const Color(0xFFBDD7FF),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEvc ? 'EVC Plus: $payNum' : 'eDahab: $payNum',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isEvc ? const Color(0xFFD35400) : const Color(0xFF1E3A8A),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(sheetCtx).showSnackBar(
                                const SnackBar(content: Text('Lambar waa la koobiyeeyay!'), duration: Duration(seconds: 1)),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            color: isEvc ? const Color(0xFFD35400) : const Color(0xFF1E3A8A),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Choice of payment methods
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setSheetState(() => method = PaymentMethod.evcPlus);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isEvc ? const Color(0xFFFF6B00) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'EVC Plus',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isEvc ? Colors.white : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setSheetState(() => method = PaymentMethod.edahab);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: !isEvc ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'eDahab',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: !isEvc ? Colors.white : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Inputs for verify
                    Text(
                      '2. Ku qor magacaaga iyo moobilka aad lacagta ka dirtay:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 10),

                    // Name Field
                    TextFormField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Magaca Diriqa',
                        prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Fadlan qor magacaaga' : null,
                    ),
                    const SizedBox(height: 12),

                    // Sender mobile
                    TextFormField(
                      controller: transPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Moobilka Lacagta Kasoo Dirtay',
                        prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Fadlan qor moobilkaaga' : null,
                    ),
                    const SizedBox(height: 24),

                    // Submit booking
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isBooking
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setSheetState(() => isBooking = true);

                                try {
                                  final booking = PropertyBooking(
                                    id: const Uuid().v4(),
                                    propertyId: p.id,
                                    propertyTitle: p.title,
                                    propertyType: p.propertyType,
                                    listingType: p.listingType,
                                    userId: auth.currentUser!.id,
                                    userName: nameCtrl.text.trim(),
                                    userPhone: auth.currentUser!.phone ?? '',
                                    totalPrice: p.price,
                                    depositAmount: deposit,
                                    currency: p.currency,
                                    paymentMethod: method,
                                    transactionPhone: transPhoneCtrl.text.trim(),
                                    status: BookingStatus.pending,
                                    createdAt: DateTime.now(),
                                  );

                                  await market.addPropertyBooking(booking);

                                  // Guriga calaamadee "Waa La Carbuntay"
                                  await SupabaseService.upsertPropertyListing(
                                    p.copyWith(isReserved: true),
                                  );

                                  // Provider fresh data
                                  if (context.mounted) {
                                    await market.refresh();
                                  }

                                  // Pop sheet
                                  if (sheetCtx.mounted) {
                                    Navigator.pop(sheetCtx);
                                  }

                                  // Show Success dialog
                                  if (context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        title: const Row(
                                          children: [
                                            Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 28),
                                            SizedBox(width: 10),
                                            Text('Guul!', style: TextStyle(fontWeight: FontWeight.w900)),
                                          ],
                                        ),
                                        content: const Text(
                                          'Carbuntao-daada waa la diiwaangeliyay!\n\nAdmin ayaa xaqiijin doona lacagta dhigashada ee carbunta, ka dibna wuu ansixin doonaa.',
                                          style: TextStyle(fontSize: 14, height: 1.5),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Hagaag', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (sheetCtx.mounted) {
                                    ScaffoldMessenger.of(sheetCtx).showSnackBar(
                                      SnackBar(content: Text('Khalad: $e'), backgroundColor: Colors.red),
                                    );
                                  }
                                } finally {
                                  setSheetState(() => isBooking = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B00),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: isBooking
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Diri Carbunta',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    LinearGradient? gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: gradient == null ? color : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
