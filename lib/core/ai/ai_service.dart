import 'package:dio/dio.dart';
import 'ai_provider.dart';
import 'chat_message.dart';
import 'gemini_provider.dart';
import 'open_router_provider.dart';
import 'together_provider.dart';
import 'local_provider.dart';
import 'openai_provider.dart';

class AIService {
  final Dio dio;
  final Map<String, AIProvider> _providers = {};

  AIService(this.dio);

  AIProvider getProvider(String id) {
    if (_providers.isEmpty) {
      _providers['local'] = LocalProvider();
      _providers['gemini'] = GeminiProvider(dio);
      _providers['openrouter'] = OpenRouterProvider(dio);
      _providers['together'] = TogetherProvider(dio);
      _providers['openai'] = OpenAIProvider(dio);
    }
    return _providers[id]!;
  }

  List<AIProvider> get allProviders => _providers.values.toList()
    ..clear()
    ..addAll([
      LocalProvider(),
      GeminiProvider(dio),
      OpenRouterProvider(dio),
      TogetherProvider(dio),
      OpenAIProvider(dio),
    ]);

  AIProvider get defaultProvider => LocalProvider();

  Future<String> generateResponse({
    required String providerId,
    required String model,
    required String apiKey,
    required List<ChatMessage> messages,
    required String systemPrompt,
  }) async {
    final provider = getProvider(providerId);
    return provider.generateResponse(
      messages: messages,
      systemPrompt: systemPrompt,
      model: model,
      apiKey: apiKey,
    );
  }
}
