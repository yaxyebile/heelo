import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/colors.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/waafi_service.dart';
import '../../core/services/features_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';

class BookTechnicianView extends StatefulWidget {
  final Map<String, dynamic> category;
  const BookTechnicianView({super.key, required this.category});

  @override
  State<BookTechnicianView> createState() => _BookTechnicianViewState();
}

class _BookTechnicianViewState extends State<BookTechnicianView> {
  String _selectedLevel = '';
  final TextEditingController _detailsController  = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController    = TextEditingController();
  bool _submitting = false;

  // Pricing loaded from Supabase
  Map<String, Map<String, dynamic>> _pricing = {
    'Sare':         {'label': 'Heer Sare',    'price': 50.0, 'desc': 'Khabiir aad u sareeya'},
    'Dhex Dhexaad': {'label': 'Dhex Dhexaad', 'price': 30.0, 'desc': 'Farsamo yaqaan khibrad leh'},
    'Hoose':        {'label': 'Heer Hoose',   'price': 15.0, 'desc': 'Farsamo yaqaan caadi ah'},
  };
  bool _loadingPricing = true;

  @override
  void initState() {
    super.initState();
    _loadPricing();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final phone = auth.currentUser?.phone;
      if (phone != null && phone.isNotEmpty) {
        _phoneController.text = phone;
      }
    });
  }

  Future<void> _loadPricing() async {
    final allPricing = await SupabaseService.fetchTechPricing();
    final catName = widget.category['name'] as String;

    // Flexible matching for category name from Supabase
    Map<String, double>? catPricing = allPricing[catName];
    if (catPricing == null) {
      final cleanCat = catName.split('(').first.trim().toLowerCase();
      for (final entry in allPricing.entries) {
        final keyClean = entry.key.split('(').first.trim().toLowerCase();
        if (keyClean == cleanCat || entry.key.toLowerCase().contains(cleanCat) || cleanCat.contains(entry.key.toLowerCase())) {
          catPricing = entry.value;
          break;
        }
      }
    }

    if (catPricing != null) {
      setState(() {
        _pricing = {
          'Sare':         {'label': 'Heer Sare',    'price': catPricing!['Sare'] ?? 50.0,         'desc': 'Khabiir aad u sareeya'},
          'Dhex Dhexaad': {'label': 'Dhex Dhexaad', 'price': catPricing['Dhex Dhexaad'] ?? 30.0, 'desc': 'Farsamo yaqaan khibrad leh'},
          'Hoose':        {'label': 'Heer Hoose',   'price': catPricing['Hoose'] ?? 15.0,        'desc': 'Farsamo yaqaan caadi ah'},
        };
      });
    }
    setState(() => _loadingPricing = false);
  }

  double get _selectedPrice =>
      _selectedLevel.isEmpty ? 0 : (_pricing[_selectedLevel]?['price'] as num? ?? 0).toDouble();

  Future<void> _processPayment() async {
    if (_selectedLevel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fadlan dooro heerka farsamo yaqaanka')),
      );
      return;
    }
    if (_detailsController.text.trim().isEmpty || _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fadlan geli faahfaahinta iyo goobtaada')),
      );
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fadlan geli nambarkaaga telefoonka / EVC Plus')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final market = Provider.of<MarketplaceProvider>(context, listen: false);
    final bookingId = const Uuid().v4();
    final phone = _phoneController.text.trim();
    final price = _selectedPrice;

    // Check if automatic WAAFI API pay is enabled
    if (market.waafiAutoEnabled) {
      _triggerWaafiPushPayment(auth, market, bookingId, phone, price);
    } else {
      _processManualBooking(auth, bookingId, phone, price);
    }
  }

  Future<void> _triggerWaafiPushPayment(
    AuthProvider auth,
    MarketplaceProvider market,
    String bookingId,
    String phone,
    double price,
  ) async {
    setState(() => _submitting = true);
    bool dialogIsOpen = false;

    try {
      if (!mounted) return;
      dialogIsOpen = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 50, height: 50,
                  child: CircularProgressIndicator(color: Color(0xFFFF6B00), strokeWidth: 3.5),
                ),
                const SizedBox(height: 20),
                const Text('WAAFI Pay (EVC Plus)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1F2937))),
                const SizedBox(height: 10),
                Text(
                  'SMS Pop-up ayaa loo diray nambarkaaga ($phone).\nFadlan geli PIN-kaaga EVC Plus si aad u bixiso \$${price.toStringAsFixed(0)}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                ),
              ],
            ),
          ),
        ),
      );

      final res = await WaafiPayService.processEvcPayment(
        phone: phone,
        amount: price,
        orderId: bookingId,
        merchantUid: market.waafiMerchantUid,
        apiUserId: market.waafiApiUserId,
        apiKey: market.waafiApiKey,
      );

      if (dialogIsOpen && mounted) {
        Navigator.pop(context); // Close progress dialog
        dialogIsOpen = false;
      }

      if (res.success) {
        // Insert paid booking into Supabase
        await SupabaseService.insertTechBooking({
          'id':             bookingId,
          'category':       widget.category['name'],
          'level':          _selectedLevel,
          'price':          '\$${price.toStringAsFixed(0)}',
          'details':        _detailsController.text.trim(),
          'location':       _locationController.text.trim(),
          'user_name':      auth.currentUser?.name ?? 'User',
          'user_id':        auth.currentUser?.id ?? '',
          'phone':          phone,
          'status':         'paid',
          'is_paid':        true,
          'transaction_id': res.transactionId ?? '',
          'created_at':     DateTime.now().toIso8601String(),
        });

        if (auth.currentUser?.id != null) {
          await FeaturesService.createNotification(
            userId: auth.currentUser!.id,
            title: 'Lacagta Farsamo Yaqaanka Waa La Bixiyay!',
            body: 'Dalabkaaga ${widget.category['name']} (\$${price.toStringAsFixed(0)}) waa la ansixiyay via EVC Plus.',
            type: 'tech_booking',
            relatedId: bookingId,
          );
        }

        if (!mounted) return;
        _showSuccessDialog(price, res.transactionId ?? bookingId);
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Icon(Icons.error_outline_rounded, color: Colors.red, size: 54),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Lacag Bixintu Weey Fashilantay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Text(res.message, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.7))),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('KU CELI', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFFF6B00))),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Cillad aan laga filayn ayaa dhacday: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (dialogIsOpen && mounted) {
        try {
          Navigator.pop(context);
        } catch (_) {}
      }
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _processManualBooking(
    AuthProvider auth,
    String bookingId,
    String phone,
    double price,
  ) async {
    setState(() => _submitting = true);

    await SupabaseService.insertTechBooking({
      'id':         bookingId,
      'category':   widget.category['name'],
      'level':      _selectedLevel,
      'price':      '\$${price.toStringAsFixed(0)}',
      'details':    _detailsController.text.trim(),
      'location':   _locationController.text.trim(),
      'user_name':  auth.currentUser?.name ?? 'User',
      'user_id':    auth.currentUser?.id ?? '',
      'phone':      phone,
      'status':     'pending',
      'is_paid':    false,
      'created_at': DateTime.now().toIso8601String(),
    });

    setState(() => _submitting = false);
    if (!mounted) return;
    _showSuccessDialog(price, null);
  }

  void _showSuccessDialog(double price, String? txId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Icon(Icons.check_circle_rounded, color: Color(0xFF00D285), size: 64),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Dalabka Waa La Gudbiyay!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
            const SizedBox(height: 12),
            Text(
              txId != null
                  ? 'Lacagta \$${price.toStringAsFixed(0)} waa la bixiyay (Tx: ${txId.substring(0, txId.length > 10 ? 10 : txId.length)}).\nFarsamo yaqaanka mar dhaw ayuu kula soo xiriiri doonaa.'
                  : 'Dalabkaaga wuu samaysmay.\nFarsamo yaqaanka ayaa kula soo xiriiri doona si uu adeegga u bixiyo.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D285),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
              child: const Text('LA GARTEY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final market = Provider.of<MarketplaceProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Dalbo ${cat['name']}',
          style: const TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w900, fontSize: 17)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        centerTitle: true,
      ),
      body: _loadingPricing
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon header
                  Center(
                    child: Container(
                      width: 84, height: 84,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cat['color'] ?? const Color(0xFFFF6B00), const Color(0xFF2563EB)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: (cat['color'] as Color? ?? const Color(0xFFFF6B00)).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Icon(cat['icon'], color: Colors.white, size: 42),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(child: Text(cat['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF1F2937)))),
                  const SizedBox(height: 28),

                  // 1. Level
                  const Text('1. Dooro Heerka Farsamo Yaqaanka',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1F2937))),
                  const SizedBox(height: 14),
                  ..._pricing.entries.map((entry) {
                    final id   = entry.key;
                    final info = entry.value;
                    final isSel = _selectedLevel == id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedLevel = id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFFF6B00).withOpacity(0.06) : Colors.white,
                          border: Border.all(
                            color: isSel ? const Color(0xFFFF6B00) : const Color(0xFFE2E8F0),
                            width: isSel ? 2 : 1.2,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: isSel ? [BoxShadow(color: const Color(0xFFFF6B00).withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 4))] : [],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSel ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                              color: isSel ? const Color(0xFFFF6B00) : const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(info['label'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1F2937))),
                                  const SizedBox(height: 2),
                                  Text(info['desc'],  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                                ],
                              ),
                            ),
                            Text(
                              '\$${(info['price'] as num).toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFFFF6B00)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // 2. Details & Location
                  const Text('2. Faahfaahinta Cilada & Nambarka Telefoonka',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1F2937))),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nambarka Telefoonka (EVC Plus / Account)',
                      hintText: '61XXXXXXX',
                      prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFFFF6B00)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _detailsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Faahfaahinta Cilada',
                      hintText: 'Qor faahfaahinta cilada haysata qalabkaaga...',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Goobtaada (Location)',
                      hintText: 'Tusaale: Hodan, Taleex, Mogadishu',
                      prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFFFF6B00)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),

                  if (market.waafiAutoEnabled) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF00D285).withOpacity(0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: Color(0xFF00D285), size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'WAAFI Pay API is Active! Lacag bixintu waxay si automatic ah ugu dhaceysaa EVC Plus.',
                              style: TextStyle(color: Color(0xFF047857), fontWeight: FontWeight.w700, fontSize: 11.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: const Color(0xFFFF6B00).withOpacity(0.4),
              ),
              onPressed: _submitting ? null : _processPayment,
              child: _submitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _selectedLevel.isEmpty
                              ? 'Bixi Lacagta & Dalbo'
                              : 'Bixi \$${_selectedPrice.toStringAsFixed(0)} & Dalbo (EVC Plus)',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
