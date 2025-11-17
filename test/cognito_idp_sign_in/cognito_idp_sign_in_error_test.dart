import 'package:cognito_idp_sign_in/src/cognito_idp_sign_in/index.dart';
import 'package:cognito_idp_sign_in/src/http/http.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CognitoIdpSignInError', () {
    // Authorization Code Flow Errors
    test('StateExpiredError', () {
      final DateTime createdAt = DateTime(2024, 1, 1, 12, 0, 0);
      final Duration age = const Duration(minutes: 2);
      final Duration maxLifetime = const Duration(minutes: 1);

      expect(
        StateExpiredError(createdAt: createdAt, age: age, maxLifetime: maxLifetime).toString(),
        'StateExpiredError(createdAt: $createdAt, age: $age, maxLifetime: $maxLifetime)',
      );
    });

    test('StateMismatchError', () {
      const String expected = 'expected';
      const String actual = 'actual';

      const StateMismatchError error = StateMismatchError(expected: expected, actual: actual);
      expect(error.toString(), 'StateMismatchError(expected: $expected, actual: $actual)');
    });

    test('UnexpectedAuthorizationCodeFlowError', () {
      final Exception error = Exception('Unexpected error');
      final StackTrace stackTrace = StackTrace.current;

      expect(
        UnexpectedAuthorizationCodeFlowError(error, stackTrace).toString(),
        'UnexpectedAuthorizationCodeFlowError(error: $error, stackTrace: $stackTrace)',
      );
    });

    // Web Auth Flow Errors
    test('WebAuthFlowUnexpectedError', () {
      final StackTrace stackTrace = StackTrace.current;

      final WebAuthFlowUnexpectedError error = WebAuthFlowUnexpectedError(
        error: Exception('Unexpected error'),
        stackTrace: stackTrace,
      );

      expect(
        error.toString(),
        'WebAuthFlowUnexpectedError(error: Exception: Unexpected error, stackTrace: $stackTrace)',
      );
    });

    test('WebAuthFlowInvalidCallbackUrlError', () {
      final StackTrace stackTrace = StackTrace.current;
      const String callbackUrl = 'invalid://callback';

      final WebAuthFlowInvalidCallbackUrlError error = WebAuthFlowInvalidCallbackUrlError(
        callbackUrl: callbackUrl,
        error: Exception('Invalid callback URL'),
        stackTrace: stackTrace,
      );

      expect(
        error.toString(),
        'WebAuthFlowInvalidCallbackUrlError(callbackUrl: $callbackUrl, error: Exception: Invalid callback URL, stackTrace: $stackTrace)',
      );
    });

    test('WebAuthFlowPlatformError', () {
      final StackTrace stackTrace = StackTrace.current;
      final PlatformException platformException = PlatformException(
        code: 'USER_CANCELED',
        message: 'User canceled the operation',
      );

      final WebAuthFlowPlatformError error = WebAuthFlowPlatformError(error: platformException, stackTrace: stackTrace);

      expect(error.toString(), 'WebAuthFlowPlatformError(error: $platformException, stackTrace: $stackTrace)');
    });

    // Code Exchange Errors
    test('PkceBundleExpiredError', () {
      final DateTime createdAt = DateTime(2024, 1, 1, 12, 0, 0);
      final Duration age = const Duration(minutes: 6);
      final Duration maxLifetime = const Duration(minutes: 5);

      expect(
        PkceBundleExpiredError(createdAt: createdAt, age: age, maxLifetime: maxLifetime).toString(),
        'PkceBundleExpiredError(createdAt: $createdAt, age: $age, maxLifetime: $maxLifetime)',
      );
    });

    test('PkceBundleMissingError', () {
      expect(const PkceBundleMissingError().toString(), 'PkceBundleMissingError');
    });

    test('ExchangeCodeHttpRequestFailedError', () {
      final HttpStatusCode statusCode = HttpStatusCode.fromCode(400);

      final ExchangeCodeHttpRequestFailedError error = ExchangeCodeHttpRequestFailedError(
        responseBody: <String, dynamic>{},
        requestBody: <String, dynamic>{},
        requestParams: <String, dynamic>{},
        requestPath: '/token',
        statusCode: statusCode,
      );
      expect(error.toString(), contains('ExchangeCodeHttpRequestFailedError'));
      expect(error.statusCode, statusCode);
    });

    test('ExchangeCodeHttpInvalidResponseBodyError', () {
      final HttpStatusCode statusCode = HttpStatusCode.fromCode(200);
      const String rawResponseBody = 'invalid json';

      final ExchangeCodeHttpInvalidResponseBodyError error = ExchangeCodeHttpInvalidResponseBodyError(
        rawResponseBody: rawResponseBody,
        requestBody: <String, dynamic>{},
        requestParams: <String, dynamic>{},
        requestPath: '/token',
        statusCode: statusCode,
      );

      expect(
        error.toString(),
        'ExchangeCodeHttpInvalidResponseBodyError(rawResponseBody: $rawResponseBody, requestBody: {}, requestParams: {}, requestPath: /token, statusCode: $statusCode)',
      );
      expect(error.rawResponseBody, rawResponseBody);
      expect(error.statusCode, statusCode);
    });

    test('ExchangeCodeHttpTimeoutError', () {
      const Duration timeout = Duration(seconds: 30);
      const String requestPath = '/token';

      final ExchangeCodeHttpTimeoutError error = ExchangeCodeHttpTimeoutError(
        timeout: timeout,
        requestBody: <String, dynamic>{},
        requestParams: <String, dynamic>{},
        requestPath: requestPath,
      );

      expect(
        error.toString(),
        'ExchangeCodeHttpTimeoutError(timeout: $timeout, requestBody: {}, requestParams: {}, requestPath: $requestPath)',
      );
      expect(error.timeout, timeout);
      expect(error.requestPath, requestPath);
    });

    test('ExchangeCodeUnexpectedError', () {
      final StackTrace stackTrace = StackTrace.current;

      expect(
        ExchangeCodeUnexpectedError(Exception('Unexpected error'), stackTrace).toString(),
        'ExchangeCodeUnexpectedError(error: Exception: Unexpected error, stackTrace: $stackTrace)',
      );
    });

    // JWT Decode Errors
    test('DecodeJwtInvalidPayloadError', () {
      const DecodeJwtInvalidPayloadError error = DecodeJwtInvalidPayloadError();
      expect(error.toString(), 'DecodeJwtInvalidPayloadError');
    });

    test('DecodeJwtUnexpectedError', () {
      final StackTrace stackTrace = StackTrace.current;

      final DecodeJwtUnexpectedError error = DecodeJwtUnexpectedError(Exception('Unexpected error'), stackTrace);
      expect(error.toString(), 'DecodeJwtUnexpectedError(error: Exception: Unexpected error, stackTrace: $stackTrace)');
    });

    // Other Errors
    test('NonceMismatchFailure', () {
      const String expectedNonce = 'expected-nonce-123';
      const String actualNonce = 'actual-nonce-456';

      const NonceMismatchFailure error = NonceMismatchFailure(expectedNonce: expectedNonce, actualNonce: actualNonce);
      expect(error.toString(), 'NonceMismatchFailure(expectedNonce: $expectedNonce, actualNonce: $actualNonce)');
    });

    test('UnexpectedError', () {
      final StackTrace stackTrace = StackTrace.current;
      final UnexpectedError error = UnexpectedError(Exception('Unexpected error'), stackTrace);
      expect(error.toString(), 'UnexpectedError(error: Exception: Unexpected error, stackTrace: $stackTrace)');
    });
  });
}
