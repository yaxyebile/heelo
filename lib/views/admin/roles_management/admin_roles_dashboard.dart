import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/marketplace_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/user_role.dart';
import 'admin_role_users_view.dart';
import 'admin_role_create_view.dart';

class AdminRolesDashboard extends StatelessWidget {
  const AdminRolesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);

    // Users excluding the 'user' role
    final managedUsers = market.users
        .where((u) => u.role != UserRole.user)
        .toList();

    final adminCount   = managedUsers.where((u) => u.role == UserRole.admin).length;
    final sellerCount  = managedUsers.where((u) => u.role == UserRole.seller).length;
    final delivCount   = managedUsers.where((u) => u.role == UserRole.delivery).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar ──────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF0A0E1A),
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: _HeaderBg(
                adminCount: adminCount,
                sellerCount: sellerCount,
                delivCount: delivCount,
              ),
            ),
            title: const Text(
              'Roles Management',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _GlassButton(
                  icon: Icons.person_add_rounded,
                  label: 'New',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminRoleCreateView(),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Body ────────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Total Badge ──────────────────────────────────────────
                  _TotalBadge(total: managedUsers.length),
                  const SizedBox(height: 28),

                  // ── Role Cards ───────────────────────────────────────────
                  const _SectionLabel('Roles Overview'),
                  const SizedBox(height: 14),
                  _RoleCardGrid(
                    adminCount: adminCount,
                    sellerCount: sellerCount,
                    delivCount: delivCount,
                  ),
                  const SizedBox(height: 32),

                  // ── Quick Access ─────────────────────────────────────────
                  const _SectionLabel('Manage by Role'),
                  const SizedBox(height: 14),
                  _RoleNavTile(
                    role: UserRole.admin,
                    label: 'Admins',
                    sublabel: '$adminCount accounts',
                    icon: Icons.shield_rounded,
                    gradient: const [Color(0xFFFFB800), Color(0xFFFF6B00)],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminRoleUsersView(
                          role: UserRole.admin,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _RoleNavTile(
                    role: UserRole.seller,
                    label: 'Sellers',
                    sublabel: '$sellerCount accounts',
                    icon: Icons.storefront_rounded,
                    gradient: const [Color(0xFF00D285), Color(0xFF059669)],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminRoleUsersView(
                          role: UserRole.seller,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _RoleNavTile(
                    role: UserRole.delivery,
                    label: 'Delivery Staff',
                    sublabel: '$delivCount accounts',
                    icon: Icons.delivery_dining_rounded,
                    gradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminRoleUsersView(
                          role: UserRole.delivery,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Recent Staff ─────────────────────────────────────────
                  if (managedUsers.isNotEmpty) ...[
                    const _SectionLabel('All Staff Members'),
                    const SizedBox(height: 14),
                    ...managedUsers
                        .take(8)
                        .map((u) => _StaffTile(user: u)),
                    if (managedUsers.length > 8)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Center(
                          child: Text(
                            '+ ${managedUsers.length - 8} more members',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),

      // ── FAB ─────────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminRoleCreateView()),
        ),
        backgroundColor: const Color(0xFFFF6B00),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          'Add Staff',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        elevation: 8,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER BACKGROUND
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderBg extends StatelessWidget {
  final int adminCount, sellerCount, delivCount;
  const _HeaderBg({
    required this.adminCount,
    required this.sellerCount,
    required this.delivCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F2937), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF6B00).withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(0.08),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 70, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MiniStat(label: 'Admins',  value: adminCount,  color: const Color(0xFFFFB800)),
                  _MiniDivider(),
                  _MiniStat(label: 'Sellers', value: sellerCount, color: const Color(0xFF00D285)),
                  _MiniDivider(),
                  _MiniStat(label: 'Drivers', value: delivCount,  color: const Color(0xFF8B5CF6)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white60, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _MiniDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 40, color: Colors.white12);
}

// ─────────────────────────────────────────────────────────────────────────────
// TOTAL BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _TotalBadge extends StatelessWidget {
  final int total;
  const _TotalBadge({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF1F2937)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B00).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.manage_accounts_rounded, color: Color(0xFFFF6B00), size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total Staff Members',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 2),
                const Text(
                  'All roles excluding regular users',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16, fontWeight: FontWeight.w900,
        color: Colors.white70, letterSpacing: 0.5,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROLE CARD GRID
// ─────────────────────────────────────────────────────────────────────────────

class _RoleCardGrid extends StatelessWidget {
  final int adminCount, sellerCount, delivCount;
  const _RoleCardGrid({
    required this.adminCount,
    required this.sellerCount,
    required this.delivCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _RoleCard(icon: Icons.shield_rounded,          label: 'Admin',    count: adminCount,  color: const Color(0xFFFFB800), bg: const Color(0xFF2D1F00))),
        const SizedBox(width: 12),
        Expanded(child: _RoleCard(icon: Icons.storefront_rounded,      label: 'Seller',   count: sellerCount, color: const Color(0xFF00D285), bg: const Color(0xFF002D1A))),
        const SizedBox(width: 12),
        Expanded(child: _RoleCard(icon: Icons.delivery_dining_rounded, label: 'Delivery', count: delivCount,  color: const Color(0xFF8B5CF6), bg: const Color(0xFF1A0D2D))),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final Color bg;

  const _RoleCard({
    required this.icon, required this.label,
    required this.count, required this.color, required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text('$count', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROLE NAV TILE
// ─────────────────────────────────────────────────────────────────────────────

class _RoleNavTile extends StatelessWidget {
  final UserRole role;
  final String label, sublabel;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _RoleNavTile({
    required this.role, required this.label, required this.sublabel,
    required this.icon, required this.gradient, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gradient.first.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 3),
                  Text(sublabel, style: TextStyle(fontSize: 12, color: gradient.first, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: gradient.first.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_forward_ios_rounded, color: gradient.first, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAFF TILE
// ─────────────────────────────────────────────────────────────────────────────

class _StaffTile extends StatelessWidget {
  final dynamic user;
  const _StaffTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final roleData = _roleInfo(user.role);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: roleData.$2.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (user.name.isNotEmpty ? user.name[0] : '?').toUpperCase(),
                style: TextStyle(color: roleData.$2, fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
                const SizedBox(height: 2),
                Text(user.email, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: roleData.$2.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: roleData.$2.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(roleData.$1, color: roleData.$2, size: 12),
                const SizedBox(width: 4),
                Text(roleData.$3, style: TextStyle(color: roleData.$2, fontSize: 11, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          if (user.isBanned)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.block_rounded, color: Color(0xFFEF4444), size: 12),
              ),
            ),
        ],
      ),
    );
  }

  (IconData, Color, String) _roleInfo(UserRole role) {
    switch (role) {
      case UserRole.admin:    return (Icons.shield_rounded,          const Color(0xFFFFB800), 'Admin');
      case UserRole.seller:   return (Icons.storefront_rounded,      const Color(0xFF00D285), 'Seller');
      case UserRole.delivery: return (Icons.delivery_dining_rounded, const Color(0xFF8B5CF6), 'Driver');
      default:                return (Icons.person_rounded,          const Color(0xFF64748B), 'User');
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GLASS BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GlassButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
