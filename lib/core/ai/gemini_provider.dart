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
  String get defaultModel => 'gemini-2.0-flash';
  @override
  String get apiKeyLabel => 'مفتاح Gemini API';
  @override
  bool get needsApiKey => true;
  @override
  List<String> get availableModels => [
    'gemini-2.0-flash',
    'gemini-2.0-flash-lite',
    'gemini-1.5-flash',
    'gemini-1.5-pro',
  ];

  @override
  Future<String> generateResponse({
    required List<ChatMessage> messages,
    required String systemPrompt,
    required String model,
    required String apiKey,
  }) async {
    final contents = messages.map((m) => {
      'role': m.isUser ? 'user' : 'model',
      'parts': [{'text': m.content}]
    }).toList();

    final response = await dio.post(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
      data: {
        'system_instruction': {
          'parts': [{'text': systemPrompt}]
        },
        'contents': contents,
      },
    );
    final candidates = response.data['candidates'] as List;
    return candidates[0]['content']['parts'][0]['text'] as String;
  }
}
