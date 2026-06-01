import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../core/widgets/product_card.dart';
import 'product_details_view.dart';
import '../auth/login_view.dart';

class WishlistView extends StatelessWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isAuthenticated) {
          return _guest(context);
        }
        return _WishlistContent(key: ValueKey(auth.currentUser!.id));
      },
    );
  }
}

class _WishlistContent extends StatefulWidget {
  const _WishlistContent({super.key});

  @override
  State<_WishlistContent> createState() => _WishlistContentState();
}

class _WishlistContentState extends State<_WishlistContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final uid = auth.currentUser?.id;
    if (uid != null) {
      Provider.of<MarketplaceProvider>(context, listen: false).loadWishlist(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final saved = market.wishlistProducts;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Saved Items',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
      ),
      body: saved.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded,
                      size: 64,
                      color: AppColors.primary.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  const Text('Nothing saved yet',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppColors.textPrimaryLight)),
                  const SizedBox(height: 8),
                  const Text('Tap ♥ on products to save them',
                      style: TextStyle(color: AppColors.textSecondaryLight)),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemCount: saved.length,
              itemBuilder: (_, i) => ProductCard(
                product: saved[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsView(product: saved[i]),
                  ),
                ),
                onAddToCart: () => market.addToCart(saved[i], 1),
              ),
            ),
    );
  }
}

Widget _guest(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded,
                  size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text('Sign in to see saved items',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginView())),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    ),
  );
}
