import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';
import '../auth/login_view.dart';
import 'checkout_view.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final cart = market.cart;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("My Cart", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0F172A))),
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () => market.clearCart(),
              child: const Text("Clear", style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: cart.isEmpty ? _emptyCart(context) : _cartBody(context, market, auth, cart),
    );
  }

  Widget _emptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_bag_outlined, size: 64, color: Color(0xFFFF6B00)),
          ),
          const SizedBox(height: 28),
          const Text("Your cart is empty", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 10),
          const Text("Add items to start shopping", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 36),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              foregroundColor: Colors.white,
              minimumSize: const Size(180, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text("Browse Marketplace", style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _cartBody(BuildContext context, MarketplaceProvider market, AuthProvider auth, Map<String, List<OrderItem>> cart) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            physics: const BouncingScrollPhysics(),
            itemCount: cart.length,
            itemBuilder: (context, i) {
              final storeId = cart.keys.elementAt(i);
              return _storeGroup(context, storeId, cart[storeId]!, market);
            },
          ),
        ),
        _checkoutBar(context, market, auth),
      ],
    );
  }

  Widget _storeGroup(BuildContext context, String storeId, List<OrderItem> items, MarketplaceProvider market) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Row(
              children: [
                const Icon(Icons.storefront_rounded, color: Color(0xFFFF6B00), size: 20),
                const SizedBox(width: 10),
                Text(items.first.storeName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(8)),
                  child: const Text("Free Delivery", style: TextStyle(color: Color(0xFF00D285), fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          ...items.map((item) => _cartItem(context, storeId, item, market)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _cartItem(BuildContext context, String storeId, OrderItem item, MarketplaceProvider market) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(18),
              image: item.image.isNotEmpty
                  ? DecorationImage(image: NetworkImage(item.image), fit: BoxFit.cover)
                  : null,
            ),
            child: item.image.isEmpty ? const Icon(Icons.image_outlined, color: Color(0xFFCBD5E1)) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
                    ),
                    GestureDetector(
                      onTap: () => market.removeFromCart(storeId, item.productId),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFEF4444)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text("\$${item.price.toStringAsFixed(0)}",
                    style: const TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _qtyBtn(Icons.remove_rounded, () {}),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text("${item.quantity}",
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                    ),
                    _qtyBtn(Icons.add_rounded, () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF374151)),
      ),
    );
  }

  Widget _checkoutBar(BuildContext context, MarketplaceProvider market, AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Amount", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w600)),
                  SizedBox(height: 2),
                  Text("VAT included", style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11)),
                ],
              ),
              Text(
                "\$${market.cartTotal.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: Color(0xFFFF6B00)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              if (auth.isAuthenticated) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutView()));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginView()));
              }
            },
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF6B00), Color(0xFFD84315)]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFF6B00).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: const Center(
                child: Text("Place Order", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
