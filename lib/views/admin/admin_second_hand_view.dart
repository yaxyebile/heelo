import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/second_hand_item.dart';

class AdminSecondHandView extends StatefulWidget {
  const AdminSecondHandView({super.key});

  @override
  State<AdminSecondHandView> createState() => _AdminSecondHandViewState();
}

class _AdminSecondHandViewState extends State<AdminSecondHandView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _approve(BuildContext context, MarketplaceProvider market, SecondHandItem item) async {
    final ok = await _confirm(context,
        title: 'Ansixi Alaabta',
        msg: 'Ma xaqiijisaa daabacaadda "${item.title}"?',
        okLabel: 'Ansixi',
        okColor: const Color(0xFF00AA5B));
    if (ok == true) {
      if (!context.mounted) return;
      try {
        await market.approveSecondHandItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('"${item.title}" waa la daabacay!'),
          backgroundColor: const Color(0xFF00AA5B),
          behavior: SnackBarBehavior.floating,
        ));
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Khalad: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  Future<void> _reject(BuildContext context, MarketplaceProvider market, SecondHandItem item) async {
    final ok = await _confirm(context,
        title: 'Diid Alaabta',
        msg: 'Ma hubtaa inaad diideyso "${item.title}"?',
        okLabel: 'Diid',
        okColor: Colors.red);
    if (ok == true) {
      if (!context.mounted) return;
      try {
        await market.rejectSecondHandItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Alaabta waa la diiday!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Khalad: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  Future<void> _markSold(BuildContext context, MarketplaceProvider market, SecondHandItem item) async {
    final ok = await _confirm(context,
        title: 'Gali "Waa La Gatay"',
        msg: 'Ma xaqiijisaa in "${item.title}" waa la gatay?',
        okLabel: 'Haa, La Gatay',
        okColor: const Color(0xFF2563EB));
    if (ok == true) {
      if (!context.mounted) return;
      try {
        await market.markSecondHandSold(item.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Waa la gudi waa la calaamadeeyay "La Gatay"!'),
            backgroundColor: Color(0xFF2563EB),
            behavior: SnackBarBehavior.floating,
          ));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Khalad: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  Future<void> _delete(BuildContext context, MarketplaceProvider market, SecondHandItem item) async {
    final ok = await _confirm(context,
        title: 'Tirtir Alaabta',
        msg: 'Ma hubtaa inaad tirtirayso "${item.title}"? Tani waa go\'aan degdeg ah.',
        okLabel: 'Tirtir',
        okColor: Colors.red);
    if (ok == true) {
      if (!context.mounted) return;
      try {
        await market.deleteSecondHandItem(item.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Alaabta waa la tirtiray!'),
            backgroundColor: Color(0xFF1F2937),
            behavior: SnackBarBehavior.floating,
          ));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Khalad: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  Future<bool?> _confirm(BuildContext context, {
    required String title,
    required String msg,
    required String okLabel,
    required Color okColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text(msg, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Maya'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: okColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(okLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final market   = Provider.of<MarketplaceProvider>(context);
    final all      = market.allSecondHandItems;
    final pending  = all.where((i) => i.status == SecondHandStatus.pending).toList();
    final approved = all.where((i) => i.status == SecondHandStatus.approved).toList();
    final reserved = all.where((i) => i.status == SecondHandStatus.reserved).toList();
    final others   = all.where((i) => i.status == SecondHandStatus.sold || i.status == SecondHandStatus.rejected).toList();

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
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1F2937)),
          ),
        ),
        title: const Text('Alaabta Casriga (Second Hand)',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFF2563EB),
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          tabs: [
            Tab(text: 'Sugaya (${pending.length})'),
            Tab(text: 'Live (${approved.length})'),
            Tab(text: '🔒 Carbuntay (${reserved.length})'),
            Tab(text: 'Kale (${others.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildList(context, pending,  market, showApproveReject: true),
          _buildList(context, approved, market, showSold: true),
          _buildList(context, reserved, market, showSold: true),
          _buildList(context, others,   market),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<SecondHandItem> items,
    MarketplaceProvider market, {
    bool showApproveReject = false,
    bool showSold = false,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.swap_horiz_rounded, size: 32, color: Color(0xFF2563EB)),
            ),
            const SizedBox(height: 14),
            const Text('Liis maran', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final item = items[i];

        // Status color
        Color statusColor;
        switch (item.status) {
          case SecondHandStatus.pending:  statusColor = const Color(0xFFB45309); break;
          case SecondHandStatus.approved: statusColor = const Color(0xFF2E7D32); break;
          case SecondHandStatus.reserved: statusColor = const Color(0xFFF97316); break;
          case SecondHandStatus.sold:     statusColor = const Color(0xFF2563EB); break;
          case SecondHandStatus.rejected: statusColor = Colors.red; break;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image + title row
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Row(
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: item.primaryImage.isNotEmpty
                          ? Image.network(item.primaryImage, width: 70, height: 70, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imgPh(item))
                          : _imgPh(item),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF1F2937))),
                          const SizedBox(height: 4),
                          Text('${item.categoryLabel}  •  ${item.conditionLabel}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          const SizedBox(height: 4),
                          Text(item.formattedPrice,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF2563EB))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(item.statusLabel,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: statusColor)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              // Seller info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.person_rounded, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Text('${item.sellerName} • ${item.sellerPhone}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const Spacer(),
                    const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 2),
                    Text(item.location, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              // Action buttons
              if (showApproveReject || showSold) ...[
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Delete always shown
                      IconButton(
                        onPressed: () => _delete(context, market, item),
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                        tooltip: 'Tirtir',
                      ),
                      const Spacer(),
                      if (showApproveReject) ...[
                        OutlinedButton(
                          onPressed: () => _reject(context, market, item),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          child: const Text('Diid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _approve(context, market, item),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00AA5B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            elevation: 0,
                          ),
                          child: const Text('Ansixi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                      if (showSold) ...[
                        ElevatedButton.icon(
                          onPressed: () => _markSold(context, market, item),
                          icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                          label: const Text('Gali "La Gatay"', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _imgPh(SecondHandItem item) {
    return Container(
      width: 70, height: 70,
      color: const Color(0xFF2563EB).withValues(alpha: 0.08),
      child: const Icon(Icons.image_not_supported_rounded, color: Color(0xFF2563EB), size: 28),
    );
  }
}
