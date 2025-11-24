import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient._(this.dio);

  factory ApiClient({required String baseUrl}) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('→ ${options.method} ${options.uri}');
        handler.next(options);
      },
      onError: (e, handler) async {
        print('← ERROR: ${e.response?.statusCode} ${e.message}');

        // Ретраи на сетевые ошибки
        if (_shouldRetry(e)) {
          final retryCount =
              (e.requestOptions.extra['retry_count'] ?? 0) as int;
          if (retryCount < 3) {
            await _exponentialDelay(retryCount);
            e.requestOptions.extra['retry_count'] = retryCount + 1;
            handler.resolve(await dio.fetch(e.requestOptions));
            return;
          }
        }

        handler.next(e);
      },
    ));

    return ApiClient._(dio);
  }

  static bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.response?.statusCode == 502 ||
        error.response?.statusCode == 503;
  }

  static Future<void> _exponentialDelay(int retryCount) async {
    final delay =
        Duration(milliseconds: 500 * (1 << retryCount)); // 0.5s, 1s, 2s
    await Future.delayed(delay);
  }
}
