import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/store.dart';
import 'store_profile_view.dart';
import '../../core/constants/colors.dart';

class RestaurantsListView extends StatelessWidget {
  const RestaurantsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketplaceProvider>();
    final restaurants = market.restaurants.where((s) => s.isApproved).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE11D48),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('🍔 Maqaayadaha (Food Delivery)', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFE11D48).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 8))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('FAST FOOD & DINING',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                        ),
                        const SizedBox(height: 8),
                        const Text('Dooro Maqaayadda Kaad Jeceshahay',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        const Text('Cuntada kulul si degdeg ah baa laguugu soo gaarsiinayaa!',
                            style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 54),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('🍕 Liiska Maqaayadaha Bixiya Cuntada',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
            const SizedBox(height: 12),

            if (restaurants.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                ),
                child: const Column(
                  children: [
                    Icon(Icons.restaurant_outlined, size: 48, color: Color(0xFFCBD5E1)),
                    SizedBox(height: 12),
                    Text('Weli ma jiro maqaayado la diiwaangeliyay.',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  ],
                ),
              )
            else
              ...restaurants.map((rest) {
                final foodItems = market.getApprovedProductsByStore(rest.id);
                return GestureDetector(
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => StoreProfileView(store: rest))),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFFFFE4E6),
                            image: rest.logo.isNotEmpty
                                ? DecorationImage(image: NetworkImage(rest.logo), fit: BoxFit.cover)
                                : null,
                          ),
                          child: rest.logo.isEmpty ? const Icon(Icons.restaurant_rounded, color: Color(0xFFE11D48), size: 28) : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(rest.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                  ),
                                  if (market.storeHasDiscount(rest.id))
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [Color(0xFFDC2626), Color(0xFF991B1B)]),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFDC2626).withOpacity(0.4),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          )
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 13),
                                          const SizedBox(width: 3),
                                          Text(
                                            'ILAA -${market.getStoreMaxDiscount(rest.id)}%',
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(rest.description.isNotEmpty ? rest.description : 'Cuntooyin dhadhan fiican leh & Gaarsiin degdeg ah',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB800)),
                                  Text(' ${rest.rating.toStringAsFixed(1)}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                                  const SizedBox(width: 10),
                                  Text('• ${foodItems.length} Cuntooyin',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFCBD5E1)),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
