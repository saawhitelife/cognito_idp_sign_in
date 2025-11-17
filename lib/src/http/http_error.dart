import 'http_status_code.dart';

sealed class HttpError {
  const HttpError();
}

class HttpUnexpectedError extends HttpError {
  const HttpUnexpectedError(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'HttpUnexpectedError(error: $error, stackTrace: $stackTrace)';
  }
}

class HttpRequestFailedError extends HttpError {
  final Map<String, dynamic> responseBody;
  final Map<String, dynamic> requestBody;
  final Map<String, dynamic> requestParams;
  final String requestPath;
  final HttpStatusCode statusCode;

  const HttpRequestFailedError(
    this.responseBody,
    this.requestBody,
    this.requestParams,
    this.requestPath,
    this.statusCode,
  );

  @override
  String toString() {
    return 'HttpRequestFailedError(responseBody: $responseBody, requestBody: $requestBody, requestParams: $requestParams, requestPath: $requestPath, statusCode: $statusCode)';
  }
}

class HttpInvalidResponseBodyError extends HttpError {
  const HttpInvalidResponseBodyError(
    this.rawResponseBody,
    this.requestBody,
    this.requestParams,
    this.requestPath,
    this.statusCode,
  );
  final String rawResponseBody;
  final Map<String, dynamic> requestBody;
  final Map<String, dynamic> requestParams;
  final String requestPath;
  final HttpStatusCode statusCode;

  @override
  String toString() {
    return 'HttpInvalidResponseBodyError(rawResponseBody: $rawResponseBody, requestBody: $requestBody, requestParams: $requestParams, requestPath: $requestPath, statusCode: $statusCode)';
  }
}

class HttpTimeoutError extends HttpError {
  const HttpTimeoutError(this.timeout, this.requestBody, this.requestParams, this.requestPath);

  final Duration timeout;
  final Map<String, dynamic> requestBody;
  final Map<String, dynamic> requestParams;
  final String requestPath;

  @override
  String toString() {
    return 'HttpTimeoutError(timeout: $timeout, requestBody: $requestBody, requestParams: $requestParams, requestPath: $requestPath)';
  }
}
