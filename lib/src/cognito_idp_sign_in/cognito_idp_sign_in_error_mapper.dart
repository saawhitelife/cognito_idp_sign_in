import 'cognito_idp_sign_in_error.dart';
import '../cognito_idp_web_auth/web_auth_flow_error.dart' as web_auth_flow_error;
import '../http/http.dart';
import '../utilities/jwt_decoder/decode_jwt_error.dart' as decode_jwt_error;
import 'package:flutter/services.dart' show PlatformException;

/// Maps errors from internal components to [CognitoIdpSignInError] subtypes.
class CognitoIdpSignInErrorMapper {
  const CognitoIdpSignInErrorMapper();

  /// Maps a [WebAuthFlowError] to a [CognitoIdpSignInError] subtype.
  CognitoIdpSignInError mapWebAuthFlowError(web_auth_flow_error.WebAuthFlowError error) {
    return switch (error) {
      web_auth_flow_error.WebAuthFlowUnexpectedError(:final Object error, :final StackTrace stackTrace) =>
        WebAuthFlowUnexpectedError(error: error, stackTrace: stackTrace),
      web_auth_flow_error.WebAuthFlowInvalidCallbackUrlError(
        :final String callbackUrl,
        :final Object error,
        :final StackTrace stackTrace,
      ) =>
        WebAuthFlowInvalidCallbackUrlError(callbackUrl: callbackUrl, error: error, stackTrace: stackTrace),
      web_auth_flow_error.WebAuthFlowPlatformError(:final PlatformException error, :final StackTrace stackTrace) =>
        WebAuthFlowPlatformError(error: error, stackTrace: stackTrace),
    };
  }

  /// Maps a [DecodeJwtError] to a [CognitoIdpSignInError] subtype.
  CognitoIdpSignInError mapDecodeJwtError(decode_jwt_error.DecodeJwtError error) {
    return switch (error) {
      decode_jwt_error.DecodeJwtInvalidPayloadError() => const DecodeJwtInvalidPayloadError(),
      decode_jwt_error.DecodeJwtUnexpectedError(:final Object error, :final StackTrace stackTrace) =>
        DecodeJwtUnexpectedError(error, stackTrace),
    };
  }

  /// Maps an [HttpError] to a [CognitoIdpSignInError] subtype.
  CognitoIdpSignInError mapHttpError(HttpError error) {
    return switch (error) {
      HttpUnexpectedError(:final Object error, :final StackTrace stackTrace) => ExchangeCodeUnexpectedError(
        error,
        stackTrace,
      ),
      HttpRequestFailedError(
        :final Map<String, dynamic> responseBody,
        :final Map<String, dynamic> requestBody,
        :final Map<String, dynamic> requestParams,
        :final String requestPath,
        :final HttpStatusCode statusCode,
      ) =>
        ExchangeCodeHttpRequestFailedError(
          responseBody: responseBody,
          requestBody: requestBody,
          requestParams: requestParams,
          requestPath: requestPath,
          statusCode: statusCode,
        ),
      HttpInvalidResponseBodyError(
        :final String rawResponseBody,
        :final Map<String, dynamic> requestBody,
        :final Map<String, dynamic> requestParams,
        :final String requestPath,
        :final HttpStatusCode statusCode,
      ) =>
        ExchangeCodeHttpInvalidResponseBodyError(
          rawResponseBody: rawResponseBody,
          requestBody: requestBody,
          requestParams: requestParams,
          requestPath: requestPath,
          statusCode: statusCode,
        ),
      HttpTimeoutError(
        :final Duration timeout,
        :final Map<String, dynamic> requestBody,
        :final Map<String, dynamic> requestParams,
        :final String requestPath,
      ) =>
        ExchangeCodeHttpTimeoutError(
          timeout: timeout,
          requestBody: requestBody,
          requestParams: requestParams,
          requestPath: requestPath,
        ),
    };
  }
}
