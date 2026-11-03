import 'package:dio/dio.dart';

import 'package:ecoach_pro/core/config/env.dart';
import 'package:ecoach_pro/core/network/api_response.dart';
import 'package:ecoach_pro/core/storage/token_storage.dart';
import 'package:ecoach_pro/core/utils/logger.dart';

/// The ONE place that talks HTTP.
///
/// * base URL, timeouts and JSON headers
/// * `Authorization: Bearer <token>` added automatically (`auth: false` to skip)
/// * request / response logging (passwords and tokens are masked)
/// * every outcome (2xx, 4xx, timeout, no internet...) comes back as an
///   [ApiResponse]; nothing is thrown to the UI
class NetworkClient {
  NetworkClient({
    required TokenStorage tokenStorage,
    this.onUnauthorized,
    Dio? dio,
  }) : _tokens = tokenStorage,
       _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: Env.connectTimeout,
      receiveTimeout: Env.receiveTimeout,
      sendTimeout: Env.receiveTimeout,
      headers: const <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      // Backend sends useful JSON bodies on 4xx; only 5xx is an exception.
      validateStatus: (code) => code != null && code < 500,
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _tokens.token;
          if (options.extra['auth'] != false && token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          AppLogger.debug(
            '--> ${options.method} ${options.uri}\n${_mask(options.data)}',
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.debug(
            '<-- ${response.statusCode} ${response.requestOptions.uri}\n'
            '${_mask(response.data)}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.error(
            '<-- ERROR ${error.response?.statusCode} '
            '${error.requestOptions.uri}\n${_mask(error.response?.data)}',
            error: error.message,
          );
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokens;

  /// Called when a request that carried a token comes back 401
  /// (expired / revoked session).
  final void Function()? onUnauthorized;

  Future<ApiResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
  }) => _send('GET', path, query: query, auth: auth);

  Future<ApiResponse<dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) => _send('POST', path, body: body, auth: auth);

  Future<ApiResponse<dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) => _send('PUT', path, body: body, auth: auth);

  Future<ApiResponse<dynamic>> delete(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) => _send('DELETE', path, body: body, auth: auth);

  // ---------------------------------------------------------------------------

  Future<ApiResponse<dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    required bool auth,
  }) async {
    final hadToken = auth && _tokens.token != null;
    try {
      final response = await _dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
        options: Options(method: method, extra: <String, dynamic>{'auth': auth}),
      );

      if (response.statusCode == 401 && hadToken) onUnauthorized?.call();
      return _parse(response);
    } on DioException catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        message: _dioMessage(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e, st) {
      AppLogger.error('Unexpected network error', error: e, stackTrace: st);
      return const ApiResponse<dynamic>(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  ApiResponse<dynamic> _parse(Response<dynamic> response) {
    final code = response.statusCode ?? 0;
    final ok = code >= 200 && code < 300;
    final raw = response.data;

    if (raw is! Map) {
      return ApiResponse<dynamic>(
        success: ok,
        message: ok ? 'Success' : 'Unexpected server response ($code).',
        statusCode: code,
      );
    }

    final body = Map<String, dynamic>.from(raw);
    final flag = body['status'] ?? body['success'];
    final success = flag is bool ? flag && ok : ok;

    final errors = body['errors'] is Map
        ? Map<String, dynamic>.from(body['errors'] as Map)
        : null;

    var message = (body['message'] ?? '').toString();
    if (!success && errors != null && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) message = first.first.toString();
    }
    if (message.isEmpty) {
      message = success ? 'Success' : 'Request failed ($code).';
    }

    return ApiResponse<dynamic>(
      success: success,
      message: message,
      data: body['data'],
      statusCode: code,
      errors: errors,
      body: body,
    );
  }

  String _dioMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The request timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.badResponse:
        final body = e.response?.data;
        final serverMsg = body is Map ? body['message']?.toString() : null;
        final code = e.response?.statusCode;
        return (serverMsg != null && serverMsg.isNotEmpty)
            ? 'Server error ($code): $serverMsg'
            : 'Server error ($code). Please try later.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  static const Set<String> _secret = <String>{
    'password',
    'password_confirmation',
    'token',
    'otp',
    'remember_token',
  };

  Object? _mask(Object? data) {
    if (data is Map) {
      return data.map(
        (k, v) => MapEntry<dynamic, dynamic>(
          k,
          _secret.contains(k) ? '***' : _mask(v),
        ),
      );
    }
    if (data is List) return data.map(_mask).toList();
    return data;
  }
}
