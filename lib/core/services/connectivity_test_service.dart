import 'package:dio/dio.dart';

class ConnectionTestResult {
  final String label;
  final bool success;
  final int? statusCode;
  final String message;
  final Duration duration;

  const ConnectionTestResult({
    required this.label,
    required this.success,
    this.statusCode,
    required this.message,
    required this.duration,
  });
}

class ConnectivityTestService {
  final Dio dio;

  ConnectivityTestService(this.dio);

  Future<ConnectionTestResult> testInternet() async {
    final start = DateTime.now();
    try {
      final response = await dio.get(
        'https://www.google.com',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          headers: {'Accept': 'text/html'},
        ),
      );
      final elapsed = DateTime.now().difference(start);
      return ConnectionTestResult(
        label: '📡 اتصال الإنترنت',
        success: true,
        statusCode: response.statusCode,
        message: 'الاتصال بالإنترنت يعمل',
        duration: elapsed,
      );
    } catch (e) {
      final elapsed = DateTime.now().difference(start);
      return ConnectionTestResult(
        label: '📡 اتصال الإنترنت',
        success: false,
        message: 'فشل الاتصال بالإنترنت: ${_simplify(e.toString())}',
        duration: elapsed,
      );
    }
  }

  Future<ConnectionTestResult> testGemini({required String apiKey}) async {
    final start = DateTime.now();
    try {
      final response = await dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
        options: Options(
          headers: {
            'x-goog-api-key': apiKey,
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
        data: {
          'contents': [
            {'parts': [{'text': 'قل "مرحباً" بالعربية'}], 'role': 'user'}
          ],
          'generationConfig': {'maxOutputTokens': 50},
        },
      );
      final elapsed = DateTime.now().difference(start);
      return ConnectionTestResult(
        label: '🤖 Gemini',
        success: true,
        statusCode: response.statusCode,
        message: 'النموذج يعمل',
        duration: elapsed,
      );
    } catch (e) {
      final elapsed = DateTime.now().difference(start);
      return ConnectionTestResult(
        label: '🤖 Gemini',
        success: false,
        statusCode: e is DioException ? e.response?.statusCode : null,
        message: _simplify(e.toString()),
        duration: elapsed,
      );
    }
  }

  Future<ConnectionTestResult> testOpenRouter({required String apiKey}) async {
    final start = DateTime.now();
    try {
      final response = await dio.post(
        'https://openrouter.ai/api/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
        data: {
          'model': 'qwen/qwen-2.5-72b-instruct',
          'messages': [
            {'role': 'user', 'content': 'قل "مرحباً" بالعربية'}
          ],
          'max_tokens': 50,
        },
      );
      final elapsed = DateTime.now().difference(start);
      return ConnectionTestResult(
        label: '🤖 OpenRouter',
        success: true,
        statusCode: response.statusCode,
        message: 'النموذج يعمل',
        duration: elapsed,
      );
    } catch (e) {
      final elapsed = DateTime.now().difference(start);
      return ConnectionTestResult(
        label: '🤖 OpenRouter',
        success: false,
        statusCode: e is DioException ? e.response?.statusCode : null,
        message: _simplify(e.toString()),
        duration: elapsed,
      );
    }
  }

  Future<ConnectionTestResult> testOpenAI({required String apiKey}) async {
    final start = DateTime.now();
    try {
      final response = await dio.post(
        'https://api.openai.com/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': 'قل "مرحباً" بالعربية'}
          ],
          'max_tokens': 50,
        },
      );
      final elapsed = DateTime.now().difference(start);
      return ConnectionTestResult(
        label: '🤖 OpenAI',
        success: true,
        statusCode: response.statusCode,
        message: 'النموذج يعمل',
        duration: elapsed,
      );
    } catch (e) {
      final elapsed = DateTime.now().difference(start);
      return ConnectionTestResult(
        label: '🤖 OpenAI',
        success: false,
        statusCode: e is DioException ? e.response?.statusCode : null,
        message: _simplify(e.toString()),
        duration: elapsed,
      );
    }
  }

  Future<ConnectionTestResult> testTogether({required String apiKey}) async {
    final start = DateTime.now();
    try {
      final response = await dio.post(
        'https://api.together.xyz/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
        data: {
          'model': 'Qwen/Qwen2.5-72B-Instruct-Turbo',
          'messages': [
            {'role': 'user', 'content': 'قل "مرحباً" بالعربية'}
          ],
          'max_tokens': 50,
        },
      );
      final elapsed = DateTime.now().difference(start);
      return ConnectionTestResult(
        label: '🤖 Together AI',
        success: true,
        statusCode: response.statusCode,
        message: 'النموذج يعمل',
        duration: elapsed,
      );
    } catch (e) {
      final elapsed = DateTime.now().difference(start);
      return ConnectionTestResult(
        label: '🤖 Together AI',
        success: false,
        statusCode: e is DioException ? e.response?.statusCode : null,
        message: _simplify(e.toString()),
        duration: elapsed,
      );
    }
  }

  String _simplify(String err) {
    if (err.contains('401') || err.contains('API key')) return 'المفتاح غير صالح';
    if (err.contains('403')) return 'المفتاح ليس لديه صلاحية';
    if (err.contains('429')) return 'طلبات كثيرة جداً';
    if (err.contains('connection') || err.contains('Failed host lookup') || err.contains('SocketException')) {
      return 'فشل الاتصال بالخادم';
    }
    if (err.contains('timeout')) return 'انتهت المهلة';
    if (err.contains('500') || err.contains('502') || err.contains('503')) return 'الخادم معطل';
    if (err.length > 120) return '${err.substring(0, 120)}...';
    return err;
  }
}
