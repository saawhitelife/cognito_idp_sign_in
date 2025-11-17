import '../http/http_status_code.dart';
import 'package:flutter/services.dart' show PlatformException;

/// Base class for all Cognito IDP sign-in errors.
///
/// This sealed class ensures exhaustive pattern matching when handling errors
/// from the Cognito IDP sign-in flow.
sealed class CognitoIdpSignInError {
  const CognitoIdpSignInError();
}

/// An error indicating the PKCE state parameter has expired.
///
/// The state parameter is used to prevent CSRF attacks and has a limited
/// lifetime. This error occurs when the authorization response is received
/// after the state has exceeded its maximum lifetime.
class StateExpiredError extends CognitoIdpSignInError {
  const StateExpiredError({required this.createdAt, required this.age, required this.maxLifetime});

  /// The timestamp when the state was created.
  final DateTime createdAt;

  /// The age of the state parameter when validation occurred.
  final Duration age;

  /// The maximum allowed lifetime for the state parameter.
  final Duration maxLifetime;

  @override
  String toString() {
    return 'StateExpiredError(createdAt: $createdAt, age: $age, maxLifetime: $maxLifetime)';
  }
}

/// An error indicating the state parameter in the callback does not match the expected value.
///
/// The state parameter is used to prevent CSRF attacks. This error occurs when
/// the state returned by the authorization server doesn't match the state that
/// was sent in the authorization request.
class StateMismatchError extends CognitoIdpSignInError {
  const StateMismatchError({required this.expected, required this.actual});

  /// The expected state value that was sent in the authorization request.
  final String expected;

  /// The actual state value received in the authorization callback.
  final String actual;

  @override
  String toString() {
    return 'StateMismatchError(expected: $expected, actual: $actual)';
  }
}

/// An unexpected error that occurred during the authorization code flow.
///
/// This error wraps any unexpected exceptions that occur during the
/// authorization process that don't fit into other specific error categories.
class UnexpectedAuthorizationCodeFlowError extends CognitoIdpSignInError {
  const UnexpectedAuthorizationCodeFlowError(this.error, this.stackTrace);

  /// The underlying error object that was thrown.
  final Object error;

  /// The stack trace at the point where the error occurred.
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'UnexpectedAuthorizationCodeFlowError(error: $error, stackTrace: $stackTrace)';
  }
}

/// An unexpected error that occurred during the web authentication flow.
///
/// This error wraps any unexpected exceptions that occur during the web
/// authentication session that don't fit into other specific error categories.
class WebAuthFlowUnexpectedError extends CognitoIdpSignInError {
  const WebAuthFlowUnexpectedError({required this.error, required this.stackTrace});

  /// The underlying error object that was thrown.
  final Object error;

  /// The stack trace at the point where the error occurred.
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'WebAuthFlowUnexpectedError(error: $error, stackTrace: $stackTrace)';
  }
}

/// An error indicating the callback URL received from the web authentication flow is invalid.
///
/// This error occurs when the callback URL cannot be parsed or doesn't match
/// the expected format. The URL should contain the authorization code and state
/// parameters.
class WebAuthFlowInvalidCallbackUrlError extends CognitoIdpSignInError {
  const WebAuthFlowInvalidCallbackUrlError({required this.callbackUrl, required this.error, required this.stackTrace});

  /// The invalid callback URL that was received.
  final String callbackUrl;

  /// The error that occurred while parsing the callback URL.
  final Object error;

  /// The stack trace at the point where the parsing error occurred.
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'WebAuthFlowInvalidCallbackUrlError(callbackUrl: $callbackUrl, error: $error, stackTrace: $stackTrace)';
  }
}

/// A platform-specific error that occurred during the web authentication flow.
///
/// This error wraps [PlatformException] errors from the underlying platform
/// channel, such as when the user cancels the authentication or when there's
/// a platform-specific issue with the web view.
class WebAuthFlowPlatformError extends CognitoIdpSignInError {
  const WebAuthFlowPlatformError({required this.error, required this.stackTrace});

  /// The platform exception that was thrown.
  final PlatformException error;

  /// The stack trace at the point where the platform error occurred.
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'WebAuthFlowPlatformError(error: $error, stackTrace: $stackTrace)';
  }
}

/// An error indicating the PKCE bundle has expired.
///
/// The PKCE (Proof Key for Code Exchange) bundle contains the code verifier
/// and other parameters needed to exchange the authorization code for tokens.
/// This error occurs when attempting to use a PKCE bundle that has exceeded
/// its maximum lifetime.
class PkceBundleExpiredError extends CognitoIdpSignInError {
  const PkceBundleExpiredError({required this.createdAt, required this.age, required this.maxLifetime});

  /// The timestamp when the PKCE bundle was created.
  final DateTime createdAt;

  /// The age of the PKCE bundle when validation occurred.
  final Duration age;

  /// The maximum allowed lifetime for the PKCE bundle.
  final Duration maxLifetime;

  @override
  String toString() {
    return 'PkceBundleExpiredError(createdAt: $createdAt, age: $age, maxLifetime: $maxLifetime)';
  }
}

/// An error indicating the PKCE bundle is missing when attempting code exchange.
///
/// This error occurs when trying to exchange an authorization code for tokens
/// without a valid PKCE bundle. The bundle should have been created during
/// the initial authorization request.
class PkceBundleMissingError extends CognitoIdpSignInError {
  const PkceBundleMissingError();

  @override
  String toString() {
    return 'PkceBundleMissingError';
  }
}

/// An HTTP request error that occurred during the code exchange.
///
/// This error occurs when the HTTP request to exchange the authorization code
/// for tokens fails with a non-2xx status code. The error includes details
/// about the request and response for debugging.
class ExchangeCodeHttpRequestFailedError extends CognitoIdpSignInError {
  const ExchangeCodeHttpRequestFailedError({
    required this.responseBody,
    required this.requestBody,
    required this.requestParams,
    required this.requestPath,
    required this.statusCode,
  });

  /// The response body returned by the server.
  final Map<String, dynamic> responseBody;

  /// The request body that was sent.
  final Map<String, dynamic> requestBody;

  /// The request query parameters that were sent.
  final Map<String, dynamic> requestParams;

  /// The request path (endpoint) that was called.
  final String requestPath;

  /// The HTTP status code returned by the server.
  final HttpStatusCode statusCode;

  @override
  String toString() {
    return 'ExchangeCodeHttpRequestFailedError(responseBody: $responseBody, requestBody: $requestBody, requestParams: $requestParams, requestPath: $requestPath, statusCode: $statusCode)';
  }
}

/// An error indicating the HTTP response body during code exchange is invalid.
///
/// This error occurs when the server returns a response that cannot be parsed
/// as JSON or doesn't match the expected format for token exchange responses.
class ExchangeCodeHttpInvalidResponseBodyError extends CognitoIdpSignInError {
  const ExchangeCodeHttpInvalidResponseBodyError({
    required this.rawResponseBody,
    required this.requestBody,
    required this.requestParams,
    required this.requestPath,
    required this.statusCode,
  });

  /// The raw response body as a string that could not be parsed.
  final String rawResponseBody;

  /// The request body that was sent.
  final Map<String, dynamic> requestBody;

  /// The request query parameters that were sent.
  final Map<String, dynamic> requestParams;

  /// The request path (endpoint) that was called.
  final String requestPath;

  /// The HTTP status code returned by the server.
  final HttpStatusCode statusCode;

  @override
  String toString() {
    return 'ExchangeCodeHttpInvalidResponseBodyError(rawResponseBody: $rawResponseBody, requestBody: $requestBody, requestParams: $requestParams, requestPath: $requestPath, statusCode: $statusCode)';
  }
}

/// An HTTP timeout error that occurred during the code exchange.
///
/// This error occurs when the HTTP request to exchange the authorization code
/// for tokens exceeds the configured timeout duration.
class ExchangeCodeHttpTimeoutError extends CognitoIdpSignInError {
  const ExchangeCodeHttpTimeoutError({
    required this.timeout,
    required this.requestBody,
    required this.requestParams,
    required this.requestPath,
  });

  /// The timeout duration that was exceeded.
  final Duration timeout;

  /// The request body that was sent.
  final Map<String, dynamic> requestBody;

  /// The request query parameters that were sent.
  final Map<String, dynamic> requestParams;

  /// The request path (endpoint) that was called.
  final String requestPath;

  @override
  String toString() {
    return 'ExchangeCodeHttpTimeoutError(timeout: $timeout, requestBody: $requestBody, requestParams: $requestParams, requestPath: $requestPath)';
  }
}

/// An unexpected error that occurred during the code exchange process.
///
/// This error wraps any unexpected exceptions that occur during the token
/// exchange that don't fit into other specific error categories.
class ExchangeCodeUnexpectedError extends CognitoIdpSignInError {
  const ExchangeCodeUnexpectedError(this.error, this.stackTrace);

  /// The underlying error object that was thrown.
  final Object error;

  /// The stack trace at the point where the error occurred.
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'ExchangeCodeUnexpectedError(error: $error, stackTrace: $stackTrace)';
  }
}

/// An error indicating the JWT payload is invalid or cannot be decoded.
///
/// This error occurs when the ID token returned by the authorization server
/// cannot be decoded, typically due to invalid base64 encoding or malformed
/// JSON in the payload.
class DecodeJwtInvalidPayloadError extends CognitoIdpSignInError {
  const DecodeJwtInvalidPayloadError();

  @override
  String toString() {
    return 'DecodeJwtInvalidPayloadError';
  }
}

/// An unexpected error that occurred during JWT decoding.
///
/// This error wraps any unexpected exceptions that occur while decoding
/// the JWT token that don't fit into other specific error categories.
class DecodeJwtUnexpectedError extends CognitoIdpSignInError {
  const DecodeJwtUnexpectedError(this.error, this.stackTrace);

  /// The underlying error object that was thrown.
  final Object error;

  /// The stack trace at the point where the error occurred.
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'DecodeJwtUnexpectedError(error: $error, stackTrace: $stackTrace)';
  }
}

/// An error indicating the nonce in the ID token does not match the expected value.
///
/// The nonce is used to prevent replay attacks. This error occurs when the
/// nonce claim in the ID token doesn't match the nonce that was sent in the
/// authorization request.
class NonceMismatchFailure extends CognitoIdpSignInError {
  const NonceMismatchFailure({required this.expectedNonce, required this.actualNonce});

  /// The expected nonce value that was sent in the authorization request.
  final String expectedNonce;

  /// The actual nonce value found in the ID token payload.
  final String actualNonce;

  @override
  String toString() {
    return 'NonceMismatchFailure(expectedNonce: $expectedNonce, actualNonce: $actualNonce)';
  }
}

/// An unexpected error that occurred during the sign-in process.
///
/// This error wraps any unexpected exceptions that occur during the overall
/// sign-in flow that don't fit into other specific error categories. This is
/// the catch-all error for any unforeseen issues.
class UnexpectedError extends CognitoIdpSignInError {
  const UnexpectedError(this.error, this.stackTrace);

  /// The underlying error object that was thrown.
  final Object error;

  /// The stack trace at the point where the error occurred.
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'UnexpectedError(error: $error, stackTrace: $stackTrace)';
  }
}
