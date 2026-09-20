import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/hakabo_logo_title.dart';
import 'package:hakabo/core/l10n/locale_provider.dart';
import 'package:hakabo/core/l10n/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../core/utils/whatsapp_launcher.dart';
import 'orders_view.dart';
import 'wishlist_view.dart';
import '../chat/chat_screen.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final market = Provider.of<MarketplaceProvider>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final user = auth.currentUser;
    final orderCount =
        user != null ? market.getOrdersByUser(user.id).length : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const HakaboLogoTitle(logoHeight: 24),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded, color: AppColors.textSecondaryLight),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              backgroundImage: user == null ? const AssetImage('assets/images/avatar.png') : null,
              child: user != null
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              user?.name ?? 'Guest',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.textSecondaryLight),
                const SizedBox(width: 4),
                Text(
                  user?.phone ?? 'Mogadishu, Somalia',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondaryLight),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  Expanded(
                      child: _statCard('$orderCount', 'My Orders')),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statCard('4.9', 'Rating', showStar: true)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _section('Account Management'),
            _tile(context, Icons.shopping_bag_outlined, 'My Orders', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const OrdersView()));
            }),
            _tile(context, Icons.chat_bubble_outline_rounded, 'Messages / Support Chat', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ChatScreen(otherUserId: 'admin', otherUserName: 'EMARA Support')));
            }),
            _tile(context, Icons.favorite_outline_rounded, 'Saved Items', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const WishlistView()));
            }),
            _tile(context, Icons.list_alt_rounded, 'My Listings', () {}),
            const SizedBox(height: 16),
            _section('Preferences'),
            ListTile(
              leading: const Icon(Icons.language_rounded, color: AppColors.primary),
              title: Text(locale.t('language')),
              subtitle: Text(
                locale.language == AppLanguage.so ? locale.t('somali') 
                : locale.language == AppLanguage.ar ? locale.t('arabic')
                : locale.t('english')
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                  builder: (_) => Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(locale.t('choose_lang'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        _langTile(context, locale, AppLanguage.en, locale.t('english')),
                        _langTile(context, locale, AppLanguage.so, locale.t('somali')),
                        _langTile(context, locale, AppLanguage.ar, locale.t('arabic')),
                      ],
                    ),
                  ),
                );
              },
            ),
            _tile(context, Icons.settings_outlined, 'Settings', () {}),
            _tile(context, Icons.help_outline_rounded, 'Help Center', () {}),
            _tile(context, Icons.chat_bubble_outline_rounded, 'WhatsApp Support (+252611112886)', () {
              WhatsAppLauncher.openWhatsApp();
            }),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OutlinedButton(
                onPressed: () => auth.logout(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  side: const BorderSide(color: Color(0xFFFFEAEA)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  foregroundColor: Colors.red,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Logout',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(title,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondaryLight)),
        ),
      );

  Widget _statCard(String val, String label, {bool showStar = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(val,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w900)),
                if (showStar) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.star_rounded,
                      color: AppColors.primary, size: 18),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondaryLight)),
          ],
        ),
      );

  Widget _tile(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary, size: 22),
          title: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondaryLight, size: 20),
          onTap: onTap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
  Widget _langTile(BuildContext context, LocaleProvider lp, AppLanguage lang, String label) {
    bool selected = lp.language == lang;
    return ListTile(
      title: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      trailing: selected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
      onTap: () {
        lp.setLanguage(lang);
        Navigator.pop(context);
      },
    );
  }
}
