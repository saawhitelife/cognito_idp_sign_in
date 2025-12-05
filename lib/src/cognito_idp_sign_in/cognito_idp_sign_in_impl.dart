import '../code_exchange/code_exchange.dart';
import 'cognito_idp_sign_in_error.dart';
import 'cognito_idp_sign_in_error_mapper.dart';
import 'cognito_idp_sign_in_options.dart';
import 'cognito_scope.dart';
import '../cognito_idp_web_auth/cognito_idp_web_auth_impl.dart';
import '../cognito_idp_web_auth/cognito_callback_params.dart';
import '../cognito_idp_web_auth/web_auth.dart';
import '../cognito_idp_web_auth/web_auth_flow_error.dart';
import '../generic/generic.dart';
import '../http/http.dart';
import '../utilities/jwt_decoder/jwt_decoder_impl.dart';
import '../utilities/jwt_decoder/decode_jwt_error.dart';
import '../utilities/pkce/pkce.dart';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

/// The result type returned by [CognitoIdpSignIn.signInWithCognitoIdp].
///
/// This is a type alias for [Result]<[AuthData], [CognitoIdpSignInError]>.
/// Use pattern matching to handle success and failure cases:
///
/// ```dart
/// final IdpResult result = await cognitoIdpSignIn.signInWithCognitoIdp();
/// switch (result) {
///   case SuccessResult<AuthData, CognitoIdpSignInError>(data: final authData):
///     // Handle successful authentication
///   case FailureResult<AuthData, CognitoIdpSignInError>(error: final error):
///     // Handle authentication error
/// }
/// ```
typedef IdpResult = Result<AuthData, CognitoIdpSignInError>;

/// A client for authenticating users with AWS Cognito Identity Provider using OAuth 2.0 and PKCE.
///
/// This class handles the complete authentication flow including:
/// - Generating PKCE parameters (code verifier, code challenge, state, nonce)
/// - Initiating the web-based authorization flow
/// - Exchanging the authorization code for tokens
/// - Validating tokens and verifying nonce
///
/// The authentication process follows the OAuth 2.0 authorization code flow with PKCE
/// as specified in [RFC 7636](https://tools.ietf.org/html/rfc7636).
///
/// **Platform Configuration Required:**
/// This package requires per-platform setup (Android manifest, iOS URL schemes, web callback page).
/// See the [flutter_web_auth_2 setup guide](https://pub.dev/packages/flutter_web_auth_2#setup)
/// for detailed instructions.
///
/// Example usage:
///
/// ```dart
/// final cognitoIdpSignIn = CognitoIdpSignIn(
///   CognitoIdpSignInOptions(
///     poolId: 'us-east-1_XXXXXXXXX',
///     clientId: 'your-client-id',
///     hostedUiDomain: 'your-domain.auth.region.amazoncognito.com',
///     redirectUri: Uri.parse('myapp://'),
///     identityProviderName: 'SignInWithApple',
///   ),
/// );
///
/// final result = await cognitoIdpSignIn.signInWithCognitoIdp();
/// ```
class CognitoIdpSignIn {
  /// Creates a new [CognitoIdpSignIn] instance.
  ///
  /// The [options] parameter is required and contains all configuration needed for
  /// authentication, including Cognito User Pool details, client ID, and identity provider.
  ///
  /// Optional dependencies can be provided for testing or customization:
  /// - [pkceTools] - For generating PKCE parameters (defaults to [PkceTools])
  /// - [remoteDataSource] - For HTTP requests to Cognito token endpoint (defaults to [RemoteDataSource])
  /// - [jwtDecoder] - For decoding JWT tokens (defaults to [JwtDecoder])
  /// - [cognitoIdpWebAuth] - For initiating web authentication flow (defaults to [CognitoIdpWebAuth])
  CognitoIdpSignIn(
    this._options, {
    PkceTools? pkceTools,
    RemoteDataSource? remoteDataSource,
    JwtDecoder? jwtDecoder,
    CognitoIdpWebAuth? cognitoIdpWebAuth,
  }) : _pkceTools = pkceTools ?? PkceTools(),
       _remoteDataSource =
           remoteDataSource ??
           RemoteDataSource(client: HttpClient(http.Client(), 'https://${_options.hostedUiDomain}')),
       _jwtDecoder = jwtDecoder ?? JwtDecoder(),
       _cognitoIdpWebAuth = cognitoIdpWebAuth ?? CognitoIdpWebAuth(WebAuthFlutter());

  final CognitoIdpSignInOptions _options;
  final PkceTools _pkceTools;
  final RemoteDataSource _remoteDataSource;
  final JwtDecoder _jwtDecoder;
  final CognitoIdpWebAuth _cognitoIdpWebAuth;
  final CognitoIdpSignInErrorMapper _errorMapper = const CognitoIdpSignInErrorMapper();

  PkceBundle? _lastPkceBundle;

  PkceBundle _createPkceBundle({required CognitoIdpSignInOptions options}) {
    final (:String codeVerifier, :String codeChallenge) = _pkceTools.generatePkcePair();
    final String state = _pkceTools.generateUrlSafeString(length: options.stateLength);
    final String nonce = _pkceTools.generateUrlSafeString(length: options.nonceLength);

    return PkceBundle(
      codeVerifier: codeVerifier,
      codeChallenge: codeChallenge,
      state: state,
      nonce: nonce,
      createdAt: DateTime.now(),
    );
  }

  /// Checks whether the current PKCE bundle has expired.
  ///
  /// Returns `true` if no PKCE bundle exists or if the bundle's age exceeds
  /// the [options.pkceBundleLifetime]. This is used internally to ensure
  /// PKCE parameters don't become stale during the authentication flow.
  bool checkIfPkceBundleExpired({required CognitoIdpSignInOptions options}) {
    final PkceBundle? pkceBundle = _lastPkceBundle;

    if (pkceBundle == null) {
      return true;
    }

    return pkceBundle.age >= options.pkceBundleLifetime;
  }

  void _clearPkceBundle() {
    _lastPkceBundle = null;
  }

  // Test-only method to set bundle state for testing defensive error paths
  @visibleForTesting
  void setPkceBundleForTesting(PkceBundle? bundle) {
    _lastPkceBundle = bundle;
  }

  Future<Result<String, CognitoIdpSignInError>> _startAuthorizationCodeFlow({
    required CognitoIdpSignInOptions options,
  }) async {
    try {
      final PkceBundle pkceBundle = _createPkceBundle(options: options);

      _lastPkceBundle = pkceBundle;

      final WebAuthFlowResult idpWebAuthResult = await _cognitoIdpWebAuth.startWebAuthFlow(
        clientId: options.clientId,
        clientSecret: options.clientSecret,
        redirectUri: options.redirectUri,
        state: pkceBundle.state,
        nonce: pkceBundle.nonce,
        identityProvider: options.identityProviderName,
        codeChallenge: pkceBundle.codeChallenge,
        codeChallengeMethod: options.codeChallengeMethod,
        scopes: options.scopes ?? <CognitoScope>[],
        customScopes: options.customScopes ?? <String>[],
        hostedUiDomain: options.hostedUiDomain,
        webAuthOptions: options.webAuthOptions,
      );

      final WebAuthFlowError? webAuthFlowError = switch (idpWebAuthResult) {
        SuccessResult<CognitoCallbackParams, WebAuthFlowError>() => null,
        FailureResult<CognitoCallbackParams, WebAuthFlowError>(error: final WebAuthFlowError error) => error,
      };

      if (webAuthFlowError != null) {
        return FailureResult<String, CognitoIdpSignInError>(error: _errorMapper.mapWebAuthFlowError(webAuthFlowError));
      }

      final CognitoCallbackParams parameters = idpWebAuthResult.requireData;

      if (checkIfPkceBundleExpired(options: options)) {
        final DateTime createdAt = pkceBundle.createdAt;
        final Duration age = pkceBundle.age;
        final Duration maxLifetime = options.pkceBundleLifetime;
        _clearPkceBundle();

        return FailureResult<String, CognitoIdpSignInError>(
          error: StateExpiredError(createdAt: createdAt, age: age, maxLifetime: maxLifetime),
        );
      }

      if (parameters.state != pkceBundle.state) {
        _clearPkceBundle();

        return FailureResult<String, CognitoIdpSignInError>(
          error: StateMismatchError(expected: pkceBundle.state, actual: parameters.state),
        );
      }

      return SuccessResult<String, CognitoIdpSignInError>(data: parameters.code);
    } catch (e, stackTrace) {
      return FailureResult<String, CognitoIdpSignInError>(error: UnexpectedAuthorizationCodeFlowError(e, stackTrace));
    }
  }

  /// Signs in a user with Cognito Identity Provider.
  ///
  /// This method performs the complete OAuth 2.0 authorization code flow with PKCE:
  /// 1. Generates PKCE parameters (code verifier, code challenge, state, nonce)
  /// 2. Opens the Cognito Hosted UI for user authentication
  /// 3. Exchanges the authorization code for access, ID, and refresh tokens
  /// 4. Validates the ID token and verifies the nonce
  ///
  /// The [optionOverrides] parameter allows you to override specific options for this
  /// authentication attempt without creating a new [CognitoIdpSignIn] instance.
  ///
  /// Returns an [IdpResult] which can be either:
  /// - [SuccessResult] containing [AuthData] with authentication tokens
  /// - [FailureResult] containing a [CognitoIdpSignInError] describing what went wrong
  ///
  /// Example:
  ///
  /// ```dart
  /// final result = await cognitoIdpSignIn.signInWithCognitoIdp();
  /// switch (result) {
  ///   case SuccessResult<AuthData, CognitoIdpSignInError>(data: final authData):
  ///     // Use authData.accessToken, authData.idToken, etc.
  ///   case FailureResult<AuthData, CognitoIdpSignInError>(error: final error):
  ///     // Handle error
  /// }
  /// ```
  Future<IdpResult> signInWithCognitoIdp({CognitoIdpSignInOptionsOverrides? optionOverrides}) async {
    try {
      final CognitoIdpSignInOptions options = _options.applyOverrides(overrides: optionOverrides);

      final Result<String, CognitoIdpSignInError> webAuthResult = await _startAuthorizationCodeFlow(options: options);

      final CognitoIdpSignInError? webAuthError = switch (webAuthResult) {
        SuccessResult<String, CognitoIdpSignInError>() => null,
        FailureResult<String, CognitoIdpSignInError>(error: final CognitoIdpSignInError error) => error,
      };

      if (webAuthError != null) {
        return FailureResult<AuthData, CognitoIdpSignInError>(error: webAuthError);
      }

      final String authCode = webAuthResult.requireData;

      final Result<AuthData, CognitoIdpSignInError> exchangeCodeForAuthDataResult = await _exchangeCodeForAuthData(
        authCode: authCode,
        options: options,
      );

      final CognitoIdpSignInError? exchangeCodeForAuthDataError = switch (exchangeCodeForAuthDataResult) {
        SuccessResult<AuthData, CognitoIdpSignInError>() => null,
        FailureResult<AuthData, CognitoIdpSignInError>(error: final CognitoIdpSignInError error) => error,
      };

      if (exchangeCodeForAuthDataError != null) {
        return FailureResult<AuthData, CognitoIdpSignInError>(error: exchangeCodeForAuthDataError);
      }

      final AuthData authData = exchangeCodeForAuthDataResult.requireData;

      final String? idToken = authData.idToken;

      if (idToken == null) {
        return SuccessResult<AuthData, CognitoIdpSignInError>(data: authData);
      }

      final DecodeJwtResult decodeJwtResult = _jwtDecoder.decodePayload(idToken);

      final CognitoIdpSignInError? decodeJwtError = switch (decodeJwtResult) {
        SuccessResult<Map<String, dynamic>, DecodeJwtError>() => null,
        FailureResult<Map<String, dynamic>, DecodeJwtError>(error: final DecodeJwtError error) =>
          _errorMapper.mapDecodeJwtError(error),
      };

      if (decodeJwtError != null) {
        return FailureResult<AuthData, CognitoIdpSignInError>(error: decodeJwtError);
      }

      final Map<String, dynamic> payload = decodeJwtResult.requireData;

      if (payload['nonce'] != _lastPkceBundle?.nonce) {
        final String actualNonce = payload['nonce']?.toString() ?? '';
        final String expectedNonce = _lastPkceBundle?.nonce ?? '';
        return FailureResult<AuthData, CognitoIdpSignInError>(
          error: NonceMismatchFailure(expectedNonce: expectedNonce, actualNonce: actualNonce),
        );
      }

      return SuccessResult<AuthData, CognitoIdpSignInError>(data: authData);
    } catch (error, stackTrace) {
      return FailureResult<AuthData, CognitoIdpSignInError>(error: UnexpectedError(error, stackTrace));
    } finally {
      _clearPkceBundle();
    }
  }

  // Test-only method to directly test _exchangeCodeForAuthData defensive error paths
  @visibleForTesting
  Future<Result<AuthData, CognitoIdpSignInError>> exchangeCodeForAuthDataForTesting({
    required String authCode,
    required CognitoIdpSignInOptions options,
  }) async {
    return _exchangeCodeForAuthData(authCode: authCode, options: options);
  }

  Future<Result<AuthData, CognitoIdpSignInError>> _exchangeCodeForAuthData({
    required String authCode,
    required CognitoIdpSignInOptions options,
  }) async {
    try {
      final PkceBundle? pkceBundle = _lastPkceBundle;

      if (pkceBundle == null) {
        return FailureResult<AuthData, CognitoIdpSignInError>(error: PkceBundleMissingError());
      }

      if (checkIfPkceBundleExpired(options: options)) {
        final DateTime createdAt = pkceBundle.createdAt;
        final Duration age = pkceBundle.age;
        final Duration maxLifetime = options.pkceBundleLifetime;
        _clearPkceBundle();

        return FailureResult<AuthData, CognitoIdpSignInError>(
          error: PkceBundleExpiredError(createdAt: createdAt, age: age, maxLifetime: maxLifetime),
        );
      }

      final CodeExchangeData codeExchangeData = CodeExchangeData(
        clientId: options.clientId,
        clientSecret: options.clientSecret,
        code: authCode,
        redirectUri: options.redirectUri.toString(),
        codeVerifier: pkceBundle.codeVerifier,
      );

      final HttpResponse<AuthData> response = await _remoteDataSource.exchangeCodeForAuthData(codeExchangeData);

      return switch (response) {
        SuccessResult<AuthData, HttpError>(data: final AuthData data) => SuccessResult<AuthData, CognitoIdpSignInError>(
          data: data,
        ),
        FailureResult<AuthData, HttpError>(error: final HttpError error) =>
          FailureResult<AuthData, CognitoIdpSignInError>(error: _errorMapper.mapHttpError(error)),
      };
    } catch (error, stackTrace) {
      return FailureResult<AuthData, CognitoIdpSignInError>(error: ExchangeCodeUnexpectedError(error, stackTrace));
    }
  }
}
