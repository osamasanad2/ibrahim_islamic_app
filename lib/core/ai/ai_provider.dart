import 'chat_message.dart';

abstract class AIProvider {
  String get id;
  String get displayName;
  String get defaultModel;
  String get apiKeyLabel;
  bool get needsApiKey;
  List<String> get availableModels;

  Future<String> generateResponse({
    required List<ChatMessage> messages,
    required String systemPrompt,
    required String model,
    required String apiKey,
  });
}
