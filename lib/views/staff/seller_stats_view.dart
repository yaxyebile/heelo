import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/store.dart';
import '../../providers/marketplace_provider.dart';

class SellerStatsView extends StatelessWidget {
  final Store store;
  const SellerStatsView({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final data = market.storeRevenueLast7Days(store.id);
    final maxVal = data.values.fold(0.0, (a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales stats',
            style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last 7 days — ${store.name}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.entries.map((e) {
                  final h = maxVal > 0 ? (e.value / maxVal) * 160 : 4.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('\$${e.value.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 9)),
                          const SizedBox(height: 4),
                          Container(
                            height: h,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(e.key,
                              style: const TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
