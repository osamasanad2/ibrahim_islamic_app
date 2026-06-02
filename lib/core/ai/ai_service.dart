import 'package:dio/dio.dart';
import 'ai_provider.dart';
import 'chat_message.dart';
import 'gemini_provider.dart';
import 'open_router_provider.dart';
import 'together_provider.dart';

class AIService {
  final Dio dio;
  final Map<String, AIProvider> _providers = {};

  AIService(this.dio);

  AIProvider getProvider(String id) {
    if (_providers.isEmpty) {
      _providers['gemini'] = GeminiProvider(dio);
      _providers['openrouter'] = OpenRouterProvider(dio);
      _providers['together'] = TogetherProvider(dio);
    }
    return _providers[id]!;
  }

  List<AIProvider> get allProviders => _providers.values.toList()
    ..clear()
    ..addAll([
      GeminiProvider(dio),
      OpenRouterProvider(dio),
      TogetherProvider(dio),
    ]);

  AIProvider get defaultProvider => GeminiProvider(dio);

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
