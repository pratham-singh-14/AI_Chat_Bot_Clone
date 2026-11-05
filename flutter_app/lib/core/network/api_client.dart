import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'api_exceptions.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.baseUrl = ApiConstants.baseUrl;
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          final mappedException = _mapDioError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: mappedException,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );
  }

  Dio get dio => _dio;

  void updateBaseUrl(String newUrl) {
    ApiConstants.baseUrl = newUrl;
    _dio.options.baseUrl = newUrl;
  }

  ApiException _mapDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return NetworkException();
    }

    final response = error.response;
    if (response != null) {
      final statusCode = response.statusCode;
      String message = 'Server error occurred.';

      if (response.data is Map && response.data['message'] != null) {
        message = response.data['message'].toString();
      } else if (response.data is Map && response.data['msg'] != null) {
        message = response.data['msg'].toString();
      }

      if (statusCode == 429) {
        return QuotaExceededException(message);
      } else if (statusCode == 401) {
        return UnauthorizedException(message);
      }
      return ApiException(message, statusCode);
    }

    return ApiException(error.message ?? 'Unknown network error.');
  }
}
