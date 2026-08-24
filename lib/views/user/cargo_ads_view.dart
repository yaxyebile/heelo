import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/cargo_ad.dart';

class CargoAdsView extends StatelessWidget {
  const CargoAdsView({super.key});

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final ads = market.cargoAds;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: RefreshIndicator(
        onRefresh: () => market.refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            // ── Hero Header ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 24,
                  left: 24, right: 24, bottom: 32,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0A0E27), Color(0xFF1A1040)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animated Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFF6B00), Color(0xFFFF9500)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text('CARGO SERVICE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'World\nto Somalia',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'China · Dubai · Turkey · USA iyo adduunka oo dhan\nwaxaan kuu keenaa xilli gaaban oo qiimo jaban',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    // Stats Row
                    Row(
                      children: [
                        _statChip(Icons.public_rounded, 'Adduunka', '50+ Dalal'),
                        const SizedBox(width: 12),
                        _statChip(Icons.speed_rounded, 'Degdeg', '7-21 Maalmood'),
                        const SizedBox(width: 12),
                        _statChip(Icons.verified_rounded, 'Amaan', '100%'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Routes Section ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: const Color(0xFFF8FAFC),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Wadooyinka Rasmiga ah',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF1F2937))),
                    const SizedBox(height: 4),
                    const Text('Halkan ka dooro wadada adiga ku habboon',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    const SizedBox(height: 20),
                    _routeCard(
                      flag: '🇨🇳',
                      country: 'China → Somalia',
                      duration: '15-25 maalmood',
                      desc: 'Guangzhou, Yiwu, Shenzhen — alaabta caalamiga ah, dharka, elektroniksga',
                      color: const Color(0xFFEF4444),
                      badge: 'Ugu Badan',
                    ),
                    const SizedBox(height: 12),
                    _routeCard(
                      flag: '🌍',
                      country: 'World → Somalia',
                      duration: '7-21 maalmood',
                      desc: 'Turkey, Dubai, USA, UK — alaab kasta oo caalamka ka timid',
                      color: const Color(0xFF8B5CF6),
                      badge: 'Caalami',
                    ),
                    const SizedBox(height: 12),
                    _routeCard(
                      flag: '🇦🇪',
                      country: 'Dubai → Somalia',
                      duration: '7-14 maalmood',
                      desc: 'Dubai: alaab tayo sare leh, taleefannada, dheriga, dahab',
                      color: const Color(0xFFFFB800),
                      badge: 'Degdeg',
                    ),
                  ],
                ),
              ),
            ),

            // ── Ads from admin ─────────────────────────────────────────────────
            if (ads.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Container(
                  color: const Color(0xFFF8FAFC),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                  child: const Text('Xayaysiisyada Cargo',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF1F2937))),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _adCard(ads[i]),
                  childCount: ads.length,
                ),
              ),
            ],

            // ── How it works ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: const Color(0xFFF8FAFC),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sidee u Shaqeysaa?',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF1F2937))),
                    const SizedBox(height: 20),
                    _howStep('1', 'Xiriir Nala Samee', 'WhatsApp ama telefoon naga soo wac si aad alaabta u diiwaan geliso.', Icons.phone_rounded),
                    _howStep('2', 'Alaabta Dir', 'Alaabta u dir cinwaankeena dalkii aad ka iibsatay.', Icons.send_rounded),
                    _howStep('3', 'La Socodsii', 'Tracking number kuu diri doonnaa si aad u raacdo.', Icons.gps_fixed_rounded),
                    _howStep('4', 'Soo Qaado', 'Alaabtu marka ay timaado waxaad ka qaadataa xafiiskeena.', Icons.store_rounded),
                  ],
                ),
              ),
            ),

            // ── Contact Banner ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00AA5B), Color(0xFF00D285)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: const Color(0xFF00AA5B).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 36),
                    const SizedBox(height: 12),
                    const Text('Xiriir Hadda!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
                    const SizedBox(height: 6),
                    const Text('Wixii su\'aal ah ama dalbadasho kacsan naga soo wac ama WhatsApp noo dir.',
                        style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.chat_rounded),
                      label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.w900)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF00AA5B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00D285), size: 20),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
            Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _routeCard({
    required String flag, required String country, required String duration,
    required String desc, required Color color, required String badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(country, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1F2937))),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(badge, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10)),
                  ),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFFFF6B00)),
                  const SizedBox(width: 4),
                  Text(duration, style: const TextStyle(fontSize: 12, color: Color(0xFFFF6B00), fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _adCard(CargoAd ad) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ad.imageUrl.isNotEmpty
                  ? Image.network(ad.imageUrl, width: double.infinity, height: 180, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderBox())
                  : _placeholderBox(),
            ),
            // Gradient overlay
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Positioned(
              left: 16, bottom: 16, right: 16,
              child: Text(ad.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, height: 1.3)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderBox() => Container(
    height: 180,
    color: const Color(0xFF1E293B),
    child: const Center(child: Icon(Icons.flight_rounded, color: Color(0xFF475569), size: 48)),
  );

  Widget _howStep(String num, String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00AA5B), Color(0xFF00D285)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(num, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1F2937))),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4)),
              ],
            ),
          ),
          Icon(icon, color: const Color(0xFF00AA5B), size: 22),
        ],
      ),
    );
  }
}
