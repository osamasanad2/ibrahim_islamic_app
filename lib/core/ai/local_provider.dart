import 'chat_message.dart';
import 'ai_provider.dart';

class LocalProvider extends AIProvider {
  @override
  String get id => 'local';
  @override
  String get displayName => 'Local (مجاني)';
  @override
  String get defaultModel => 'local';
  @override
  String get apiKeyLabel => '';
  @override
  bool get needsApiKey => false;
  @override
  List<String> get availableModels => ['local'];

  @override
  Future<String> generateResponse({
    required List<ChatMessage> messages,
    required String systemPrompt,
    required String model,
    required String apiKey,
  }) async {
    // Very small local fallback: simple rule-based replies for offline/free use.
    final lastUser = messages.lastWhere((m) => m.isUser, orElse: () => messages.isNotEmpty ? messages.last : ChatMessage(content: '', isUser: true, timestamp: DateTime.now()));
    final text = lastUser.content.toLowerCase();

    if (text.contains('مرحبا') || text.contains('السلام') || text.contains('hello')) {
      return 'وعليكم السلام! كيف أستطيع مساعدتك اليوم؟';
    }
    if (text.contains('?') || text.contains('؟')) {
      return 'سؤال جيد — للأسف هذا المزود المحلي يعطي ردودًا تجريبية فقط.';
    }

    // Fallback: echo with short reply
    final echo = text.length > 120 ? '${text.substring(0, 120)}...' : text;
    if (echo.trim().isEmpty) return 'مرحبا! هذا رد تجريبي من الموفر المحلي.';
    return 'رد تجريبي: $echo';
  }
}
