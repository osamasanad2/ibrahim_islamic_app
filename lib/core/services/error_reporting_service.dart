import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class ErrorReportingService {
  static final ErrorReportingService _instance = ErrorReportingService._();
  ErrorReportingService._();

  static ErrorReportingService get instance => _instance;

  FirebaseAnalytics? _analytics;
  bool _initialized = false;

  void init() {
    if (_initialized) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;

    _analytics = FirebaseAnalytics.instance;
    _initialized = true;
  }

  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) async {
    if (!_initialized) return;
    try {
      await _analytics!.logEvent(name: name, parameters: parameters);
    } catch (_) {}
  }

  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    if (!_initialized || !Platform.isAndroid && !Platform.isIOS) return;
    try {
      await FirebaseCrashlytics.instance.recordError(
        exception,
        stack,
        reason: reason,
        fatal: fatal,
      );
    } catch (_) {}
  }

  void setUserIdentifier(String? id) {
    if (!_initialized) return;
    try {
      FirebaseCrashlytics.instance.setUserIdentifier(id ?? '');
    } catch (_) {}
  }

  void setCustomKey(String key, String value) {
    if (!_initialized) return;
    try {
      FirebaseCrashlytics.instance.setCustomKey(key, value);
    } catch (_) {}
  }

  Future<void> setUserId(String? userId) async {
    if (!_initialized) return;
    try {
      await _analytics!.setUserId(id: userId);
    } catch (_) {}
  }
}
