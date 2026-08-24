import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/cargo_ad.dart';
import '../../core/services/upload_service.dart';

class AdminCargoAdsView extends StatefulWidget {
  const AdminCargoAdsView({super.key});

  @override
  State<AdminCargoAdsView> createState() => _AdminCargoAdsViewState();
}

class _AdminCargoAdsViewState extends State<AdminCargoAdsView> {
  final _titleCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  Future<void> _pickImage() async {
    final url = await UploadService.pickAndUploadImage();
    if (url != null) setState(() => _imageCtrl.text = url);
  }

  Future<void> _addAd() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final market = Provider.of<MarketplaceProvider>(context, listen: false);
    final ad = CargoAd(
      id: const Uuid().v4(),
      title: title,
      imageUrl: _imageCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      createdAt: DateTime.now(),
    );
    await market.addCargoAd(ad);
    if (mounted) {
      _titleCtrl.clear();
      _imageCtrl.clear();
      _descCtrl.clear();
      _phoneCtrl.clear();
      Navigator.pop(context);
    }
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Xayeysiis cusub ku dar',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
            const SizedBox(height: 20),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'Cinwaan (Title)',
                hintText: 'China to Somalia — qiimo jaban',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                prefixIcon: const Icon(Icons.title_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _imageCtrl,
              decoration: InputDecoration(
                labelText: 'Image URL',
                hintText: 'https://...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                prefixIcon: const Icon(Icons.image_outlined),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.upload_rounded, color: Color(0xFF00AA5B)),
                  onPressed: _pickImage,
                  tooltip: 'Upload sawir',
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Faahfaahin (Description)',
                hintText: 'Xayeysiiskaan wuxuu ku saabsan yahay...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                prefixIcon: const Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'WhatsApp Telefoon',
                hintText: '+252 61 XXX XXXX',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                prefixIcon: const Icon(Icons.phone_rounded),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addAd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Ku Dar', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AA5B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final ads = market.cargoAds;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Cargo Xayeysiisyada',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1F2937))),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        backgroundColor: const Color(0xFF00AA5B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Xayeysiis Cusub', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ads.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                    child: const Icon(Icons.flight_rounded, size: 50, color: Color(0xFFCBD5E1)),
                  ),
                  const SizedBox(height: 16),
                  const Text('Xayeysiis ma jiro', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  const Text('Ku dar xayeysiis cusub oo cargo ah', style: TextStyle(color: Color(0xFFCBD5E1))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: ads.length,
              itemBuilder: (_, i) {
                final ad = ads[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ad.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(
                            ad.imageUrl,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 100, color: const Color(0xFFF1F5F9),
                              child: const Center(child: Icon(Icons.broken_image_rounded, color: Color(0xFFCBD5E1), size: 40)),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ad.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1F2937))),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${ad.createdAt.day}/${ad.createdAt.month}/${ad.createdAt.year}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _confirmDelete(context, market, ad),
                              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                              tooltip: 'Tirtir',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _confirmDelete(BuildContext ctx, MarketplaceProvider market, CargoAd ad) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xayeysiiska Tirtir?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Ma hubtaa inaad tirtirayso "${ad.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Maya')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await market.removeCargoAd(ad.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            child: const Text('Tirtir'),
          ),
        ],
      ),
    );
  }
}
