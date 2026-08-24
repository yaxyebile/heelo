import 'package:flutter/material.dart';
import '../../views/admin/admin_user_profile_view.dart';
import '../../core/services/supabase_service.dart';

class AdminTechnicianBookingsView extends StatefulWidget {
  const AdminTechnicianBookingsView({super.key});

  @override
  State<AdminTechnicianBookingsView> createState() => _AdminTechnicianBookingsViewState();
}

class _AdminTechnicianBookingsViewState extends State<AdminTechnicianBookingsView> {
  List<Map<String, dynamic>> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await SupabaseService.fetchTechBookings();
    setState(() {
      _bookings = data;
      _loading = false;
    });
  }

  Future<void> _updateStatus(String id, String status) async {
    await SupabaseService.updateTechBookingStatus(id, status);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Dalbashyada Farsamada', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            color: const Color(0xFFF97316),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)))
          : _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_rounded, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('Wali dalbasho lama soo galin', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: const Color(0xFFF97316),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _bookings.length,
                    itemBuilder: (context, i) {
                      final b = _bookings[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF97316).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(b['category'] ?? '', style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.w800, fontSize: 12)),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('Heer ${b['level'] ?? ''}', style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w800, fontSize: 12)),
                                ),
                                const Spacer(),
                                Text(b['price'] ?? '', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFFF97316))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if ((b['user_name'] ?? '').isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.person_rounded, size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(b['user_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700))),
                                  IconButton(
                                    icon: const Icon(Icons.visibility_rounded, color: Color(0xFF2563EB)),
                                    onPressed: () {
                                      final userId = b['user_id'] ?? '';
                                      if (userId.isNotEmpty) {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => AdminUserProfileView(userId: userId)));
                                      }
                                    },
                                  ),
                                ],
                              ),
                            const SizedBox(height: 6),
                            Row(children: [
                              const Icon(Icons.location_on_rounded, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Expanded(child: Text(b['location'] ?? '', style: const TextStyle(color: Colors.black54))),
                            ]),
                            const SizedBox(height: 6),
                            Row(children: [
                              const Icon(Icons.notes_rounded, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Expanded(child: Text(b['details'] ?? '', style: const TextStyle(color: Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis)),
                            ]),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _statusChip(b['status'] ?? 'pending'),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                                  onSelected: (val) => _updateStatus(b['id'], val),
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(value: 'pending',    child: Text('⏳ Sugitaanka')),
                                    const PopupMenuItem(value: 'inprogress', child: Text('🔄 Socda')),
                                    const PopupMenuItem(value: 'done',       child: Text('✅ La Dhamaystiray')),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'done':       color = Colors.green;  label = '✅ La Dhamaystiray'; break;
      case 'inprogress': color = Colors.blue;   label = '🔄 Socda';           break;
      default:           color = Colors.orange; label = '⏳ Sugitaanka';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}
