import 'package:cognito_idp_sign_in/src/cognito_idp_web_auth/cognito_idp_web_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebAuthFlowError', () {
    test('WebAuthFlowUnexpectedError', () {
      final Exception error = Exception('Unexpected error');
      final StackTrace stackTrace = StackTrace.current;

      expect(
        WebAuthFlowUnexpectedError(error: error, stackTrace: stackTrace).toString(),
        'WebAuthFlowUnexpectedError(error: Exception: Unexpected error, stackTrace: $stackTrace)',
      );
    });

    test('WebAuthFlowInvalidCallbackUrlError', () {
      final Exception error = Exception('Invalid callback url error');
      final StackTrace stackTrace = StackTrace.current;

      expect(
        WebAuthFlowInvalidCallbackUrlError(
          callbackUrl: 'https://example.com',
          error: error,
          stackTrace: stackTrace,
        ).toString(),
        'WebAuthFlowInvalidCallbackUrlError(callbackUrl: https://example.com, error: Exception: Invalid callback url error, stackTrace: $stackTrace)',
      );
    });

    test('WebAuthFlowPlatformError', () {
      final StackTrace stackTrace = StackTrace.current;
      final PlatformException error = PlatformException(
        code: 'platform_exception',
        message: 'Platform exception',
        details: 'Platform details',
        stacktrace: 'platform_stacktrace',
      );

      expect(
        WebAuthFlowPlatformError(error: error, stackTrace: stackTrace).toString(),
        'WebAuthFlowPlatformError(error: PlatformException(platform_exception, Platform exception, Platform details, platform_stacktrace), stackTrace: $stackTrace)',
      );
    });
  });
}
