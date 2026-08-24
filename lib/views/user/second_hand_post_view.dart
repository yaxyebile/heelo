import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/second_hand_item.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_role.dart';
import '../../core/services/upload_service.dart';

class SecondHandPostView extends StatefulWidget {
  const SecondHandPostView({super.key});

  @override
  State<SecondHandPostView> createState() => _SecondHandPostViewState();
}

class _SecondHandPostViewState extends State<SecondHandPostView> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl    = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _priceCtrl    = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _imageCtrl    = TextEditingController();
  final _videoCtrl    = TextEditingController();
  final _stockCtrl    = TextEditingController(text: '1');

  SecondHandCategory _category  = SecondHandCategory.electronics;
  SecondHandCondition _condition = SecondHandCondition.good;
  String _currency = 'USD';
  bool _loading = false;
  final List<String> _imageUrls = [];

  final _currencies = ['USD', 'SOS', 'ETB', 'AED', 'SAR', 'EUR'];

  static const _catIcons = {
    SecondHandCategory.electronics: Icons.phone_android_rounded,
    SecondHandCategory.clothing:    Icons.checkroom_rounded,
    SecondHandCategory.furniture:   Icons.chair_rounded,
    SecondHandCategory.vehicles:    Icons.directions_car_rounded,
    SecondHandCategory.sports:      Icons.sports_soccer_rounded,
    SecondHandCategory.books:       Icons.menu_book_rounded,
    SecondHandCategory.appliances:  Icons.kitchen_rounded,
    SecondHandCategory.other:       Icons.category_rounded,
  };

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _nameCtrl.text  = auth.currentUser?.name ?? '';
    _phoneCtrl.text = auth.currentUser?.phone ?? '';
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose();
    _locationCtrl.dispose(); _phoneCtrl.dispose(); _nameCtrl.dispose();
    _imageCtrl.dispose(); _videoCtrl.dispose(); _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth  = Provider.of<AuthProvider>(context, listen: false);
    final market = Provider.of<MarketplaceProvider>(context, listen: false);

    final imgs = _imageUrls;

    final item = SecondHandItem(
      id: const Uuid().v4(),
      title:       _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      sellerId:    auth.currentUser?.id ?? '',
      sellerName:  _nameCtrl.text.trim(),
      sellerPhone: _phoneCtrl.text.trim(),
      category:    _category,
      condition:   _condition,
      price:       double.tryParse(_priceCtrl.text.trim()) ?? 0,
      currency:    _currency,
      location:    _locationCtrl.text.trim(),
      images:      imgs,
      videoUrl:    _videoCtrl.text.trim().isNotEmpty ? _videoCtrl.text.trim() : null,
      stock:       int.tryParse(_stockCtrl.text.trim()) ?? 1,
      status:      auth.currentUser?.role == UserRole.admin ? SecondHandStatus.approved : SecondHandStatus.pending,
      createdAt:   DateTime.now(),
    );

    try {
      await market.addSecondHandItem(item);
      if (mounted) Navigator.pop(context);
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 28),
                SizedBox(width: 10),
                Text('Waad guuleysatay!', style: TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
            content: Text(
              auth.currentUser?.role == UserRole.admin
                  ? 'Alaabadaada waa la soo gudbiyay waana la daabacay (Auto-approved sidii Admin).'
                  : 'Alaabadaada waa la soo gudbiyay.\n\nAdmin ayaa soo xaqiijin doona ka dibna waxay soo muuqan doontaa suuqa.',
              style: const TextStyle(fontSize: 14, height: 1.5),
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
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Khalad: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alaab Iibso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
            Text('Alaabta casriga ah oo la isticmaalay', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('📸 Sawirrada Alaabta (URL ama Upload - Ugu badnaan 4)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      controller: _imageCtrl,
                      hint: 'Link-ga Sawirka (https://...)',
                      icon: Icons.image_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (_imageUrls.length >= 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ugu badnaan 4 sawir ayaad ku dari kartaa')),
                        );
                        return;
                      }
                      final url = _imageCtrl.text.trim();
                      if (url.isNotEmpty) {
                        setState(() {
                          _imageUrls.add(url);
                          _imageCtrl.clear();
                        });
                      }
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      if (_imageUrls.length >= 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ugu badnaan 4 sawir ayaad ku dari kartaa')),
                        );
                        return;
                      }
                      final uploadedUrl = await UploadService.pickAndUploadImage(bucketName: 'images');
                      if (uploadedUrl != null) {
                        setState(() {
                          _imageUrls.add(uploadedUrl);
                        });
                      }
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00AA5B),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.photo_library_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
              if (_imageUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imageUrls.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              image: DecorationImage(
                                image: NetworkImage(_imageUrls[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 16,
                            child: GestureDetector(
                              onTap: () => setState(() => _imageUrls.removeAt(index)),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 20),
              _section('🎥 Muuqaalka Alaabta (Video URL ama Upload - Optional)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      controller: _videoCtrl,
                      hint: 'Youtube/MP4 link ama ku dar video...',
                      icon: Icons.video_library_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final uploadedUrl = await UploadService.pickAndUploadVideo();
                      if (uploadedUrl != null) {
                        setState(() {
                          _videoCtrl.text = uploadedUrl;
                        });
                      }
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.upload_file_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _section('📝 Faahfaahinta Alaabta'),
              const SizedBox(height: 8),
              _field(
                controller: _titleCtrl,
                hint: 'Cinwaanka Alaabta (e.g. Samsung Galaxy S20)',
                icon: Icons.title_rounded,
                validator: (v) => v == null || v.trim().isEmpty ? 'Fadlan qor cinwaanka' : null,
              ),
              const SizedBox(height: 10),
              _field(
                controller: _descCtrl,
                hint: 'Sharax faahfaahan alaabta...',
                icon: Icons.description_rounded,
                maxLines: 4,
              ),

              const SizedBox(height: 20),
              _section('📦 Nooca & Xaaladda'),
              const SizedBox(height: 8),
              // Category
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nooca Alaabta', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SecondHandCategory.values.map((c) {
                        final sel = _category == c;
                        return GestureDetector(
                          onTap: () => setState(() => _category = c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_catIcons[c], size: 14, color: sel ? Colors.white : const Color(0xFF64748B)),
                                const SizedBox(width: 5),
                                Text(
                                  SecondHandItem(
                                    id: '', title: '', description: '', sellerId: '',
                                    sellerName: '', sellerPhone: '', category: c,
                                    condition: SecondHandCondition.good, price: 0,
                                    location: '', createdAt: DateTime.now(),
                                  ).categoryLabel,
                                  style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w700,
                                    color: sel ? Colors.white : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Condition
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Xaaladda Alaabta', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 10),
                    Row(
                      children: SecondHandCondition.values.map((c) {
                        final sel = _condition == c;
                        final label = SecondHandItem(
                          id: '', title: '', description: '', sellerId: '',
                          sellerName: '', sellerPhone: '', category: SecondHandCategory.other,
                          condition: c, price: 0, location: '', createdAt: DateTime.now(),
                        ).conditionLabel;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _condition = c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: sel ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w700,
                                    color: sel ? Colors.white : const Color(0xFF64748B),
                                  )),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _section('💵 Qiimaha'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _field(
                      controller: _priceCtrl,
                      hint: '0.00',
                      icon: Icons.monetization_on_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Qiimaha ku qor';
                        if (double.tryParse(v.trim()) == null) return 'Lambar saxan';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _currency,
                          isExpanded: true,
                          items: _currencies
                              .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))))
                              .toList(),
                          onChanged: (v) => setState(() => _currency = v!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _section('📦 Tirada Stock-ga'),
              const SizedBox(height: 8),
              _field(
                controller: _stockCtrl,
                hint: '1',
                icon: Icons.inventory_2_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Tirada ku qor';
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 1) return 'Ugu yaraan 1';
                  return null;
                },
              ),

              const SizedBox(height: 20),
              _section('📍 Xogta Xiriirka'),
              const SizedBox(height: 8),
              _field(
                controller: _locationCtrl,
                hint: 'Magaalada / Degmada',
                icon: Icons.location_on_rounded,
                validator: (v) => v == null || v.trim().isEmpty ? 'Fadlan qor goobta' : null,
              ),
              const SizedBox(height: 10),
              _field(
                controller: _nameCtrl,
                hint: 'Magacaaga',
                icon: Icons.person_rounded,
                validator: (v) => v == null || v.trim().isEmpty ? 'Magacaaga ku qor' : null,
              ),
              const SizedBox(height: 10),
              _field(
                controller: _phoneCtrl,
                hint: '+252 61...',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.trim().isEmpty ? 'Taleefankaaga ku qor' : null,
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Soo Gudbi Alaabta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String label) {
    return Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)));
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF2563EB)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
