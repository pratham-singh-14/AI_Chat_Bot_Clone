class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException([super.message = 'Unable to connect to the backend server. Please check your network and Base URL.']);
}

class QuotaExceededException extends ApiException {
  QuotaExceededException([String message = 'API rate limit or quota exceeded. Please try again later.'])
      : super(message, 429);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Invalid or missing OpenAI API key. Check backend configuration.'])
      : super(message, 401);
}
