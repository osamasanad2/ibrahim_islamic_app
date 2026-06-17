import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/providers.dart';
import '../storage/local_storage.dart';
import 'ai_service.dart';
import 'remote_config_service.dart';
import '../constants/api_keys.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService(ref.read(dioProvider));
});

final selectedAiProviderId = StateProvider<String>((ref) {
  final savedProvider = LocalStorage().getString('ai_provider', defaultValue: '');
  if (savedProvider.isNotEmpty) return savedProvider;

  // If an API key is embedded inside the code, select that provider automatically.
  if (AppApiKeys.openAiApiKey.isNotEmpty) return 'openai';
  if (AppApiKeys.openRouterApiKey.isNotEmpty) return 'openrouter';
  if (RemoteConfigService.geminiApiKey != null && RemoteConfigService.geminiApiKey!.isNotEmpty) return 'gemini';
  if (AppApiKeys.geminiApiKey.isNotEmpty) return 'gemini';

  return LocalStorage().getString('ai_provider', defaultValue: 'local');
});

final selectedAiModel = StateProvider<String>((ref) {
  final providerId = ref.watch(selectedAiProviderId);
  return LocalStorage().getString('ai_model_$providerId', defaultValue: '');
});

final aiApiKeyProvider = StateProvider<String>((ref) {
  final providerId = ref.watch(selectedAiProviderId);
  return LocalStorage().getString('ai_key_$providerId', defaultValue: '');
});

final effectiveApiKeyProvider = Provider<String>((ref) {
  final stored = ref.watch(aiApiKeyProvider);
  if (stored.isNotEmpty) return stored;
  
  final providerId = ref.watch(selectedAiProviderId);
  // local provider doesn't require an API key
  if (providerId == 'local') return '';
  
  if (providerId == 'openrouter') {
    if (AppApiKeys.openRouterApiKey.isNotEmpty) return AppApiKeys.openRouterApiKey;
  } else if (providerId == 'gemini') {
    final remote = RemoteConfigService.geminiApiKey;
    if (remote != null && remote.isNotEmpty) return remote;

    if (AppApiKeys.geminiApiKey.isNotEmpty) {
      return AppApiKeys.geminiApiKey;
    }
  } else if (providerId == 'openai') {
    if (AppApiKeys.openAiApiKey.isNotEmpty) return AppApiKeys.openAiApiKey;
  }

  return '';
});

final hasRemoteKeyProvider = Provider<bool>((ref) {
  final stored = ref.watch(aiApiKeyProvider);
  if (stored.isNotEmpty) return false;

  final providerId = ref.watch(selectedAiProviderId);
  if (providerId == 'local') return false;

  if (providerId == 'openrouter') {
    if (AppApiKeys.openRouterApiKey.isNotEmpty) return true;
  } else if (providerId == 'gemini') {
    final remote = RemoteConfigService.geminiApiKey;
    if (remote != null && remote.isNotEmpty) return true;

    if (AppApiKeys.geminiApiKey.isNotEmpty) return true;
  } else if (providerId == 'openai') {
    if (AppApiKeys.openAiApiKey.isNotEmpty) return true;
  }

  return false;
});

final currentAiProvider = Provider((ref) {
  final service = ref.watch(aiServiceProvider);
  final providerId = ref.watch(selectedAiProviderId);
  return service.getProvider(providerId);
});
