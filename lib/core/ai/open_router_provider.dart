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
  String get defaultModel => 'qwen/qwen-2.5-72b-instruct:free';
  @override
  String get apiKeyLabel => 'مفتاح OpenRouter API';
  @override
  bool get needsApiKey => true;
  @override
  List<String> get availableModels => [
    'google/gemini-2.0-flash-exp:free',
    'google/gemini-2.0-flash-lite-preview-02-05:free',
    'meta-llama/llama-3.1-8b-instruct:free',
    'meta-llama/llama-3.3-70b-instruct:free',
    'qwen/qwen-2.5-72b-instruct:free',
    'mistralai/mistral-7b-instruct:free',
    'deepseek/deepseek-r1:free',
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
