import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hakabo/core/l10n/app_strings.dart';
import 'package:hakabo/core/l10n/locale_provider.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../core/constants/colors.dart';
import '../chat/chat_screen.dart';
import 'cart_view.dart';
import 'checkout_view.dart';
import '../../core/widgets/video_player_widget.dart';

class ProductDetailsView extends StatefulWidget {
  final Product product;
  const ProductDetailsView({super.key, required this.product});

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  int _selectedSize = 0;
  int _selectedColor = 0;
  int _quantity = 1;
  bool _expandedDesc = false;
  late final PageController _pageCtrl;
  Timer? _sliderTimer;
  int _activeItem = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(initialPage: 0);
    _startSliderTimer();
  }

  void _startSliderTimer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final product = widget.product;
      final images = product.allImages;
      final totalItems = (product.videoUrl.isNotEmpty ? 1 : 0) + images.length;
      if (totalItems > 1) {
        _sliderTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
          if (_pageCtrl.hasClients) {
            final hasVideo = product.videoUrl.isNotEmpty;
            if (hasVideo && _activeItem == images.length) {
              return; // Do not auto-slide if currently on the video page
            }
            _activeItem++;
            if (_activeItem >= totalItems) {
              _activeItem = 0;
            }
            _pageCtrl.animateToPage(
              _activeItem,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final market = Provider.of<MarketplaceProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final store = market.getStoreById(product.storeId);
    final inWishlist = market.isInWishlist(product.id);
    final images = product.allImages;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 420,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimaryLight,
            elevation: 0,
            stretch: true,
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
                  '${product.name} — \$${product.price.toStringAsFixed(2)} on EMARA',
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
              background: (images.isNotEmpty || product.videoUrl.isNotEmpty)
                  ? Stack(
                      children: [
                        PageView.builder(
                          controller: _pageCtrl,
                          itemCount: (product.videoUrl.isNotEmpty ? 1 : 0) + images.length,
                          onPageChanged: (i) => setState(() => _activeItem = i),
                          itemBuilder: (_, i) {
                            final hasVideo = product.videoUrl.isNotEmpty;
                            if (hasVideo && i == images.length) {
                              return SafeArea(
                                child: Container(
                                  color: Colors.black,
                                  alignment: Alignment.center,
                                  child: VideoPlayerWidget(
                                    url: product.videoUrl,
                                    autoPlay: true,
                                  ),
                                ),
                              );
                            }
                            final imageIndex = i;
                            return Image.network(
                              images[imageIndex],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (c, e, s) => _imagePlaceholder(),
                            );
                          },
                        ),
                        if ((product.videoUrl.isNotEmpty ? 1 : 0) + images.length > 1)
                          Positioned(
                            bottom: 14,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                (product.videoUrl.isNotEmpty ? 1 : 0) + images.length,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: i == _activeItem ? 18 : 6,
                                  height: 6,
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  decoration: BoxDecoration(
                                    color: i == _activeItem
                                        ? AppColors.primary
                                        : Colors.grey.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : _imagePlaceholder(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(AppStrings.translateData(product.name, locale.language),
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                color: AppColors.textPrimaryLight)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFEDD5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 16),
                            const SizedBox(width: 4),
                            Text(product.rating.toStringAsFixed(1),
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFC2410C))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('\$${product.priceWithFee.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: product.hasDiscount ? const Color(0xFFEF4444) : AppColors.primary)),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 10),
                        Text('\$${product.originalPrice!.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF94A3B8),
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Color(0xFF94A3B8))),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-${product.discountPercent}% OFF',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: product.stock > 0 ? AppColors.primary.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                         product.stock > 0 ? '${product.stock} ${locale.t('stock_available')}' : locale.t('out_of_stock'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: product.stock > 0 ? AppColors.primary : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // ── Quantity Selector ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tirada (Quantity)",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
                                ),
                                child: Icon(Icons.remove_rounded, size: 18, color: _quantity > 1 ? const Color(0xFF1F2937) : Colors.grey.shade400),
                              ),
                            ),
                            Container(
                              width: 44,
                              alignment: Alignment.center,
                              child: Text(
                                "$_quantity",
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1F2937)),
                              ),
                            ),
                            InkWell(
                              onTap: _quantity < product.stock ? () => setState(() => _quantity++) : null,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
                                ),
                                child: Icon(Icons.add_rounded, size: 18, color: _quantity < product.stock ? const Color(0xFF1F2937) : Colors.grey.shade400),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (product.sizes.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(locale.t('select_size'),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimaryLight)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      children: List.generate(product.sizes.length, (i) {
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
                            child: Text(product.sizes[i],
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
                  ],
                  if (product.colors.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(locale.t('select_color'),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimaryLight)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      children: List.generate(product.colors.length, (i) {
                        final selected = _selectedColor == i;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = i),
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
                            child: Text(product.colors[i],
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
                  ],
                  const SizedBox(height: 28),
                  Text(locale.t('description'),
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimaryLight)),
                  const SizedBox(height: 12),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _expandedDesc ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    firstChild: Text(
                      AppStrings.translateData(product.description.isNotEmpty ? product.description : 'Alaab tayo sare leh oo ka timid dukaanka ${product.storeName}.', locale.language),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 15, height: 1.6),
                    ),
                    secondChild: Text(
                      AppStrings.translateData(product.description.isNotEmpty ? product.description : 'Alaab tayo sare leh oo ka timid dukaanka ${product.storeName}.', locale.language),
                      style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 15, height: 1.6),
                    ),
                  ),
                  if (product.description.length > 80)
                    TextButton(
                      onPressed: () =>
                          setState(() => _expandedDesc = !_expandedDesc),
                      child: Text(_expandedDesc ? locale.t('show_less') : locale.t('read_more'),
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
                                AppStrings.translateData(store?.name ?? product.storeName, locale.language),
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
                          child: Text(locale.t('chat'),
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _serviceChip(Icons.verified_rounded, locale.t('warranty')),
                      const SizedBox(width: 12),
                      _serviceChip(Icons.replay_rounded, locale.t('return_policy')),
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
              onTap: product.stock > 0
                  ? () {
                      market.addToCart(product, _quantity);
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${product.name} ($_quantity) waa lagu daray Cart-ka!',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF00D285),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          action: SnackBarAction(
                            label: 'EAG CART',
                            textColor: Colors.white,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CartView()),
                            ),
                          ),
                        ),
                      );
                    }
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Alaabtan stock-keedu wuu dhammaaday!'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: product.stock > 0 ? const Color(0xFFF1F5F9) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: product.stock > 0 ? AppColors.primary : Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: product.stock > 0
                      ? const LinearGradient(colors: [AppColors.primary, Color(0xFF00C853)])
                      : const LinearGradient(colors: [Colors.grey, Colors.black38]),
                  boxShadow: product.stock > 0
                      ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))]
                      : [],
                ),
                child: ElevatedButton(
                  onPressed: product.stock > 0
                      ? () {
                          market.addToCart(product, _quantity);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CheckoutView()),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(product.stock > 0 ? locale.t('buy_now') : locale.t('out_of_stock_btn'),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      if (product.stock > 0) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ]
                    ],
                  ),
                ),
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
