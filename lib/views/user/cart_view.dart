import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:hakabo/core/l10n/app_strings.dart';
import 'package:hakabo/core/l10n/locale_provider.dart';
import '../../models/order.dart';
import '../auth/login_view.dart';
import 'checkout_view.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final cart = market.cart;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(locale.t('my_cart'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF1F2937))),
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () => market.clearCart(),
              child: Text(locale.t('clear'), style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: cart.isEmpty ? _emptyCart(context, locale) : _cartBody(context, market, auth, cart, locale),
    );
  }

  Widget _emptyCart(BuildContext context, LocaleProvider locale) {
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
            child: const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.primary),
          ),
          const SizedBox(height: 28),
          Text(locale.t('your_cart_is_empty'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
          const SizedBox(height: 10),
          Text(locale.t('add_items_to_start'), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 36),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(180, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(locale.t('browse_marketplace'), style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _cartBody(BuildContext context, MarketplaceProvider market, AuthProvider auth, Map<String, List<OrderItem>> cart, LocaleProvider locale) {
    return Column(
      children: [
        _fulfillmentSelector(context, market),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            physics: const BouncingScrollPhysics(),
            itemCount: cart.length,
            itemBuilder: (context, i) {
              final storeId = cart.keys.elementAt(i);
              return _storeGroup(context, storeId, cart[storeId]!, market, locale);
            },
          ),
        ),
        _checkoutBar(context, market, auth, locale),
      ],
    );
  }

  Widget _fulfillmentSelector(BuildContext context, MarketplaceProvider market) {
    final isPickup = market.isPickupFulfillment;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => market.setFulfillmentType('delivery'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !isPickup ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !isPickup
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_shipping_rounded, size: 18, color: !isPickup ? AppColors.primary : const Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      '🚚 Gaarsiin (Delivery)',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        color: !isPickup ? AppColors.primary : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => market.setFulfillmentType('pickup'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isPickup ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isPickup
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storefront_rounded, size: 18, color: isPickup ? const Color(0xFF00D285) : const Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      '🚶‍♂️ Iska soo doono (Pickup)',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        color: isPickup ? const Color(0xFF00D285) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _storeGroup(BuildContext context, String storeId, List<OrderItem> items, MarketplaceProvider market, LocaleProvider locale) {
    final storeTotal = items.fold(0.0, (sum, i) => sum + (i.price * i.quantity));
    final isPickup = market.isPickupFulfillment;
    final isFreeDelivery = isPickup || storeTotal > 20.0;

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
                const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Text(AppStrings.translateData(items.first.storeName, locale.language), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1F2937))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isFreeDelivery ? const Color(0xFFF0FDF4) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPickup
                        ? '🚶‍♂️ Store Pickup (Bilaash)'
                        : (isFreeDelivery ? '🎉 FREE Delivery (>\$20)' : '🚚 Delivery: \$1.30'),
                    style: TextStyle(
                      color: isFreeDelivery ? const Color(0xFF00D285) : const Color(0xFF2563EB),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          ...items.map((item) => _cartItem(context, storeId, item, market, locale)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _cartItem(BuildContext context, String storeId, OrderItem item, MarketplaceProvider market, LocaleProvider locale) {
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
                      child: Text(AppStrings.translateData(item.productName, locale.language),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1F2937))),
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
                Text("\$${item.price.toStringAsFixed(2)}",
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _qtyBtn(Icons.remove_rounded, () => market.updateCartQty(storeId, item.productId, item.quantity - 1)),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text("${item.quantity}",
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1F2937))),
                    ),
                    _qtyBtn(Icons.add_rounded, () => market.updateCartQty(storeId, item.productId, item.quantity + 1)),
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

  Widget _checkoutBar(BuildContext context, MarketplaceProvider market, AuthProvider auth, LocaleProvider locale) {
    final subtotal = market.cartTotal;
    final deliveryFee = market.deliveryFee;
    final grandTotal = market.cartTotalWithDelivery;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
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
              const Text("Subtotal", style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
              Text("\$${subtotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Delivery Fee", style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
              Text(
                deliveryFee == 0 ? "FREE" : "+\$${deliveryFee.toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: deliveryFee == 0 ? const Color(0xFF00D285) : const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(locale.t('total_amount'), style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  const Text("Inclusive of +7% platform fee & delivery", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                ],
              ),
              Text(
                "\$${grandTotal.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              if (auth.isAuthenticated) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutView()));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginView()));
              }
            },
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF00C853)]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Center(
                child: Text(locale.t('place_order'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
