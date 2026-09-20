import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/l10n/app_strings.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_view.dart';
import '../user/main_scaffold.dart';
import '../user/product_details_view.dart';
import '../user/store_profile_view.dart';
import '../user/stores_list_view.dart';
import '../user/departments_view.dart';
import '../user/property_listings_view.dart';
import '../user/technicians_view.dart';
import '../user/restaurants_list_view.dart';
import '../../core/widgets/product_card.dart';
import '../../core/utils/whatsapp_launcher.dart';

class WebLandingPage extends StatefulWidget {
  final VoidCallback? onLaunchApp;
  const WebLandingPage({super.key, this.onLaunchApp});

  @override
  State<WebLandingPage> createState() => _WebLandingPageState();
}

class _WebLandingPageState extends State<WebLandingPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _productsKey = GlobalKey();
  final GlobalKey _storesKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void _openWhatsApp() {
    WhatsAppLauncher.openWhatsApp(message: 'Asc EMARA Web Support');
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openWhatsApp,
        backgroundColor: const Color(0xFF25D366),
        elevation: 8,
        icon: const Icon(Icons.chat_rounded, color: Colors.white),
        label: const Text(
          'Caawinaad 24/7',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // 1. Top Web Navigation Header
            _buildHeader(context, auth, locale, isDesktop),

            // 2. Hero Section
            _buildHero(context, isDesktop),

            // 3. Stats Strip
            _buildStatsStrip(isDesktop),

            // 4. Ecosystem Services Section
            Container(key: _featuresKey, child: _buildServicesGrid(context, isDesktop)),

            // 5. Featured Products Live Marketplace Section
            Container(key: _productsKey, child: _buildLiveMarketplace(context, market, isDesktop)),

            // 6. Top Stores Highlight
            Container(key: _storesKey, child: _buildTopStoresSection(context, market, isDesktop)),

            // 7. Why Choose Us / Platform Trust Section
            Container(key: _aboutKey, child: _buildWhyChooseUs(isDesktop)),

            // 8. Mobile & Web App Download Banner
            _buildAppDownloadBanner(context, isDesktop),

            // 9. Modern Web Footer
            _buildFooter(context, locale, isDesktop),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 1. Header Bar
  // -------------------------------------------------------------
  Widget _buildHeader(BuildContext context, AuthProvider auth, LocaleProvider locale, bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 20,
        vertical: 16,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Row(
            children: [
              // Logo & Brand Name
              GestureDetector(
                onTap: () => _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeOut),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'E',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: const [
                            Text(
                              'EMARA',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'MARKET',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Mogadishu Digital Hub',
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Desktop Navigation Links
              if (isDesktop) ...[
                _navLink('Adeegyada', () => _scrollToSection(_featuresKey)),
                _navLink('Alaabaha', () => _scrollToSection(_productsKey)),
                _navLink('Dukaamada', () => _scrollToSection(_storesKey)),
                _navLink('Naga Mid Ah', () => _scrollToSection(_aboutKey)),
                const SizedBox(width: 24),
              ],

              // Language Switcher
              PopupMenuButton<AppLanguage>(
                initialValue: locale.language,
                onSelected: (lang) => locale.setLanguage(lang),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        locale.language.name.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 18),
                    ],
                  ),
                ),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: AppLanguage.so, child: Text('🇸🇴 Somali')),
                  const PopupMenuItem(value: AppLanguage.en, child: Text('🇬🇧 English')),
                  const PopupMenuItem(value: AppLanguage.ar, child: Text('🇸🇦 Arabic')),
                ],
              ),
              const SizedBox(width: 16),

              // Action Buttons: Open Web App / Login
              if (auth.isAuthenticated) ...[
                ElevatedButton.icon(
                  onPressed: widget.onLaunchApp ?? () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MainScaffold()));
                  },
                  icon: const Icon(Icons.dashboard_rounded, size: 18),
                  label: const Text('Gasho Web App'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ] else ...[
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginView()));
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Soo Gasho', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: widget.onLaunchApp ?? () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MainScaffold()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Fura Web Portal-ka 🚀', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _navLink(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF334155),
        ),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 2. Hero Section
  // -------------------------------------------------------------
  Widget _buildHero(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF0284C7), Color(0xFF0369A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 20,
        vertical: isDesktop ? 80 : 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: isDesktop
              ? Row(
                  children: [
                    Expanded(flex: 6, child: _heroTextContent(context, true)),
                    const SizedBox(width: 48),
                    Expanded(flex: 5, child: _heroVisualMockup(context)),
                  ],
                )
              : Column(
                  children: [
                    _heroTextContent(context, false),
                    const SizedBox(height: 40),
                    _heroVisualMockup(context),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _heroTextContent(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.bolt_rounded, color: Color(0xFFFFD700), size: 18),
              SizedBox(width: 6),
              Text(
                'Barta Midaysan Ee Dukaamada & Adeegyada Mogadishu',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Dukaamayso, Dalbo Adeegyada & Guryaha Si Fudud 🚀',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 48 : 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'EMARA waa madalka casriga ah oo kugu xineysa Dukaamada ugu waaweyn, Maqaayadaha, Kireysiga Guryaha & Dhulalka, Farsamo Yaqaannada, iyo Delivery-ga ugu degdega badan magaalada.',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 18 : 15,
            color: Colors.white.withValues(alpha: 0.88),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 36),
        Wrap(
          spacing: 16,
          runSpacing: 14,
          alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: widget.onLaunchApp ?? () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MainScaffold()));
              },
              icon: const Icon(Icons.rocket_launch_rounded, color: AppColors.primary),
              label: const Text('Biloow Dukaamaysiga Hadda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 6,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _openWhatsApp,
              icon: const Icon(Icons.support_agent_rounded, color: Colors.white),
              label: const Text('Naga la Soo Xiriir'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white, width: 2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _heroVisualMockup(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          // Browser Top Bar Mock
          Row(
            children: [
              Row(
                children: [
                  Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFFF5F56), shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: const [
                      Icon(Icons.lock_rounded, size: 12, color: Colors.white70),
                      SizedBox(width: 6),
                      Text('https://emara.so/marketplace', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Interactive Preview Content Container
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storefront_rounded, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text('EMARA Quick Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Text('LIVE DATA', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                    children: [
                      _quickCategoryTile(Icons.shopping_bag_rounded, 'Dukaamada', '100+ Stores', const Color(0xFF0284C7)),
                      _quickCategoryTile(Icons.restaurant_rounded, 'Maqaayadaha', 'Fast Delivery', const Color(0xFFEA580C)),
                      _quickCategoryTile(Icons.home_rounded, 'Guryaha', 'Rent & Sale', const Color(0xFF16A34A)),
                      _quickCategoryTile(Icons.build_rounded, 'Farsamada', 'Verified Techs', const Color(0xFF9333EA)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MainScaffold()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Booqo Web App-ka All-in-One'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickCategoryTile(IconData icon, String title, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(sub, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 3. Stats Strip
  // -------------------------------------------------------------
  Widget _buildStatsStrip(bool isDesktop) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 20),
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 32,
              runSpacing: 24,
              children: [
                _statCard('500+', 'Dukaamo & Ganacsiyo Registered'),
                _statCard('10,000+', 'Orders oo si guul leh loo gaarsiiyay'),
                _statCard('24/7', 'Adeeg & Delivery Madaala-doon ah'),
                _statCard('4.9★', 'Qiimaynta Macaamiisha Magaalada'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // 4. Services Grid
  // -------------------------------------------------------------
  Widget _buildServicesGrid(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 20,
        vertical: 64,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              _sectionTitle('Adeegyada EMARA', 'Kala dooro qaybaha kala duwan ee platform-ku bixiyo'),
              const SizedBox(height: 48),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isDesktop ? 3 : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: isDesktop ? 1.35 : 1.5,
                children: [
                  _serviceCard(
                    context,
                    icon: Icons.shopping_bag_rounded,
                    color: const Color(0xFF0284C7),
                    title: 'Dukaamada & Marketplace',
                    desc: 'Ka iibso alaabta ugu dambeysay ee elegtarooniga, dharka, iyo guriga dukaamada ugu caansan.',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DepartmentsView())),
                  ),
                  _serviceCard(
                    context,
                    icon: Icons.restaurant_rounded,
                    color: const Color(0xFFEA580C),
                    title: 'Maqaayadaha & Food Delivery',
                    desc: 'Cuntooyinka ugu dhadhanka badan ee Mogadishu oo si degdeg ah kugu soo gaaraya guriga ama xafiiska.',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RestaurantsListView())),
                  ),
                  _serviceCard(
                    context,
                    icon: Icons.home_work_rounded,
                    color: const Color(0xFF16A34A),
                    title: 'Guryaha & Dhulalka',
                    desc: 'Kireyso ama iibso guryo, filooyin, iyo dhulal ammaan ah oo leh dukumiintiyo buuxa.',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PropertyListingsView())),
                  ),
                  _serviceCard(
                    context,
                    icon: Icons.handyman_rounded,
                    color: const Color(0xFF9333EA),
                    title: 'Farsamo Yaqaano',
                    desc: 'Hel koronto yaqaan, tuumbo yaqaan, AC repair, iyo farsamoyaqaano la isku halayn karo.',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TechniciansView())),
                  ),
                  _serviceCard(
                    context,
                    icon: Icons.replay_circle_filled_rounded,
                    color: const Color(0xFF2563EB),
                    title: 'Suuqa Casriga (Second Hand)',
                    desc: 'Iibi ama ka iibso alaabta la isticmaalay si fudud oo ammaan ah.',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MainScaffold(initialTab: 3))),
                  ),
                  _serviceCard(
                    context,
                    icon: Icons.local_shipping_rounded,
                    color: const Color(0xFF059669),
                    title: 'Cargo & Delivery',
                    desc: 'Diris alaabaha degmooyinka iyo gobollada si la isku halayn karo.',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoresListView())),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _serviceCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Text(
                  'Kala dooro',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, color: color, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 5. Live Marketplace Section
  // -------------------------------------------------------------
  Widget _buildLiveMarketplace(BuildContext context, MarketplaceProvider market, bool isDesktop) {
    final prods = market.nonRestaurantProducts.take(8).toList();

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 20,
        vertical: 64,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              _sectionTitle('Alaabaha Safka Hore', 'Booqo alaabooyinka ugu iibsiga badan suuqa EMARA'),
              const SizedBox(height: 40),
              if (prods.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 4 : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: prods.length,
                  itemBuilder: (_, i) => ProductCard(
                    compact: false,
                    product: prods[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductDetailsView(product: prods[i])),
                    ),
                    onAddToCart: () => market.addToCart(prods[i], 1),
                  ),
                ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MainScaffold()));
                },
                icon: const Icon(Icons.grid_view_rounded),
                label: const Text('Dhamaan Alaabaha Eeg'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 6. Top Stores Section
  // -------------------------------------------------------------
  Widget _buildTopStoresSection(BuildContext context, MarketplaceProvider market, bool isDesktop) {
    final stores = market.stores.where((s) => s.isApproved).take(6).toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 20,
        vertical: 64,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              _sectionTitle('Dukaamada La Oggolaaday', 'Ka iibso dukaamada la xaqiijiyay ee platform-ka EMARA'),
              const SizedBox(height: 40),
              if (stores.isEmpty)
                const SizedBox(height: 40)
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 3 : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: stores.length,
                  itemBuilder: (_, i) {
                    final s = stores[i];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoreProfileView(store: s))),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: s.logo.isNotEmpty
                                    ? Image.network(s.logo, width: 56, height: 56, fit: BoxFit.cover)
                                    : Container(width: 56, height: 56, color: AppColors.primary.withValues(alpha: 0.1), child: const Icon(Icons.store_rounded, color: AppColors.primary, size: 28)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB800)),
                                        Text(' ${s.rating.toStringAsFixed(1)} ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        Text(s.isRestaurant ? '• Maqaayada' : '• Dukaanka', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 7. Why Choose Us Section
  // -------------------------------------------------------------
  Widget _buildWhyChooseUs(bool isDesktop) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 20,
        vertical: 64,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              _sectionTitle('Maxaa EMARA Loo Doortaa?', 'Guulaha iyo ammaanada platform-ka ugu weyn Mogadishu'),
              const SizedBox(height: 48),
              Wrap(
                spacing: 32,
                runSpacing: 32,
                alignment: WrapAlignment.center,
                children: [
                  _benefitTile(Icons.shield_outlined, 'Bixinta Lacagaha Oo Ammaan Ah', 'Taageerada WAAFI Pay, EVC Plus, Sahal, iyo Cash on Delivery.'),
                  _benefitTile(Icons.local_shipping_outlined, 'Delivery Madaala-doon Ah', 'Alaabahaaga waxay ku soo gaarayaan waqti kooban.'),
                  _benefitTile(Icons.verified_user_outlined, 'Dukaamo La Xaqiijiyay', 'Dhamaan dukaamada ku jira EMARA waa kuwo sharci ah oo la kormeeray.'),
                  _benefitTile(Icons.headset_mic_outlined, 'Taageero 24/7', 'Kooxdayadu waxay diyaar u tahay inay kugu caawiso wada sheekaysiga WhatsApp.'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefitTile(IconData icon, String title, String desc) {
    return SizedBox(
      width: 260,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 36),
          ),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(desc, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 8. App Download Banner
  // -------------------------------------------------------------
  Widget _buildAppDownloadBanner(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0369A1), Color(0xFF0284C7)],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 20,
        vertical: 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'U Diyaar Ah Mobelka & Web-ka 📲',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Waxaad ka adeegan kartaa Web Browser-kaaga ama waxaad soo download garaysan kartaa Mobile App-ka EMARA.',
                      textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: 32),
                ElevatedButton.icon(
                  onPressed: widget.onLaunchApp ?? () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MainScaffold()));
                  },
                  icon: const Icon(Icons.web_rounded),
                  label: const Text('Fur Web App-ka'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 9. Modern Web Footer
  // -------------------------------------------------------------
  Widget _buildFooter(BuildContext context, LocaleProvider locale, bool isDesktop) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 20,
        vertical: 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('EMARA MARKETPLACE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                        SizedBox(height: 12),
                        Text(
                          'Mogadishu Digital Hub — Dukaamayso, Dalbo Adeegyada & Guryaha Si Fudud oo Ammaan ah.',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  if (isDesktop) ...[
                    const Spacer(),
                    _footerColumn('Qaybaha', ['Dukaamada', 'Maqaayadaha', 'Guryaha', 'Farsamo Yaqaano']),
                    const SizedBox(width: 48),
                    _footerColumn('Xiriirka', ['WhatsApp Support', '+252611112886', 'Mogadishu, Somalia', 'info@emara.so']),
                  ],
                ],
              ),
              const Divider(color: Color(0xFF1E293B), height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('© 2026 EMARA Platform. Dhamaan xuquuqda waa la dhowray.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                  Text('Made with ❤️ for Somalia', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerColumn(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 14),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(item, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
            )),
      ],
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
