import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio dio;
  bool _initialized = false;

  static const Duration _timeout = Duration(seconds: 30);

  void init({String? baseUrl}) {
    if (_initialized) return;
    _initialized = true;
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.addAll([
      _ErrorInterceptor(),
      RetryInterceptor(dio: dio),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        compact: true,
      ),
    ]);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        err = DioException(
          requestOptions: err.requestOptions,
          message: 'timeout_انتهت مهلة الاتصال',
          type: err.type,
        );
      case DioExceptionType.connectionError:
        err = DioException(
          requestOptions: err.requestOptions,
          message: 'connection_فشل الاتصال بالخادم',
          type: err.type,
        );
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode == 429) {
          err = DioException(
            requestOptions: err.requestOptions,
            message: '429_طلبات كثيرة جداً',
            type: err.type,
          );
        } else if (statusCode == 401 || statusCode == 403) {
          err = DioException(
            requestOptions: err.requestOptions,
            message: '${statusCode}_المفتاح غير صالح',
            type: err.type,
          );
        } else if (statusCode != null && statusCode >= 500) {
          err = DioException(
            requestOptions: err.requestOptions,
            message: '${statusCode}_خطأ في الخادم',
            type: err.type,
          );
        }
      default:
        break;
    }
    handler.next(err);
  }
}

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor({required this.dio, this.maxRetries = 2});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err) && (err.requestOptions.extra['retryCount'] ?? 0) < maxRetries) {
      final retryCount = (err.requestOptions.extra['retryCount'] as int? ?? 0) + 1;
      err.requestOptions.extra['retryCount'] = retryCount;
      await Future.delayed(Duration(milliseconds: 500 * retryCount));
      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (_) {}
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;
  }
}
