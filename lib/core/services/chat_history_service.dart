import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../ai/chat_session.dart';
import '../ai/chat_message.dart';

class ChatHistoryService {
  static const String _boxName = 'settings';
  static const String _key = 'chat_sessions';
  static const int _maxSessions = 50;

  List<ChatSession> getSessions() {
    final box = Hive.box(_boxName);
    final raw = box.get(_key, defaultValue: <String>[]) as List;
    return raw
        .map((e) => ChatSession.fromJson(json.decode(e as String) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> saveSession(ChatSession session) async {
    final box = Hive.box(_boxName);
    final raw = box.get(_key, defaultValue: <String>[]) as List;
    final list = raw.cast<String>();

    list.removeWhere((e) {
      final s = ChatSession.fromJson(json.decode(e) as Map<String, dynamic>);
      return s.id == session.id;
    });

    list.insert(0, json.encode(session.toJson()));

    if (list.length > _maxSessions) {
      list.removeRange(_maxSessions, list.length);
    }

    await box.put(_key, list);
  }

  Future<void> deleteSession(String id) async {
    final box = Hive.box(_boxName);
    final raw = box.get(_key, defaultValue: <String>[]) as List;
    final list = raw.cast<String>();
    list.removeWhere((e) {
      final s = ChatSession.fromJson(json.decode(e) as Map<String, dynamic>);
      return s.id == id;
    });
    await box.put(_key, list);
  }

  Future<void> clearAll() async {
    final box = Hive.box(_boxName);
    await box.put(_key, <String>[]);
  }

  String generateTitle(List<ChatMessage> messages) {
    if (messages.isEmpty) return 'محادثة جديدة';
    final first = messages.first.content;
    if (first.length > 30) return '${first.substring(0, 30)}...';
    return first;
  }

  ChatSession createSession() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    return ChatSession(
      id: id,
      title: 'محادثة جديدة',
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

final chatHistoryProvider = Provider<ChatHistoryService>((ref) {
  return ChatHistoryService();
});

final chatSessionsProvider = Provider<List<ChatSession>>((ref) {
  final service = ref.watch(chatHistoryProvider);
  return service.getSessions();
});

final currentSessionIdProvider = StateProvider<String?>((ref) => null);

final currentSessionProvider = Provider<ChatSession?>((ref) {
  final id = ref.watch(currentSessionIdProvider);
  if (id == null) return null;
  final sessions = ref.watch(chatSessionsProvider);
  try {
    return sessions.firstWhere((s) => s.id == id);
  } catch (_) {
    return null;
  }
});
