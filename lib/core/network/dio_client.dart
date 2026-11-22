import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/token_storage.dart';
import '../config/app_config.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {'Accept': 'application/json'},
    ),
  );

  final storage = ref.watch(tokenStorageProvider);
  dio.interceptors.add(_AuthInterceptor(storage));
  dio.interceptors.add(_RetryInterceptor(dio));
  return dio;
});

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage);

  final TokenStorage _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.readAccessToken();
    final tenantId = await _storage.readTenantId();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['X-Tenant-Id'] = tenantId ?? AppConfig.defaultTenantId;
    options.headers['X-Request-Id'] =
        '${DateTime.now().microsecondsSinceEpoch}-${options.path.hashCode}';
    handler.next(options);
  }
}

class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);

  final Dio _dio;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra['retryAttempt'] as int?) ?? 0;
    final isTransient = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout;
    if (!isTransient || attempt >= AppConfig.maxRetries) {
      handler.next(err);
      return;
    }
    await Future<void>.delayed(Duration(milliseconds: 400 * (attempt + 1)));
    final options = err.requestOptions;
    options.extra['retryAttempt'] = attempt + 1;
    try {
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
