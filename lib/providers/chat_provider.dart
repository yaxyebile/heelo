import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/services/supabase_service.dart';
import '../core/services/features_service.dart';
import '../models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _loaded = false;
  StreamSubscription? _chatSubscription;

  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;

  /// Loads chat & subscribes to Realtime updates from Supabase.
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    await _loadMessages();
    _subscribeToRealtimeChat();
    _loaded = true;
  }

  void _subscribeToRealtimeChat() {
    _chatSubscription?.cancel();
    try {
      _chatSubscription = SupabaseService.client
          .from('chat_messages')
          .stream(primaryKey: ['id'])
          .order('timestamp', ascending: true)
          .listen(
        (List<Map<String, dynamic>> data) {
          _messages.clear();
          for (final r in data) {
            _messages.add({
              'id': r['id'] as String,
              'senderId': r['sender_id'] as String,
              'receiverId': r['receiver_id'] as String,
              'content': r['content'] as String,
              'timestamp': r['timestamp'] as String,
              'isRead': r['is_read'] as bool? ?? false,
            });
          }
          _messages.sort(
            (a, b) => (a['timestamp'] as String).compareTo(b['timestamp'] as String),
          );
          notifyListeners();
        },
        onError: (err) {
          debugPrint('Realtime chat stream error: $err');
        },
      );
    } catch (e) {
      debugPrint('Error subscribing to chat realtime: $e');
    }
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

    // Optimistically add to local list immediately
    final existingIndex = _messages.indexWhere((m) => m['id'] == msg.id);
    if (existingIndex == -1) {
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

    await SupabaseService.insertChatMessage(msg);

    // Trigger notification to recipient
    try {
      await FeaturesService.createNotification(
        userId: receiverId,
        title: 'Fariin Cusub 💬',
        body: content.length > 50 ? '${content.substring(0, 50)}...' : content,
        type: 'chat',
        relatedId: senderId,
      );
    } catch (e) {
      debugPrint('Chat notification trigger error: $e');
    }
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
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
