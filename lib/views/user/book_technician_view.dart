import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/colors.dart';
import '../../core/services/supabase_service.dart';
import '../../providers/auth_provider.dart';

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
  }

  Future<void> _loadPricing() async {
    final allPricing = await SupabaseService.fetchTechPricing();
    final catName = widget.category['name'] as String;
    final catPricing = allPricing[catName];
    if (catPricing != null) {
      setState(() {
        _pricing = {
          'Sare':         {'label': 'Heer Sare',    'price': catPricing['Sare'] ?? 50.0,         'desc': 'Khabiir aad u sareeya'},
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

    setState(() => _submitting = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    await SupabaseService.insertTechBooking({
      'id':         const Uuid().v4(),
      'category':   widget.category['name'],
      'level':      _selectedLevel,
      'price':      '\$${_selectedPrice.toStringAsFixed(0)}',
      'details':    _detailsController.text.trim(),
      'location':   _locationController.text.trim(),
      'user_name':  auth.currentUser?.name ?? 'User',
      'user_id':    auth.currentUser?.id ?? '',
      'status':     'pending',
      'created_at': DateTime.now().toIso8601String(),
    });

    setState(() => _submitting = false);
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Waad Ku Guulaysatay!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text(
              'Lacagta: \$${_selectedPrice.toStringAsFixed(0)} ayaa laga goostay.\nFarsamo yaqaanka mar dhaw ayuu kula soo xiriiri doonaa.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
              child: const Text('LA GARTEY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Dalbo ${cat['name']}',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: _loadingPricing
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon header
                  Center(
                    child: Container(
                      width: 80, height: 80,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF97316), Color(0xFF2563EB)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cat['icon'], color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(child: Text(cat['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
                  const SizedBox(height: 32),

                  // 1. Level
                  const Text('1. Dooro Heerka Farsamo Yaqaanka',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  const SizedBox(height: 14),
                  ..._pricing.entries.map((entry) {
                    final id   = entry.key;
                    final info = entry.value;
                    final isSel = _selectedLevel == id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedLevel = id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFF97316).withOpacity(0.05) : Colors.white,
                          border: Border.all(
                            color: isSel ? const Color(0xFFF97316) : Colors.grey.shade200,
                            width: isSel ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSel ? const Color(0xFFF97316) : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(info['label'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                  Text(info['desc'],  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                ],
                              ),
                            ),
                            Text(
                              '\$${(info['price'] as num).toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFFF97316)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 32),

                  // 2. Details & Location
                  const Text('2. Faahfaahinta Cilada & Goobta',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _detailsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Qor faahfaahinta cilada haysata qalabkaaga...',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: 'Meesha aad joogto (Tusaale: Hodan, Taleex)',
                      prefixIcon: const Icon(Icons.location_on_rounded, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
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
                backgroundColor: const Color(0xFFF97316),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _submitting ? null : _processPayment,
              child: _submitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _selectedLevel.isEmpty
                          ? 'Bixi Lacagta & Dalbo'
                          : 'Bixi \$${_selectedPrice.toStringAsFixed(0)} & Dalbo',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
