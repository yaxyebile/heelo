import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/coupon.dart';
import '../../providers/marketplace_provider.dart';

class AdminCouponsView extends StatefulWidget {
  const AdminCouponsView({super.key});

  @override
  State<AdminCouponsView> createState() => _AdminCouponsViewState();
}

class _AdminCouponsViewState extends State<AdminCouponsView> {
  List<Coupon> _coupons = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final market = Provider.of<MarketplaceProvider>(context, listen: false);
    final list = await market.fetchCoupons();
    if (mounted) setState(() => _coupons = list);
  }

  Future<void> _addCoupon() async {
    final codeCtrl = TextEditingController();
    final pctCtrl = TextEditingController(text: '10');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Coupon cusub'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'Code')),
            TextField(
                controller: pctCtrl,
                decoration: const InputDecoration(labelText: '% dhimis'),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;
    final market = Provider.of<MarketplaceProvider>(context, listen: false);
    await market.saveCoupon(Coupon(
      id: const Uuid().v4(),
      code: codeCtrl.text.trim().toUpperCase(),
      discountPercent: double.tryParse(pctCtrl.text) ?? 10,
    ));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupons', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(onPressed: _addCoupon, icon: const Icon(Icons.add_rounded)),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _coupons.length,
        itemBuilder: (_, i) {
          final c = _coupons[i];
          return Card(
            child: ListTile(
              title: Text(c.code, style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text('${c.discountPercent.toStringAsFixed(0)}% off'),
              trailing: Icon(
                c.isActive ? Icons.check_circle : Icons.cancel,
                color: c.isActive ? Colors.green : Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}
