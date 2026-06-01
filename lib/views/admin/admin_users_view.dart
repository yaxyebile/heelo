import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';

class AdminUsersView extends StatelessWidget {
  const AdminUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: market.users.length,
        itemBuilder: (_, i) {
          final u = market.users[i];
          return Card(
            child: SwitchListTile(
              title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('${u.role.name} • ${u.email}'),
              value: !u.isBanned,
              activeColor: const Color(0xFF00AA5B),
              onChanged: (active) => market.setUserBanned(u.id, !active),
            ),
          );
        },
      ),
    );
  }
}
