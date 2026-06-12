import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/providers.dart';
import '../storage/local_storage.dart';
import 'ai_service.dart';
import 'remote_config_service.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService(ref.read(dioProvider));
});

final selectedAiProviderId = StateProvider<String>((ref) {
  return LocalStorage().getString('ai_provider', defaultValue: 'gemini');
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
  final remote = RemoteConfigService.geminiApiKey;
  if (remote != null && remote.isNotEmpty) return remote;
  return '';
});

final hasRemoteKeyProvider = Provider<bool>((ref) {
  final stored = ref.watch(aiApiKeyProvider);
  if (stored.isNotEmpty) return false;
  final remote = RemoteConfigService.geminiApiKey;
  return remote != null && remote.isNotEmpty;
});

final currentAiProvider = Provider((ref) {
  final service = ref.watch(aiServiceProvider);
  final providerId = ref.watch(selectedAiProviderId);
  return service.getProvider(providerId);
});
