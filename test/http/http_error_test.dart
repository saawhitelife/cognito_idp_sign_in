import 'package:cognito_idp_sign_in/src/http/http.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HttpError', () {
    test('HttpUnexpectedError', () {
      final StackTrace stackTrace = StackTrace.current;
      final HttpUnexpectedError error = HttpUnexpectedError(Exception('Unexpected error'), stackTrace);
      expect(error.toString(), 'HttpUnexpectedError(error: Exception: Unexpected error, stackTrace: $stackTrace)');
    });

    test('HttpRequestFailedError', () {
      final HttpRequestFailedError error = HttpRequestFailedError(
        <String, dynamic>{},
        <String, dynamic>{},
        <String, dynamic>{},
        '/test',
        HttpStatusCode.ok,
      );
      expect(
        error.toString(),
        'HttpRequestFailedError(responseBody: {}, requestBody: {}, requestParams: {}, requestPath: /test, statusCode: 200 OK)',
      );
    });

    test('HttpInvalidResponseBodyError', () {
      final HttpInvalidResponseBodyError error = HttpInvalidResponseBodyError(
        'invalid',
        <String, dynamic>{},
        <String, dynamic>{},
        '/test',
        HttpStatusCode.ok,
      );
      expect(
        error.toString(),
        'HttpInvalidResponseBodyError(rawResponseBody: invalid, requestBody: {}, requestParams: {}, requestPath: /test, statusCode: 200 OK)',
      );
    });

    test('HttpTimeoutError', () {
      const Duration duration = Duration(seconds: 10);

      final HttpTimeoutError error = HttpTimeoutError(duration, <String, dynamic>{}, <String, dynamic>{}, '/test');
      expect(
        error.toString(),
        'HttpTimeoutError(timeout: $duration, requestBody: {}, requestParams: {}, requestPath: /test)',
      );
    });
  });
}
