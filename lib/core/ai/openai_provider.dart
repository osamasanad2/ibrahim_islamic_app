import 'package:dio/dio.dart';
import 'chat_message.dart';
import 'ai_provider.dart';

class OpenAIProvider extends AIProvider {
  final Dio dio;

  OpenAIProvider(this.dio);

  @override
  String get id => 'openai';

  @override
  String get displayName => 'OpenAI';

  @override
  String get defaultModel => 'gpt-3.5-turbo';

  @override
  String get apiKeyLabel => 'مفتاح OpenAI API';

  @override
  bool get needsApiKey => true;

  @override
  List<String> get availableModels => [
        'gpt-3.5-turbo',
        'gpt-4o-mini',
      ];

  @override
  Future<String> generateResponse({
    required List<ChatMessage> messages,
    required String systemPrompt,
    required String model,
    required String apiKey,
  }) async {
    final response = await dio.post(
      'https://api.openai.com/v1/chat/completions',
      options: Options(headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      }),
      data: {
        'model': model,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          ...messages.map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.content,
              }),
        ],
        'max_tokens': 1024,
        'temperature': 0.7,
      },
    );

    final choices = response.data['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw Exception('لم يتم استلام رد من OpenAI');
    }

    final message = choices[0]['message'] as Map<String, dynamic>?;
    if (message == null) {
      throw Exception('استجابة OpenAI غير صالحة');
    }
    return message['content'] as String;
  }
}
