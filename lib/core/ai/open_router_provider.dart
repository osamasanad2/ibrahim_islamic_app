import 'package:dio/dio.dart';
import 'chat_message.dart';
import 'ai_provider.dart';

class OpenRouterProvider extends AIProvider {
  final Dio dio;

  OpenRouterProvider(this.dio);

  @override
  String get id => 'openrouter';
  @override
  String get displayName => 'OpenRouter (النماذج المفتوحة)';
  @override
  String get defaultModel => 'qwen/qwen-2.5-72b-instruct';
  @override
  String get apiKeyLabel => 'مفتاح OpenRouter API';
  @override
  bool get needsApiKey => true;
  @override
  List<String> get availableModels => [
    'qwen/qwen-2.5-72b-instruct',
    'qwen/qwen-2.5-32b-instruct',
    'meta-llama/llama-3.1-70b-instruct',
    'meta-llama/llama-3.1-8b-instruct',
    'mistralai/mistral-7b-instruct',
    'deepseek/deepseek-r1',
  ];

  @override
  Future<String> generateResponse({
    required List<ChatMessage> messages,
    required String systemPrompt,
    required String model,
    required String apiKey,
  }) async {
    final response = await dio.post(
      'https://openrouter.ai/api/v1/chat/completions',
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
      },
    );
    return response.data['choices'][0]['message']['content'] as String;
  }
}
