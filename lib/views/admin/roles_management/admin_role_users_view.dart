import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/marketplace_provider.dart';
import '../../../models/user_role.dart';
import '../../../models/app_user.dart';
import 'admin_role_detail_view.dart';

class AdminRoleUsersView extends StatefulWidget {
  final UserRole role;
  const AdminRoleUsersView({super.key, required this.role});

  @override
  State<AdminRoleUsersView> createState() => _AdminRoleUsersViewState();
}

class _AdminRoleUsersViewState extends State<AdminRoleUsersView> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  (Color, Color, IconData, String) _roleTheme() {
    switch (widget.role) {
      case UserRole.admin:
        return (const Color(0xFFFFB800), const Color(0xFF2D1F00), Icons.shield_rounded, 'Admin');
      case UserRole.seller:
        return (const Color(0xFF00D285), const Color(0xFF002D1A), Icons.storefront_rounded, 'Sellers');
      case UserRole.delivery:
        return (const Color(0xFF8B5CF6), const Color(0xFF1A0D2D), Icons.delivery_dining_rounded, 'Delivery Staff');
      default:
        return (const Color(0xFF64748B), const Color(0xFF1E293B), Icons.person_rounded, 'Users');
    }
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final theme = _roleTheme();
    final color = theme.$1;
    final bg = theme.$2;
    final icon = theme.$3;
    final title = theme.$4;

    List<AppUser> users = market.users
        .where((u) => u.role == widget.role)
        .toList();

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      users = users
          .where((u) =>
              u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q))
          .toList();
    }

    final active = users.where((u) => !u.isBanned).length;
    final banned = users.where((u) => u.isBanned).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Stats Banner ─────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(label: 'Total',  value: users.length, color: color),
                Container(width: 1, height: 30, color: Colors.white12),
                _StatItem(label: 'Active', value: active,       color: const Color(0xFF00D285)),
                Container(width: 1, height: 30, color: Colors.white12),
                _StatItem(label: 'Banned', value: banned,       color: const Color(0xFFEF4444)),
              ],
            ),
          ),

          // ── Search ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search by name or email...',
                  hintStyle: const TextStyle(color: Color(0xFF4B5563)),
                  prefixIcon: Icon(Icons.search_rounded, color: color, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Color(0xFF4B5563)),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: users.isEmpty
                ? _EmptyState(color: color, icon: icon, title: title)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                    physics: const BouncingScrollPhysics(),
                    itemCount: users.length,
                    itemBuilder: (_, i) => _UserCard(
                      user: users[i],
                      color: color,
                      icon: icon,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminRoleDetailView(user: users[i]),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── STAT ITEM ─────────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ── USER CARD ─────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final AppUser user;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _UserCard({required this.user, required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context, listen: false);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: user.isBanned
                ? const Color(0xFFEF4444).withOpacity(0.3)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: user.isBanned
                        ? const Color(0xFFEF4444).withOpacity(0.15)
                        : color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (user.name.isNotEmpty ? user.name[0] : '?').toUpperCase(),
                      style: TextStyle(
                        color: user.isBanned ? const Color(0xFFEF4444) : color,
                        fontWeight: FontWeight.w900, fontSize: 20,
                      ),
                    ),
                  ),
                ),
                if (user.isBanned)
                  Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                      child: const Icon(Icons.block_rounded, size: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
                  const SizedBox(height: 3),
                  Text(user.email, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis),
                  if (user.phone != null && user.phone!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(user.phone!, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8), fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: !user.isBanned,
                    activeColor: const Color(0xFF00D285),
                    inactiveThumbColor: const Color(0xFFEF4444),
                    inactiveTrackColor: const Color(0xFFEF4444).withOpacity(0.3),
                    onChanged: (active) => market.setUserBanned(user.id, !active),
                  ),
                ),
                Text(
                  user.isBanned ? 'Banned' : 'Active',
                  style: TextStyle(
                    fontSize: 10,
                    color: user.isBanned ? const Color(0xFFEF4444) : const Color(0xFF00D285),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── EMPTY STATE ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  const _EmptyState({required this.color, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 48),
          ),
          const SizedBox(height: 20),
          Text('No $title Found', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white70)),
          const SizedBox(height: 8),
          const Text('Add staff members using the\n"Add Staff" button', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
        ],
      ),
    );
  }
}
