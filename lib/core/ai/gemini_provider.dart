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
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
      options: Options(headers: {
        'x-goog-api-key': apiKey,
        'Content-Type': 'application/json',
      }),
      data: {
        'system_instruction': {
          'parts': [{'text': systemPrompt}]
        },
        'contents': contents,
        'generationConfig': {
          'maxOutputTokens': 4096,
          'temperature': 0.7,
        },
      },
    );
    final candidates = response.data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      final blockReason = response.data['promptFeedback'];
      throw Exception('تم حظر الرد: $blockReason');
    }
    final parts = candidates[0]['content']['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      throw Exception('لم يتم استلام رد من النموذج');
    }
    return parts[0]['text'] as String;
  }
}
