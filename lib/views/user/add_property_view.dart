import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/property_listing.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/colors.dart';
import '../../models/user_role.dart';
import '../../core/services/upload_service.dart';

class AddPropertyView extends StatefulWidget {
  const AddPropertyView({super.key});

  @override
  State<AddPropertyView> createState() => _AddPropertyViewState();
}

class _AddPropertyViewState extends State<AddPropertyView> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _bedroomsCtrl = TextEditingController();
  final _bathroomsCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _videoUrlCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();

  PropertyType _propertyType = PropertyType.house;
  PropertyListingType _listingType = PropertyListingType.rent;
  String _currency = 'USD';
  final List<String> _amenities = [];
  final List<String> _imageUrls = [];
  bool _submitting = false;

  final List<String> _currencies = ['USD', 'SOS', 'ETB', 'AED', 'SAR', 'EUR'];
  final List<String> _commonAmenities = [
    'Biyo Joogto ah',
    'Korontada',
    'Internet',
    'Garajka',
    'Beerta',
    'Gaashaanka',
    'Qabyo',
    'Dhisme cusub',
    'Meel xaafad nabdoon',
    'Suuq ku dhow',
  ];

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser != null) {
      _ownerNameCtrl.text = auth.currentUser!.name;
      _phoneCtrl.text = auth.currentUser!.phone ?? '';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _priceCtrl.dispose();
    _areaCtrl.dispose();
    _bedroomsCtrl.dispose();
    _bathroomsCtrl.dispose();
    _phoneCtrl.dispose();
    _imageUrlCtrl.dispose();
    _videoUrlCtrl.dispose();
    _ownerNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final market = Provider.of<MarketplaceProvider>(context, listen: false);
      final isAdmin = auth.currentUser?.role == UserRole.admin;

      final listing = PropertyListing(
        id: const Uuid().v4(),
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        ownerId: auth.currentUser?.id ?? '',
        ownerName: _ownerNameCtrl.text.trim(),
        ownerPhone: _phoneCtrl.text.trim(),
        propertyType: _propertyType,
        listingType: _listingType,
        price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
        currency: _currency,
        location: _locationCtrl.text.trim(),
        areaSqm: double.tryParse(_areaCtrl.text.trim()) ?? 0,
        bedrooms: int.tryParse(_bedroomsCtrl.text.trim()) ?? 0,
        bathrooms: int.tryParse(_bathroomsCtrl.text.trim()) ?? 0,
        images: _imageUrls,
        videoUrl: _videoUrlCtrl.text.trim().isNotEmpty ? _videoUrlCtrl.text.trim() : null,
        amenities: _amenities,
        isApproved: isAdmin,
        isAvailable: true,
        createdAt: DateTime.now(),
      );

      await market.addPropertyListing(listing);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isAdmin
                        ? 'Hantida waa la diiwaangeliyay, si toos ah ayaana loo daabacay!'
                        : 'Hantidaada waa la gudbiyay! Admin ayaa dib u eegi doona.',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Khalad: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isAdmin = auth.currentUser?.role == UserRole.admin;

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
        title: const Text('Ku Dar Hantida',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Listing type selector
            _sectionTitle('Nooca Xayeysiiska'),
            const SizedBox(height: 10),
            Row(
              children: PropertyListingType.values.map((t) {
                final selected = _listingType == t;
                final isRent = t == PropertyListingType.rent;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _listingType = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? LinearGradient(
                                colors: isRent
                                    ? [const Color(0xFF2563EB), const Color(0xFF3B82F6)]
                                    : [const Color(0xFFDC2626), const Color(0xFFEF4444)],
                              )
                            : null,
                        color: selected ? null : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: (isRent
                                          ? const Color(0xFF3B82F6)
                                          : const Color(0xFFEF4444))
                                      .withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isRent ? Icons.vpn_key_rounded : Icons.sell_rounded,
                            color: selected ? Colors.white : const Color(0xFF94A3B8),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isRent ? 'Kireysi' : 'Iibsi',
                            style: TextStyle(
                              color: selected ? Colors.white : const Color(0xFF64748B),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Property type
            _sectionTitle('Nooca Hantida'),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: PropertyType.values.map((t) {
                  final selected = _propertyType == t;
                  return GestureDetector(
                    onTap: () => setState(() => _propertyType = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _typeLabel(t),
                        style: TextStyle(
                          color: selected ? Colors.white : const Color(0xFF374151),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            _sectionTitle('Cinwaanka Xayeysiiska'),
            const SizedBox(height: 8),
            _field(
              controller: _titleCtrl,
              hint: 'Tusaale: Guri 3 Qol ah Xoofto',
              icon: Icons.title_rounded,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Cinwaanka ku qor' : null,
            ),
            const SizedBox(height: 16),

            // Location
            _sectionTitle('Goobta'),
            const SizedBox(height: 8),
            _field(
              controller: _locationCtrl,
              hint: 'Xaafadda, degmada...',
              icon: Icons.location_on_rounded,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Goobta ku qor' : null,
            ),
            const SizedBox(height: 16),

            // Price + Currency
            _sectionTitle('Qiimaha & Lacagta'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _field(
                    controller: _priceCtrl,
                    hint: '500',
                    icon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v == null || double.tryParse(v.trim()) == null) ? 'Qiimaha ku qor' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _currency,
                        isExpanded: true,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937)),
                        items: _currencies
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _currency = v!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Area
            _sectionTitle('Qiyaasta (m²)'),
            const SizedBox(height: 8),
            _field(
              controller: _areaCtrl,
              hint: '120',
              icon: Icons.square_foot_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Bedrooms & Bathrooms (only for houses, apartments, villas)
            if (_propertyType != PropertyType.land &&
                _propertyType != PropertyType.shop) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Qolalka'),
                        const SizedBox(height: 8),
                        _field(
                          controller: _bedroomsCtrl,
                          hint: '3',
                          icon: Icons.bed_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Musqusha'),
                        const SizedBox(height: 8),
                        _field(
                          controller: _bathroomsCtrl,
                          hint: '2',
                          icon: Icons.bathroom_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Description
            _sectionTitle('Faahfaahin'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Sharax hantida si faahfaahsan...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Amenities
            _sectionTitle('Sifooyin'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonAmenities.map((a) {
                final selected = _amenities.contains(a);
                return GestureDetector(
                  onTap: () => setState(() {
                    selected ? _amenities.remove(a) : _amenities.add(a);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? AppColors.primary.withValues(alpha: 0.4) : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected)
                          const Icon(Icons.check_rounded, size: 13, color: AppColors.primary),
                        if (selected) const SizedBox(width: 4),
                        Text(a,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected ? AppColors.primary : const Color(0xFF374151),
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Image URLs
            _sectionTitle('Sawirrada (URL ama Upload - Ugu badnaan 4)'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _field(
                    controller: _imageUrlCtrl,
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
                    final url = _imageUrlCtrl.text.trim();
                    if (url.isNotEmpty) {
                      setState(() {
                        _imageUrls.add(url);
                        _imageUrlCtrl.clear();
                      });
                    }
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
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

            // Video URL
            _sectionTitle('Muuqaalka (Video URL ama Upload - Optional)'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _field(
                    controller: _videoUrlCtrl,
                    hint: 'Youtube ama MP4 link ama ku dar video...',
                    icon: Icons.video_library_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    final uploadedUrl = await UploadService.pickAndUploadVideo();
                    if (uploadedUrl != null) {
                      setState(() {
                        _videoUrlCtrl.text = uploadedUrl;
                      });
                    }
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.upload_file_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Owner info
            _sectionTitle(isAdmin ? 'Macluumaadka Mulkiilaha' : 'Macluumaadkaaga'),
            const SizedBox(height: 8),
            _field(
              controller: _ownerNameCtrl,
              hint: isAdmin ? 'Magaca Mulkiilaha (Owner Name)' : 'Magacaaga',
              icon: Icons.person_rounded,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? (isAdmin ? 'Fadlan qor magaca mulkiilaha' : 'Magacaaga ku qor') : null,
            ),
            const SizedBox(height: 10),
            _field(
              controller: _phoneCtrl,
              hint: isAdmin ? 'Taleefanka Mulkiilaha (Owner Phone)' : '+252 61...',
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? (isAdmin ? 'Fadlan qor taleefanka mulkiilaha' : 'Telefonkaaga ku qor') : null,
            ),
            const SizedBox(height: 32),

            // Submit button
            GestureDetector(
              onTap: _submitting ? null : _submit,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF00AA5B), Color(0xFF00D285)]),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00AA5B).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: _submitting
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text('Gudbi Xayeysiiska',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text('Admin ayaa xayeysiiskaaga eegi doona ka hor intaan la soo bandhigin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            ),
          ],
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

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF374151)),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
