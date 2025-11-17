import 'package:cognito_idp_sign_in/src/cognito_idp_sign_in/cognito_idp_sign_in_error.dart';
import 'package:cognito_idp_sign_in/src/cognito_idp_sign_in/cognito_idp_sign_in_error_mapper.dart';
import 'package:cognito_idp_sign_in/src/cognito_idp_web_auth/web_auth_flow_error.dart' as web_auth_flow_error;
import 'package:cognito_idp_sign_in/src/http/http.dart';
import 'package:cognito_idp_sign_in/src/utilities/jwt_decoder/decode_jwt_error.dart' as decode_jwt_error;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CognitoIdpSignInErrorMapper', () {
    const CognitoIdpSignInErrorMapper mapper = CognitoIdpSignInErrorMapper();

    group('mapWebAuthFlowError', () {
      test('maps WebAuthFlowUnexpectedError', () {
        final StackTrace stackTrace = StackTrace.current;
        final Exception error = Exception('Unexpected error');
        final web_auth_flow_error.WebAuthFlowUnexpectedError webAuthError =
            web_auth_flow_error.WebAuthFlowUnexpectedError(error: error, stackTrace: stackTrace);

        final CognitoIdpSignInError result = mapper.mapWebAuthFlowError(webAuthError);

        expect(result, isA<WebAuthFlowUnexpectedError>());
        final WebAuthFlowUnexpectedError mappedError = result as WebAuthFlowUnexpectedError;
        expect(mappedError.error, error);
        expect(mappedError.stackTrace, stackTrace);
      });

      test('maps WebAuthFlowInvalidCallbackUrlError', () {
        final StackTrace stackTrace = StackTrace.current;
        const String callbackUrl = 'invalid://callback';
        final Exception error = Exception('Invalid callback URL');
        final web_auth_flow_error.WebAuthFlowInvalidCallbackUrlError webAuthError =
            web_auth_flow_error.WebAuthFlowInvalidCallbackUrlError(
              callbackUrl: callbackUrl,
              error: error,
              stackTrace: stackTrace,
            );

        final CognitoIdpSignInError result = mapper.mapWebAuthFlowError(webAuthError);

        expect(result, isA<WebAuthFlowInvalidCallbackUrlError>());
        final WebAuthFlowInvalidCallbackUrlError mappedError = result as WebAuthFlowInvalidCallbackUrlError;
        expect(mappedError.callbackUrl, callbackUrl);
        expect(mappedError.error, error);
        expect(mappedError.stackTrace, stackTrace);
      });

      test('maps WebAuthFlowPlatformError', () {
        final StackTrace stackTrace = StackTrace.current;
        final PlatformException platformException = PlatformException(
          code: 'USER_CANCELED',
          message: 'User canceled the operation',
        );
        final web_auth_flow_error.WebAuthFlowPlatformError webAuthError = web_auth_flow_error.WebAuthFlowPlatformError(
          error: platformException,
          stackTrace: stackTrace,
        );

        final CognitoIdpSignInError result = mapper.mapWebAuthFlowError(webAuthError);

        expect(result, isA<WebAuthFlowPlatformError>());
        final WebAuthFlowPlatformError mappedError = result as WebAuthFlowPlatformError;
        expect(mappedError.error, platformException);
        expect(mappedError.stackTrace, stackTrace);
      });
    });

    group('mapDecodeJwtError', () {
      test('maps DecodeJwtInvalidPayloadError', () {
        const decode_jwt_error.DecodeJwtInvalidPayloadError decodeError =
            decode_jwt_error.DecodeJwtInvalidPayloadError();

        final CognitoIdpSignInError result = mapper.mapDecodeJwtError(decodeError);

        expect(result, isA<DecodeJwtInvalidPayloadError>());
        expect(result, const DecodeJwtInvalidPayloadError());
      });

      test('maps DecodeJwtUnexpectedError', () {
        final StackTrace stackTrace = StackTrace.current;
        final Exception error = Exception('Unexpected error');
        final decode_jwt_error.DecodeJwtUnexpectedError decodeError = decode_jwt_error.DecodeJwtUnexpectedError(
          error,
          stackTrace,
        );

        final CognitoIdpSignInError result = mapper.mapDecodeJwtError(decodeError);

        expect(result, isA<DecodeJwtUnexpectedError>());
        final DecodeJwtUnexpectedError mappedError = result as DecodeJwtUnexpectedError;
        expect(mappedError.error, error);
        expect(mappedError.stackTrace, stackTrace);
      });
    });

    group('mapHttpError', () {
      test('maps HttpUnexpectedError to ExchangeCodeUnexpectedError', () {
        final StackTrace stackTrace = StackTrace.current;
        final Exception error = Exception('Unexpected error');
        final HttpUnexpectedError httpError = HttpUnexpectedError(error, stackTrace);

        final CognitoIdpSignInError result = mapper.mapHttpError(httpError);

        expect(result, isA<ExchangeCodeUnexpectedError>());
        final ExchangeCodeUnexpectedError mappedError = result as ExchangeCodeUnexpectedError;
        expect(mappedError.error, error);
        expect(mappedError.stackTrace, stackTrace);
      });

      test('maps HttpRequestFailedError to ExchangeCodeHttpRequestFailedError', () {
        final HttpStatusCode statusCode = HttpStatusCode.fromCode(400);
        final Map<String, dynamic> responseBody = <String, dynamic>{'error': 'invalid_request'};
        final Map<String, dynamic> requestBody = <String, dynamic>{'code': 'auth_code'};
        final Map<String, dynamic> requestParams = <String, dynamic>{};
        const String requestPath = '/token';
        final HttpRequestFailedError httpError = HttpRequestFailedError(
          responseBody,
          requestBody,
          requestParams,
          requestPath,
          statusCode,
        );

        final CognitoIdpSignInError result = mapper.mapHttpError(httpError);

        expect(result, isA<ExchangeCodeHttpRequestFailedError>());
        final ExchangeCodeHttpRequestFailedError mappedError = result as ExchangeCodeHttpRequestFailedError;
        expect(mappedError.responseBody, responseBody);
        expect(mappedError.requestBody, requestBody);
        expect(mappedError.requestParams, requestParams);
        expect(mappedError.requestPath, requestPath);
        expect(mappedError.statusCode, statusCode);
      });

      test('maps HttpInvalidResponseBodyError to ExchangeCodeHttpInvalidResponseBodyError', () {
        final HttpStatusCode statusCode = HttpStatusCode.fromCode(200);
        const String rawResponseBody = 'invalid json';
        final Map<String, dynamic> requestBody = <String, dynamic>{'code': 'auth_code'};
        final Map<String, dynamic> requestParams = <String, dynamic>{};
        const String requestPath = '/token';
        final HttpInvalidResponseBodyError httpError = HttpInvalidResponseBodyError(
          rawResponseBody,
          requestBody,
          requestParams,
          requestPath,
          statusCode,
        );

        final CognitoIdpSignInError result = mapper.mapHttpError(httpError);

        expect(result, isA<ExchangeCodeHttpInvalidResponseBodyError>());
        final ExchangeCodeHttpInvalidResponseBodyError mappedError = result as ExchangeCodeHttpInvalidResponseBodyError;
        expect(mappedError.rawResponseBody, rawResponseBody);
        expect(mappedError.requestBody, requestBody);
        expect(mappedError.requestParams, requestParams);
        expect(mappedError.requestPath, requestPath);
        expect(mappedError.statusCode, statusCode);
      });

      test('maps HttpTimeoutError to ExchangeCodeHttpTimeoutError', () {
        const Duration timeout = Duration(seconds: 30);
        final Map<String, dynamic> requestBody = <String, dynamic>{'code': 'auth_code'};
        final Map<String, dynamic> requestParams = <String, dynamic>{};
        const String requestPath = '/token';
        final HttpTimeoutError httpError = HttpTimeoutError(timeout, requestBody, requestParams, requestPath);

        final CognitoIdpSignInError result = mapper.mapHttpError(httpError);

        expect(result, isA<ExchangeCodeHttpTimeoutError>());
        final ExchangeCodeHttpTimeoutError mappedError = result as ExchangeCodeHttpTimeoutError;
        expect(mappedError.timeout, timeout);
        expect(mappedError.requestBody, requestBody);
        expect(mappedError.requestParams, requestParams);
        expect(mappedError.requestPath, requestPath);
      });
    });
  });
}
