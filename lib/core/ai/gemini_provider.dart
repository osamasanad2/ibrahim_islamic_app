import 'package:dio/dio.dart';
import 'chat_message.dart';
import 'ai_provider.dart';

class GeminiProvider extends AIProvider {
  final Dio dio;

  GeminiProvider(this.dio);

  @override
  String get id => 'gemini';
  @override
  String get displayName => 'Gemini (Google)';
  @override
  String get defaultModel => 'gemini-pro';
  @override
  String get apiKeyLabel => 'مفتاح Gemini API';
  @override
  bool get needsApiKey => true;
  @override
  List<String> get availableModels => ['gemini-pro', 'gemini-1.5-flash', 'gemini-1.5-pro'];

  @override
  Future<String> generateResponse({
    required List<ChatMessage> messages,
    required String systemPrompt,
    required String model,
    required String apiKey,
  }) async {
    final history = messages.map((m) => {
      'parts': [{'text': '${m.isUser ? 'المستخدم' : 'إبراهيم'}: ${m.content}'}]
    }).toList();

    final response = await dio.post(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
      data: {
        'contents': [
          ...history,
          {'parts': [{'text': systemPrompt}]}
        ],
      },
    );
    final candidates = response.data['candidates'] as List;
    return candidates[0]['content']['parts'][0]['text'] as String;
  }
}
