import '../../core/utils/whatsapp_launcher.dart';

class CargoAdDetailView extends StatelessWidget {
  final CargoAd ad;
  const CargoAdDetailView({super.key, required this.ad});

  Future<void> _openWhatsApp(BuildContext context) async {
    final phone = ad.phone.replaceAll(RegExp(r'[^\d]'), '');
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telefoon lama dhisin xayeysiiskan')),
      );
      return;
    }
    await WhatsAppLauncher.openWhatsApp(phone: phone, message: 'Asc EMARA Cargo Inquiry');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Image App Bar ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF0A0E27),
            foregroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: ad.imageUrl.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          ad.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        ),
                        // Dark gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF0A0E27).withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : _placeholder(),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF6B00), Color(0xFFFF9500)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text('CARGO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    ad.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1F2937),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Date
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 6),
                      Text(
                        '${ad.createdAt.day}/${ad.createdAt.month}/${ad.createdAt.year}',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                    ],
                  ),

                  // Description
                  if (ad.description.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Faahfaahin',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF1F2937))),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        ad.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF374151),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // ── What we offer row ────────────────────────────────
                  const Text('Waxaan kuu Bixinaa',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF1F2937))),
                  const SizedBox(height: 14),
                  _featureRow(Icons.verified_rounded, 'Alaab Amaan', 'Alaabta si amaan ah ayaan u keeninaa'),
                  _featureRow(Icons.speed_rounded, 'Degdeg', 'Wakhtiga ugu gaaban ee suurogalka ah'),
                  _featureRow(Icons.price_check_rounded, 'Qiimo Jaban', 'Qiimaha ugu fiican suuqa'),
                  _featureRow(Icons.gps_fixed_rounded, 'Tracking', 'Raadraac alaabta meel walba'),

                  const SizedBox(height: 40),

                  // ── WhatsApp Button ──────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF25D366).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _openWhatsApp(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat_rounded, color: Colors.white, size: 26),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('WhatsApp noo Dir',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                                  if (ad.phone.isNotEmpty)
                                    Text(ad.phone,
                                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFF1E293B),
        child: const Center(child: Icon(Icons.flight_rounded, color: Color(0xFF475569), size: 64)),
      );

  Widget _featureRow(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF00D285).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF00AA5B), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1F2937))),
                Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
