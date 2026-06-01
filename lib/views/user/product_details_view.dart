import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../core/constants/colors.dart';
import '../chat/chat_screen.dart';
import 'cart_view.dart';
import 'checkout_view.dart';

class ProductDetailsView extends StatefulWidget {
  final Product product;
  const ProductDetailsView({super.key, required this.product});

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  int _selectedSize = 0;
  bool _expandedDesc = false;
  static const _sizes = ['US 9', 'US 10', 'US 11', 'US 12'];

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final market = Provider.of<MarketplaceProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final store = market.getStoreById(product.storeId);
    final inWishlist = market.isInWishlist(product.id);
    final images = product.allImages;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimaryLight,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10)
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: AppColors.textPrimaryLight),
                ),
              ),
            ),
            actions: [
              _circleAction(Icons.ios_share_rounded, () {
                Share.share(
                  '${product.name} — \$${product.price.toStringAsFixed(2)} on Helo Market',
                );
              }),
              _circleAction(
                inWishlist ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                () {
                  if (auth.currentUser == null) return;
                  market.toggleWishlist(auth.currentUser!.id, product.id);
                },
                iconColor: inWishlist ? Colors.red : Colors.redAccent,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: images.isEmpty
                  ? _imagePlaceholder()
                  : images.length == 1
                      ? Image.network(images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imagePlaceholder())
                      : PageView.builder(
                          itemCount: images.length,
                          itemBuilder: (_, i) => Image.network(
                            images[i],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          ),
                        ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.2)),
                  const SizedBox(height: 8),
                  Text('\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary)),
                  const SizedBox(height: 20),
                  const Text('SELECT SIZE',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondaryLight,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: List.generate(_sizes.length, (i) {
                      final selected = _selectedSize == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSize = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(_sizes[i],
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              )),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  const Text('DESCRIPTION',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondaryLight)),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : 'Premium quality product from ${product.storeName}.',
                    maxLines: _expandedDesc ? null : 3,
                    overflow: _expandedDesc ? null : TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textSecondaryLight,
                        fontSize: 14,
                        height: 1.5),
                  ),
                  if (product.description.length > 80)
                    TextButton(
                      onPressed: () =>
                          setState(() => _expandedDesc = !_expandedDesc),
                      child: Text(_expandedDesc ? 'Show less' : 'Read More',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700)),
                    ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          child: const Icon(Icons.storefront_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                store?.name ?? product.storeName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                              const Text('Verified seller',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondaryLight)),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                otherUserId: store?.ownerId ?? 'admin',
                                otherUserName: store?.name ?? product.storeName,
                              ),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Chat',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _serviceChip(Icons.local_shipping_outlined,
                          'Free Delivery'),
                      const SizedBox(width: 12),
                      _serviceChip(Icons.replay_rounded, '30-Day Return'),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, -4))
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                market.addToCart(product, 1);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CartView()));
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.shopping_cart_outlined,
                    color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  market.addToCart(product, 1);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutView()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Buy Now',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleAction(IconData icon, VoidCallback onTap,
      {Color iconColor = AppColors.textPrimaryLight}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)
            ],
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
        color: const Color(0xFFF1F5F9),
        child: const Center(
            child: Icon(Icons.image_outlined,
                size: 80, color: AppColors.textSecondaryLight)),
      );

  Widget _serviceChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}
