import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/store.dart';
import '../../models/product.dart';

class AdminRestaurantsView extends StatelessWidget {
  const AdminRestaurantsView({super.key});

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketplaceProvider>();
    final restaurants = market.stores.where((s) => s.isRestaurant).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE11D48),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('🍔 Maqaayadaha (Restaurants)', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFBE123C)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: const Color(0xFFE11D48).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${restaurants.length} Maqaayado Diiwaangashan',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 2),
                        const Text('Maamul cuntooyinka iyo dakhliga maqaayad walba',
                            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('📋 Liiska Maqaayadaha & Dakhligooda',
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
                    Text('Weli ma jiro dukaan loo calaamadeeyay Maqaayad.',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                    SizedBox(height: 16),
                    Text('Waxaad dukaan kasta u beddeli kartaa Maqaayad marka aad diiwaangelinayso ama beddelayso.',
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              )
            else
              for (final rest in restaurants)
                _buildRestaurantTile(context, market, rest),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantTile(BuildContext context, MarketplaceProvider market, Store rest) {
    final foodItems = market.getProductsByStore(rest.id);
    final revenue = market.revenueForStore(rest.id);
    final storeOrders = market.getOrdersByStore(rest.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFE4E6),
            image: rest.logo.isNotEmpty ? DecorationImage(image: NetworkImage(rest.logo), fit: BoxFit.cover) : null,
          ),
          child: rest.logo.isEmpty ? const Icon(Icons.restaurant_rounded, color: Color(0xFFE11D48)) : null,
        ),
        title: Text(rest.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Dakhliga: \$${revenue.toStringAsFixed(2)}',
                  style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Text('${foodItems.length} Cunto • ${storeOrders.length} Dalab',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🍔 Cuntooyinka Maqaayadda (Menu):',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF334155))),
                const SizedBox(height: 10),
                if (foodItems.isEmpty)
                  const Text('Weli ma jiro cunto lagu daray maqaayaddan.',
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic))
                else
                  for (final f in foodItems)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text(f.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const Spacer(),
                          if (f.hasDiscount) ...[
                            Text('\$${f.originalPrice!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 11)),
                            const SizedBox(width: 6),
                          ],
                          Text('\$${f.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, color: Color(0xFFE11D48), fontSize: 13)),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
