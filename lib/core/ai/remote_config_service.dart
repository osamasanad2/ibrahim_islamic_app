import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static String? _geminiApiKey;

  static String? get geminiApiKey => _geminiApiKey;

  static Future<void> init() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await remoteConfig.fetchAndActivate();
      _geminiApiKey = remoteConfig.getString('gemini_api_key');
    } catch (_) {}
  }
}
