import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/services/supabase_service.dart';
import '../models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _loaded = false;

  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;

  /// Loads chat only when user opens Messages/admin chat (not at app start).
  Future<void> ensureLoaded() async {
    if (_loaded || _isLoading) return;
    await _loadMessages();
    _loaded = true;
  }

  Future<void> _loadMessages() async {
    _isLoading = true;
    notifyListeners();
    try {
      final list = await SupabaseService.fetchChatMessages();
      _messages.clear();
      for (final m in list) {
        _messages.add({
          'id': m.id,
          'senderId': m.senderId,
          'receiverId': m.receiverId,
          'content': m.content,
          'timestamp': m.timestamp.toIso8601String(),
          'isRead': m.isRead,
        });
      }
      _messages.sort(
        (a, b) => (a['timestamp'] as String).compareTo(b['timestamp'] as String),
      );
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _loaded = false;
    await ensureLoaded();
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    final msg = ChatMessage(
      id: const Uuid().v4(),
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
    );

    await SupabaseService.insertChatMessage(msg);

    _messages.add({
      'id': msg.id,
      'senderId': msg.senderId,
      'receiverId': msg.receiverId,
      'content': msg.content,
      'timestamp': msg.timestamp.toIso8601String(),
      'isRead': false,
    });
    notifyListeners();
  }

  List<Map<String, dynamic>> getConversation(String uid1, String uid2) {
    return _messages
        .where((m) {
          final s = m['senderId'];
          final r = m['receiverId'];
          return (s == uid1 && r == uid2) || (s == uid2 && r == uid1);
        })
        .toList()
      ..sort(
        (a, b) => (a['timestamp'] as String).compareTo(b['timestamp'] as String),
      );
  }

  List<String> getChatPartners(String userId) {
    final partnerLastMsgTime = <String, DateTime>{};

    for (var m in _messages) {
      final s = m['senderId'] as String;
      final r = m['receiverId'] as String;
      final time = DateTime.parse(m['timestamp'] as String);

      String? partnerId;
      if (s == userId) {
        partnerId = r;
      } else if (r == userId) {
        partnerId = s;
      }

      if (partnerId != null) {
        if (partnerLastMsgTime[partnerId] == null ||
            time.isAfter(partnerLastMsgTime[partnerId]!)) {
          partnerLastMsgTime[partnerId] = time;
        }
      }
    }

    final sortedPartners = partnerLastMsgTime.keys.toList()
      ..sort((a, b) => partnerLastMsgTime[b]!.compareTo(partnerLastMsgTime[a]!));

    return sortedPartners;
  }
}
