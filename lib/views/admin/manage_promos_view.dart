import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/promo_banner.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/services/upload_service.dart';

class ManagePromosView extends StatefulWidget {
  const ManagePromosView({super.key});

  @override
  State<ManagePromosView> createState() => _ManagePromosViewState();
}

class _ManagePromosViewState extends State<ManagePromosView> {
  void _showAddBannerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AddPromoSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Manage Promos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFFFF6B00)),
            onPressed: _showAddBannerModal,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: market.promos.length,
        itemBuilder: (context, index) {
          final p = market.promos[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(p.imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Color(int.parse(p.colorHex)), borderRadius: BorderRadius.circular(6)),
                        child: Text(p.tag, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 4),
                      Text(p.title.replaceAll('\n', ' '), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 16,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 16),
                      padding: EdgeInsets.zero,
                      onPressed: () => market.removePromo(p.id),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AddPromoSheet extends StatefulWidget {
  const _AddPromoSheet();

  @override
  State<_AddPromoSheet> createState() => _AddPromoSheetState();
}

class _AddPromoSheetState extends State<_AddPromoSheet> {
  final _formKey = GlobalKey<FormState>();
  final _urlCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _btnCtrl = TextEditingController();
  final _colorCtrl = TextEditingController(text: "0xFFFF6B00");
  
  bool _isLoading = false;
  String? _imageError;

  Future<void> _validateAndSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _imageError = null;
    });

    try {
      final imgStream = NetworkImage(_urlCtrl.text).resolve(const ImageConfiguration());
      final completer = Completer<ui.Image>();
      final listener = ImageStreamListener((info, _) => completer.complete(info.image), onError: (e, s) => completer.completeError(e));
      
      imgStream.addListener(listener);
      
      final image = await completer.future.timeout(const Duration(seconds: 5));
      imgStream.removeListener(listener);

      // Validate Image Size: We want a wide banner, width > height. E.g. 800x400
      if (image.width < 600 || (image.width / image.height) < 1.5) {
        setState(() {
          _imageError = "Image must be at least 600px wide and have a wide aspect ratio (e.g., 16:9). Size found: ${image.width}x${image.height}";
          _isLoading = false;
        });
        return;
      }

      final market = Provider.of<MarketplaceProvider>(context, listen: false);
      final newPromo = PromoBanner(
        id: const Uuid().v4(),
        imageUrl: _urlCtrl.text,
        title: _titleCtrl.text,
        tag: _tagCtrl.text,
        btnText: _btnCtrl.text,
        colorHex: _colorCtrl.text,
      );

      await market.addPromo(newPromo);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Promo Banner added!"), backgroundColor: Color(0xFF00D285)));
      }

    } catch (e) {
      setState(() {
        _imageError = "Invalid image URL or image could not be loaded.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Add Promo Banner", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              if (_imageError != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_imageError!, style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: "Image URL",
                      hint: "https://example.com/banner.jpg",
                      controller: _urlCtrl,
                      validator: (v) => v!.isEmpty ? "URL required" : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.upload_file, color: Color(0xFFFF6B00)),
                      onPressed: () async {
                        final url = await UploadService.pickAndUploadImage();
                        if (url != null) {
                          setState(() => _urlCtrl.text = url);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Title (use \\n for newline)",
                hint: "Summer Sale",
                controller: _titleCtrl,
                validator: (v) => v!.isEmpty ? "Title required" : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: CustomTextField(label: "Tag", hint: "HOT", controller: _tagCtrl, validator: (v) => v!.isEmpty ? "Tag required" : null)),
                  const SizedBox(width: 12),
                  Expanded(child: CustomTextField(label: "Button", hint: "Shop Now", controller: _btnCtrl, validator: (v) => v!.isEmpty ? "Btn required" : null)),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Hex Color (Format: 0xFF...)",
                hint: "0xFFFF6B00",
                controller: _colorCtrl,
                validator: (v) => v!.length != 10 ? "Invalid Hex" : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _validateAndSave,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00), minimumSize: const Size(double.infinity, 56)),
                      child: const Text("Save Banner"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
