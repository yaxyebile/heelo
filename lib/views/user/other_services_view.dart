import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import 'package:hakabo/core/l10n/locale_provider.dart';
import 'package:hakabo/core/l10n/app_strings.dart';
import 'technicians_view.dart';
import 'property_listings_view.dart';
import 'second_hand_view.dart';
import 'cargo_ads_view.dart';

class OtherServicesView extends StatelessWidget {
  const OtherServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Adeegyo / Services Hub',
          style: TextStyle(color: Color(0xFF1F2937), fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Qaybaha Kale Ee Suuqa',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Dooro adeegga aad u baahan tahay si aad toos ugu gudubto.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),

          // 1. Farsamo Yaqaano
          _serviceCard(
            context,
            icon: Icons.handyman_rounded,
            title: '🔧 Farsamo Yaqaano',
            description: 'Fixers & Technicians (Electrician, Plumber, Mechanic)',
            gradient: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TechniciansView()),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Real Estate
          _serviceCard(
            context,
            icon: Icons.home_work_rounded,
            title: '🏠 Guri & Dhul (Real Estate)',
            description: 'Rent or buy properties, houses, and land in Somalia',
            gradient: const [Color(0xFF10B981), Color(0xFF047857)],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PropertyListingsView()),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Used Goods (Suuqa Casriga)
          _serviceCard(
            context,
            icon: Icons.swap_horiz_rounded,
            title: '♻️ Suuqa Casriga (Used Goods)',
            description: 'Buy and sell second-hand items easily',
            gradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SecondHandView()),
            ),
          ),
          const SizedBox(height: 16),

          // 4. Cargo Ads
          _serviceCard(
            context,
            icon: Icons.local_shipping_rounded,
            title: '🚢 Cargo & Logistics',
            description: 'Shipment and cargo services across regions',
            gradient: const [Color(0xFFFF6B00), Color(0xFFEA580C)],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CargoAdsView()),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _serviceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF94A3B8),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
