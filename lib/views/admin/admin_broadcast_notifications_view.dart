import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/app_user.dart';
import '../../models/user_role.dart';
import '../../core/services/features_service.dart';

class AdminBroadcastNotificationsView extends StatefulWidget {
  const AdminBroadcastNotificationsView({super.key});

  @override
  State<AdminBroadcastNotificationsView> createState() =>
      _AdminBroadcastNotificationsViewState();
}

class _AdminBroadcastNotificationsViewState
    extends State<AdminBroadcastNotificationsView> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _loading = false;
  String _targetMode = 'all'; // 'all', 'store', 'restaurant', 'user', 'specific'
  AppUser? _selectedUser;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    if (title.isEmpty || body.isEmpty) {
      _snack("Fadlan buuxi cinwaanka iyo fariinta labadaba", isError: true);
      return;
    }

    if (_targetMode == 'specific' && _selectedUser == null) {
      _snack("Fadlan dooro qofka aad rabto inaad u dirto", isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final market = Provider.of<MarketplaceProvider>(context, listen: false);

      if (_targetMode == 'specific') {
        await FeaturesService.createNotification(
          userId: _selectedUser!.id,
          title: title,
          body: body,
          type: 'general',
        );
        _snack("Ogeysiiska waa la gaarsiiyay ${_selectedUser!.name} ✓");
      } else {
        // Broadened Broadcast Target (all, store, restaurant, user)
        final targetId = _targetMode;
        final users = market.users;
        
        // Broadcast to matching users or broadcast group tag
        await FeaturesService.createNotification(
          userId: targetId,
          title: title,
          body: body,
          type: 'broadcast',
        );

        for (final u in users) {
          bool isMatch = false;
          if (_targetMode == 'all') isMatch = true;
          if (_targetMode == 'store' && u.role == UserRole.seller) isMatch = true;
          if (_targetMode == 'restaurant' && u.role == UserRole.restaurant) isMatch = true;
          if (_targetMode == 'user' && u.role == UserRole.user) isMatch = true;

          if (isMatch) {
            await FeaturesService.createNotification(
              userId: u.id,
              title: title,
              body: body,
              type: 'broadcast',
            );
          }
        }
        _snack("Ogeysiiska waa la baahiyay (Target: ${_targetMode.toUpperCase()}) ✓");
      }

      _titleCtrl.clear();
      _bodyCtrl.clear();
      setState(() {
        _selectedUser = null;
      });
    } catch (e) {
      _snack("Khalad ayaa dhacay markii la dirayay: $e", isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF00D285),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final users = market.users;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
        title: const Text(
          "Diri Ogeysiis (Send Alert)",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Diri Ogeysiis Cusub",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1F2937),
              ),
            ),
            const Text(
              "Fariintaadu waxay toos ugu muuqan doontaa dadka loo waday kaliya.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Target selector input
            const Text(
              "Cidda loo dirayo (Target Audience)",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _targetChip('all', '👥 Dhammaan'),
                _targetChip('store', '🛍️ Dukaamada'),
                _targetChip('restaurant', '🍔 Maqaayadaha'),
                _targetChip('user', '👤 Macaamiisha'),
                _targetChip('specific', '🎯 Qof Gaar Ah'),
              ],
            ),
            const SizedBox(height: 20),

            // Dropdown to pick user if Specific User is selected
            if (_targetMode == 'specific') ...[
              const Text(
                "Dooro Isticmaalaha (Select User)",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<AppUser?>(
                    value: _selectedUser,
                    isExpanded: true,
                    hint: const Text(
                      "Macaamiisha ka dooro liiska...",
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                    items: users.map((u) {
                      return DropdownMenuItem<AppUser?>(
                        value: u,
                        child: Text(
                          "${u.name} (${u.email})",
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedUser = val;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Title field
            const Text(
              "Cinwaanka (Notification Title)",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                hintText: "Tusaale: Daabacid cusub ama War weyn!",
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF1F2937), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Message text field
            const Text(
              "Fariinta (Notification Message)",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bodyCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Halkan ku qor fariintaada oo faahfaahsan...",
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF1F2937), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            GestureDetector(
              onTap: _loading ? null : _submit,
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F2937), Color(0xFFD84315)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Center(
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          "Diri Ogeysiiska (Send Alert)",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _targetChip(String mode, String label) {
    final isSelected = _targetMode == mode;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12,
          color: isSelected ? Colors.white : const Color(0xFF1F2937),
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF1F2937),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
        ),
      ),
      onSelected: (val) {
        if (val) {
          setState(() {
            _targetMode = mode;
          });
        }
      },
    );
  }
}
