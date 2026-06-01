import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final bool rootTab;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.rootTab = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChatProvider>().ensureLoaded();
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() async {
    if (_msgCtrl.text.trim().isEmpty) return;
    final chat = Provider.of<ChatProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    await chat.sendMessage(
      senderId: auth.currentUser!.id,
      receiverId: widget.otherUserId,
      content: _msgCtrl.text.trim(),
    );
    _msgCtrl.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = Provider.of<ChatProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final messages = chat.getConversation(auth.currentUser!.id, widget.otherUserId);

    // No need for post frame callback with reverse: true

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: widget.rootTab ? Colors.white : const Color(0xFF0F172A),
        foregroundColor: widget.rootTab ? const Color(0xFF0F172A) : Colors.white,
        automaticallyImplyLeading: !widget.rootTab,
        elevation: 0,
        title: Row(children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF00AA5B),
            radius: 16,
            child: Text(widget.otherUserName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 10),
          Text(widget.otherUserName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        ]),
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            reverse: true,
            padding: const EdgeInsets.all(20),
            itemCount: messages.length,
            itemBuilder: (context, i) {
              final m = messages.reversed.toList()[i];
              final isMe = m['senderId'] == auth.currentUser!.id;
              return _msgBubble(m['content'], isMe, m['timestamp']);
            },
          ),
        ),
        _inputArea(),
      ]),
    );
  }

  Widget _msgBubble(String content, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFFF6B00) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
          Text(content, style: TextStyle(color: isMe ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(time.substring(11, 16), style: TextStyle(color: isMe ? Colors.white.withOpacity(0.7) : const Color(0xFF94A3B8), fontSize: 10)),
        ]),
      ),
    );
  }

  Widget _inputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)]),
      child: Row(children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(25)),
            child: TextField(
              controller: _msgCtrl,
              decoration: const InputDecoration(hintText: "Type message...", border: InputBorder.none, hintStyle: TextStyle(color: Color(0xFF94A3B8))),
              onSubmitted: (_) => _send(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _send,
          child: Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(color: Color(0xFFFF6B00), shape: BoxShape.circle),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}
