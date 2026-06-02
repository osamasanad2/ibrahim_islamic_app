import 'package:dio/dio.dart';
import 'chat_message.dart';
import 'ai_provider.dart';

class TogetherProvider extends AIProvider {
  final Dio dio;

  TogetherProvider(this.dio);

  @override
  String get id => 'together';
  @override
  String get displayName => 'Together AI (النماذج المفتوحة)';
  @override
  String get defaultModel => 'Qwen/Qwen2.5-72B-Instruct-Turbo';
  @override
  String get apiKeyLabel => 'مفتاح Together API';
  @override
  bool get needsApiKey => true;
  @override
  List<String> get availableModels => [
    'Qwen/Qwen2.5-72B-Instruct-Turbo',
    'Qwen/Qwen2.5-32B-Instruct',
    'meta-llama/Llama-3.3-70B-Instruct-Turbo',
    'meta-llama/Llama-3.1-8B-Instruct-Turbo',
    'mistralai/Mixtral-8x22B-Instruct-v0.1',
    'deepseek-ai/DeepSeek-R1',
  ];

  @override
  Future<String> generateResponse({
    required List<ChatMessage> messages,
    required String systemPrompt,
    required String model,
    required String apiKey,
  }) async {
    final response = await dio.post(
      'https://api.together.xyz/v1/chat/completions',
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
        'max_tokens': 2048,
      },
    );
    return response.data['choices'][0]['message']['content'] as String;
  }
}
