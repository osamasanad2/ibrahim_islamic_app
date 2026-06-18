import 'dart:io';
import 'dart:developer' as developer;

class ErrorReportingService {
  static final ErrorReportingService _instance = ErrorReportingService._();
  ErrorReportingService._();

  static ErrorReportingService get instance => _instance;

  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _initialized = true;
  }

  void logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) {
    developer.log('Analytics event: $name', name: 'Analytics');
  }

  void recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) {
    developer.log(
      'Error${fatal ? ' (FATAL)' : ''}: $exception${reason != null ? ' — $reason' : ''}',
      name: 'Crashlytics',
      stackTrace: stack,
    );
  }

  void setUserIdentifier(String? id) {}

  void setCustomKey(String key, String value) {}

  void setUserId(String? userId) {}
}
