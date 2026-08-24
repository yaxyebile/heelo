import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/property_listing.dart';
import '../user/property_detail_view.dart';
import '../user/add_property_view.dart';

class AdminPropertyListingsView extends StatefulWidget {
  const AdminPropertyListingsView({super.key});

  @override
  State<AdminPropertyListingsView> createState() => _AdminPropertyListingsViewState();
}

class _AdminPropertyListingsViewState extends State<AdminPropertyListingsView> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _approve(BuildContext context, MarketplaceProvider market, PropertyListing p) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await market.approvePropertyListing(p.id);
      messenger.showSnackBar(
        SnackBar(
          content: Text('"${p.title}" waa la ansixiyay!'),
          backgroundColor: const Color(0xFF00AA5B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Khalad: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _delete(BuildContext context, MarketplaceProvider market, PropertyListing p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ma hubtaa?', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
        content: Text('Ma hubtaa inaad tirtirayso xayeysiiska "${p.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Maya')),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Tirtir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      try {
        await market.removePropertyListing(p.id);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Xayeysiiska waa la tirtiray!'),
            backgroundColor: Color(0xFF1F2937),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (context.mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text('Khalad: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final allListings = market.allPropertyListings;

    final pending = allListings.where((p) => !p.isApproved).toList();
    final approved = allListings.where((p) => p.isApproved).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1F2937)),
          ),
        ),
        title: const Text('Maamulka Guryaha & Dhulka',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFFFF6B00),
          labelColor: const Color(0xFFFF6B00),
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: [
            Tab(text: 'Sugaya Ansixin (${pending.length})'),
            Tab(text: 'La Ansixiyay (${approved.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPropertyView()),
          );
        },
        backgroundColor: const Color(0xFF00AA5B),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Ku Dar Hanti', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildList(context, market, pending, isPending: true),
          _buildList(context, market, approved, isPending: false),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    MarketplaceProvider market,
    List<PropertyListing> listings, {
    required bool isPending,
  }) {
    if (listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Icon(
                isPending ? Icons.pending_actions_rounded : Icons.home_work_rounded,
                size: 64,
                color: const Color(0xFFCBD5E1),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isPending ? 'Ma jiraan guryo sugaya ansixin' : 'Ma jiraan guryo la ansixiyay',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 6),
            Text(
              isPending
                  ? 'Guryaha dadku soo galiyaan halkan ayay ku soo dhacayaan'
                  : 'Guryaha la ansixiyay ee suuqaba ka muuqda halkan ayay ku jiraan',
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: listings.length,
      itemBuilder: (_, i) {
        final p = listings[i];
        final isRent = p.listingType == PropertyListingType.rent;
        final hasImage = p.images.isNotEmpty;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Image + Type tag
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: hasImage
                          ? Image.network(
                              p.images.first,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imagePlaceholder(p),
                            )
                          : _imagePlaceholder(p),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isRent ? const Color(0xFF3B82F6) : const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isRent ? 'KIREYSI' : 'IIBSI',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          p.propertyTypeLabel.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),

                // Content details
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1F2937)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFFFF6B00)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        p.location,
                                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                p.formattedPrice,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF00AA5B)),
                              ),
                              if (isRent)
                                const Text(
                                  '/bil kasta',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                ),
                            ],
                          ),
                        ],
                      ),

                      // User/Owner details
                      const SizedBox(height: 14),
                      Divider(color: Colors.grey.shade200, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: const Color(0xFFF1F5F9),
                            child: const Icon(Icons.person_rounded, size: 14, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.ownerName.isNotEmpty ? p.ownerName : 'Lama sheegin',
                                  style: const TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (p.ownerPhone.isNotEmpty)
                                  Text(
                                    p.ownerPhone,
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            timeAgo(p.createdAt),
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),

                      // Control buttons
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => PropertyDetailView(listing: p)),
                                );
                              },
                              icon: const Icon(Icons.visibility_rounded, size: 16),
                              label: const Text('Eeg'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF64748B),
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isPending) ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _approve(context, market, p),
                                icon: const Icon(Icons.check_rounded, size: 16),
                                label: const Text('Ansixi'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00AA5B),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          IconButton(
                            onPressed: () => _delete(context, market, p),
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFFEF2F2),
                              padding: const EdgeInsets.all(12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
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
      },
    );
  }

  Widget _imagePlaceholder(PropertyListing p) {
    return Container(
      height: 160,
      width: double.infinity,
      color: const Color(0xFFECEFF1),
      child: Center(
        child: Icon(
          p.propertyType == PropertyType.land ? Icons.terrain_rounded : Icons.home_work_rounded,
          size: 48,
          color: const Color(0xFFB0BEC5),
        ),
      ),
    );
  }

  String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays} maalin ka hor';
    if (diff.inHours > 0) return '${diff.inHours} saac ka hor';
    if (diff.inMinutes > 0) return '${diff.inMinutes} daqiiqo ka hor';
    return 'Hadda';
  }
}
