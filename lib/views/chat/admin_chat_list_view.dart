import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/user_role.dart';
import 'chat_screen.dart';

class AdminChatListView extends StatefulWidget {
  const AdminChatListView({super.key});

  @override
  State<AdminChatListView> createState() => _AdminChatListViewState();
}

class _AdminChatListViewState extends State<AdminChatListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChatProvider>().ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = Provider.of<ChatProvider>(context);
    final market = Provider.of<MarketplaceProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final me = auth.currentUser!;
    
    final partnerIds = chat.getChatPartners(me.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text("Support Center", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true, elevation: 0,
      ),
      body: partnerIds.isEmpty
        ? _emptyState()
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: partnerIds.length,
            itemBuilder: (context, i) {
              final pid = partnerIds[i];
              final conv = chat.getConversation(me.id, pid);
              if (conv.isEmpty) return const SizedBox();
              
              final user = market.users.firstWhere((u) => u.id == pid, orElse: () => market.users.first);
              final lastMsg = conv.last;
              
              return _chatTile(context, user, lastMsg);
            },
          ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF6B00),
        child: const Icon(Icons.message_rounded, color: Colors.white),
        onPressed: () => _showNewChatDialog(context, market),
      ),
    );
  }

  Widget _emptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.chat_bubble_outline_rounded, size: 80, color: const Color(0xFFCBD5E1)),
      const SizedBox(height: 20),
      const Text("No active conversations", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700, fontSize: 18)),
      const SizedBox(height: 8),
      const Text("Start a chat with a Seller or User", style: TextStyle(color: Color(0xFF94A3B8))),
    ]));
  }

  Widget _chatTile(BuildContext context, dynamic user, Map<String, dynamic> last) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(otherUserId: user.id, otherUserName: user.name))),
        leading: CircleAvatar(
          backgroundColor: _roleColor(user.role).withOpacity(0.15),
          child: Icon(_roleIcon(user.role), color: _roleColor(user.role), size: 20),
        ),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(last['content'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B))),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(last['timestamp'].substring(11, 16), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
          const SizedBox(height: 4),
          if (!(last['isRead'] as bool))
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFF6B00), shape: BoxShape.circle)),
        ]),
      ),
    );
  }

  Color _roleColor(UserRole r) {
    switch (r) {
      case UserRole.seller: return const Color(0xFFFF6B00);
      case UserRole.delivery: return const Color(0xFF8B5CF6);
      default: return const Color(0xFF3B82F6);
    }
  }

  IconData _roleIcon(UserRole r) {
    switch (r) {
      case UserRole.seller: return Icons.storefront_rounded;
      case UserRole.delivery: return Icons.delivery_dining_rounded;
      default: return Icons.person_rounded;
    }
  }

  void _showNewChatDialog(BuildContext context, MarketplaceProvider market) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        final users = market.users.where((u) => u.role != UserRole.admin).toList();
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Start New Message", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, i) {
                  final u = users[i];
                  return ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.grey.shade100, child: Text(u.name[0])),
                    title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(otherUserId: u.id, otherUserName: u.name)));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
