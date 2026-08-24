import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/marketplace_provider.dart';
import '../../../models/app_user.dart';
import '../../../models/user_role.dart';

class AdminRoleDetailView extends StatelessWidget {
  final AppUser user;
  const AdminRoleDetailView({super.key, required this.user});

  (Color, Color, IconData, String) _roleTheme() {
    switch (user.role) {
      case UserRole.admin:
        return (const Color(0xFFFFB800), const Color(0xFF2D1F00), Icons.shield_rounded, 'Admin');
      case UserRole.seller:
        return (const Color(0xFF00D285), const Color(0xFF002D1A), Icons.storefront_rounded, 'Seller');
      case UserRole.delivery:
        return (const Color(0xFF8B5CF6), const Color(0xFF1A0D2D), Icons.delivery_dining_rounded, 'Delivery');
      default:
        return (const Color(0xFF64748B), const Color(0xFF1E293B), Icons.person_rounded, 'User');
    }
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final theme = _roleTheme();
    final color = theme.$1;
    final bg = theme.$2;
    final icon = theme.$3;
    final roleLabel = theme.$4;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF0A0E1A),
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileHeader(
                user: user, color: color, bg: bg,
                icon: icon, roleLabel: roleLabel,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoSection(user: user, color: color),
                  const SizedBox(height: 24),
                  _StatusCard(user: user, market: market, color: color),
                  const SizedBox(height: 24),
                  _ActionsSection(user: user, market: market, color: color),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── PROFILE HEADER ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final AppUser user;
  final Color color, bg;
  final IconData icon;
  final String roleLabel;

  const _ProfileHeader({
    required this.user, required this.color, required this.bg,
    required this.icon, required this.roleLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F2937), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 60, left: 0, right: 0,
            child: Center(
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.12)),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 20, spreadRadius: 4)],
                    ),
                    child: Center(
                      child: Text(
                        (user.name.isNotEmpty ? user.name[0] : '?').toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 36),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: color, size: 14),
                        const SizedBox(width: 6),
                        Text(roleLabel, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13)),
                        if (user.isBanned) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('BANNED', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w900, fontSize: 10)),
                          ),
                        ],
                      ],
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
}

// ── INFO SECTION ──────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  final AppUser user;
  final Color color;
  const _InfoSection({required this.user, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account Info', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5)),
          const SizedBox(height: 16),
          _InfoRow(icon: Icons.email_outlined,        label: 'Email',   value: user.email,                               color: color),
          if (user.phone != null && user.phone!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.phone_outlined,      label: 'Phone',   value: user.phone!,                              color: color),
          ],
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.fingerprint_rounded,   label: 'User ID', value: '${user.id.substring(0, 18)}...',        color: color),
          if (user.storeId != null) ...[
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.store_mall_directory_rounded, label: 'Store ID', value: '${user.storeId!.substring(0, 18)}...', color: color),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _InfoRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
            Text(value, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}

// ── STATUS CARD ───────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final AppUser user;
  final MarketplaceProvider market;
  final Color color;

  const _StatusCard({required this.user, required this.market, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: user.isBanned ? const Color(0xFFEF4444).withOpacity(0.3) : const Color(0xFF00D285).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: user.isBanned ? const Color(0xFFEF4444).withOpacity(0.15) : const Color(0xFF00D285).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              user.isBanned ? Icons.block_rounded : Icons.check_circle_rounded,
              color: user.isBanned ? const Color(0xFFEF4444) : const Color(0xFF00D285),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.isBanned ? 'Account Banned' : 'Account Active',
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w900,
                    color: user.isBanned ? const Color(0xFFEF4444) : const Color(0xFF00D285),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user.isBanned
                      ? 'This user cannot login or perform any actions'
                      : 'This user has full access to their role permissions',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Switch(
            value: !user.isBanned,
            activeColor: const Color(0xFF00D285),
            inactiveThumbColor: const Color(0xFFEF4444),
            inactiveTrackColor: const Color(0xFFEF4444).withOpacity(0.3),
            onChanged: (active) => market.setUserBanned(user.id, !active),
          ),
        ],
      ),
    );
  }
}

// ── ACTIONS SECTION ───────────────────────────────────────────────────────────

class _ActionsSection extends StatelessWidget {
  final AppUser user;
  final MarketplaceProvider market;
  final Color color;

  const _ActionsSection({required this.user, required this.market, required this.color});

  void _confirmBanToggle(BuildContext context) {
    final willBan = !user.isBanned;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          willBan ? 'Ban User?' : 'Unban User?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: Text(
          willBan
              ? 'This will prevent "${user.name}" from accessing the system.'
              : 'This will restore "${user.name}"\'s access to the system.',
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              market.setUserBanned(user.id, willBan);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: willBan ? const Color(0xFFEF4444) : const Color(0xFF00D285),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(willBan ? 'Yes, Ban' : 'Yes, Unban', style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ACTIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF4B5563), letterSpacing: 1.2)),
        const SizedBox(height: 12),
        _ActionTile(
          icon: user.isBanned ? Icons.lock_open_rounded : Icons.block_rounded,
          label: user.isBanned ? 'Unban User' : 'Ban User',
          sublabel: user.isBanned
              ? 'Restore access to this account'
              : 'Block this account from login',
          color: user.isBanned ? const Color(0xFF00D285) : const Color(0xFFEF4444),
          onTap: () => _confirmBanToggle(context),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label, sublabel;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.sublabel, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
                  const SizedBox(height: 2),
                  Text(sublabel, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5), size: 18),
          ],
        ),
      ),
    );
  }
}
