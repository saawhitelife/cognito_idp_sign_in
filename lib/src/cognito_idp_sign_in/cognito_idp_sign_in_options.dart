import '../utilities/pkce/code_challenge_method.dart';
import 'cognito_scope.dart';
import '../cognito_idp_web_auth/cognito_idp_web_auth.dart';

/// A custom OAuth 2.0 scope string.
///
/// Custom scopes are application-specific scopes that extend beyond the
/// standard OAuth 2.0 scopes defined in [CognitoScope].
typedef CustomScope = String;

/// The name of an identity provider configured in AWS Cognito.
///
/// This identifies which external identity provider (e.g., "SignInWithApple",
/// "Google", "Facebook") to use for authentication.
typedef IdentityProviderName = String;

/// Configuration options for Cognito IDP sign-in.
///
/// This class contains all the configuration needed to perform an OAuth 2.0
/// authorization code flow with PKCE against an AWS Cognito User Pool.
///
/// **Example:**
/// ```dart
/// final options = CognitoIdpSignInOptions(
///   poolId: 'us-east-1_abc123',
///   clientId: 'your-client-id',
///   clientSecret: 'your-client-secret', // Optional
///   hostedUiDomain: 'your-app.auth.us-east-1.amazoncognito.com',
///   redirectUri: Uri.parse('myapp://'),
///   identityProviderName: 'SignInWithApple',
/// );
/// ```
///
/// **For web platforms:**
/// ```dart
/// import 'package:flutter/foundation.dart' show kIsWeb;
///
/// final options = CognitoIdpSignInOptions(
///   poolId: 'us-east-1_abc123',
///   clientId: 'your-client-id',
///   clientSecret: 'your-client-secret', // Optional
///   hostedUiDomain: 'your-app.auth.us-east-1.amazoncognito.com',
///   redirectUri: kIsWeb
///     ? Uri.parse('http://localhost:8080/auth.html')
///     : Uri.parse('myapp://'),
///   identityProviderName: 'SignInWithApple',
/// );
/// ```
class CognitoIdpSignInOptions {
  const CognitoIdpSignInOptions({
    required this.poolId,
    required this.clientId,
    this.clientSecret,
    required this.hostedUiDomain,
    required this.redirectUri,
    required this.identityProviderName,
    this.nonceLength = 43,
    this.stateLength = 43,
    this.codeChallengeMethod = .s256,
    this.pkceBundleLifetime = const Duration(minutes: 1),
    this.scopes,
    this.customScopes,
    this.webAuthOptions = const CognitoIdpWebAuthOptions(),
  });

  /// The Cognito User Pool ID.
  ///
  /// The format is typically "region_poolId" (e.g., "us-east-1_abc123").
  final String poolId;

  /// The OAuth 2.0 client ID registered in the Cognito User Pool that is used
  /// when exchanging the authorization code for tokens.
  final String clientId;

  /// Optional client secret associated with the Cognito app client.
  ///
  /// Leave null when the app client does not require a secret (mobile
  /// clients). When provided, the secret will be forwarded to the Hosted UI
  /// authorization request and token exchange.
  final String? clientSecret;

  /// The hosted UI domain for the Cognito User Pool.
  ///
  /// This is the domain where the Cognito Hosted UI is accessible, typically
  /// in the format "your-domain.auth.region.amazoncognito.com".
  final String hostedUiDomain;

  /// The PKCE code challenge method to use.
  ///
  /// Defaults to [CodeChallengeMethod.s256] (SHA-256), which is the
  /// recommended method for security.
  final CodeChallengeMethod codeChallengeMethod;

  /// The OAuth 2.0 scopes to request.
  ///
  /// These are standard scopes like [CognitoScope.openid], [CognitoScope.email],
  /// and [CognitoScope.profile]. If null, no standard scopes are requested.
  final List<CognitoScope>? scopes;

  /// Additional custom scopes to request.
  ///
  /// These are application-specific scopes beyond the standard OAuth 2.0 scopes.
  /// If null, no custom scopes are requested.
  final List<CustomScope>? customScopes;

  /// The name of the identity provider to use for authentication.
  ///
  /// This must match an identity provider configured in the Cognito User Pool
  /// (e.g., "SignInWithApple", "Google", "Facebook").
  final IdentityProviderName identityProviderName;

  /// The length of the nonce string in characters.
  ///
  /// The nonce is used to prevent replay attacks. Defaults to 43 characters,
  /// which provides sufficient entropy for security.
  final int nonceLength;

  /// The length of the state string in characters.
  ///
  /// The state parameter is used to prevent CSRF attacks. Defaults to 43
  /// characters, which provides sufficient entropy for security.
  final int stateLength;

  /// The maximum lifetime for the PKCE bundle.
  ///
  /// The PKCE bundle contains the code verifier and other parameters needed
  /// to complete the authorization flow. If the bundle exceeds this lifetime,
  /// it will be considered expired and the flow will fail. Defaults to 1 minute.
  final Duration pkceBundleLifetime;

  /// Additional web authentication options for platform-specific behavior.
  ///
  /// These options are forwarded to the flutter_web_auth_2 package and control
  /// how the web authentication session behaves on different platforms
  /// (e.g., ephemeral sessions, custom tabs on Android).
  final CognitoIdpWebAuthOptions webAuthOptions;

  /// The redirect URI for the OAuth 2.0 authorization flow.
  ///
  /// This URI must be registered in your Cognito User Pool's app client settings.
  ///
  /// **For mobile platforms**, use a custom URL scheme:
  /// ```dart
  /// redirectUri: Uri.parse('myapp://')
  /// ```
  ///
  /// **For web platforms**, use the full URL to your auth callback page:
  /// ```dart
  /// // Development
  /// redirectUri: Uri.parse('http://localhost:8080/auth.html')
  ///
  /// // Production
  /// redirectUri: Uri.parse('https://yourdomain.com/auth.html')
  /// ```
  ///
  /// The auth callback page (e.g., `auth.html`) must use `postMessage()` to
  /// send the callback URL back to the Flutter app. See the flutter_web_auth_2
  /// package documentation for implementation details.
  final Uri redirectUri;

  /// Creates a new [CognitoIdpSignInOptions] with overridden values.
  ///
  /// Returns a new instance with values from [overrides] applied, falling back
  /// to the current instance's values for any fields not specified in [overrides].
  /// If [overrides] is null, returns this instance unchanged.
  CognitoIdpSignInOptions applyOverrides({CognitoIdpSignInOptionsOverrides? overrides}) {
    final CognitoIdpSignInOptionsOverrides? localOverrides = overrides;

    if (localOverrides == null) {
      return this;
    }

    return CognitoIdpSignInOptions(
      poolId: localOverrides.poolId ?? poolId,
      clientId: localOverrides.clientId ?? clientId,
      clientSecret: localOverrides.clientSecret ?? clientSecret,
      hostedUiDomain: localOverrides.hostedUiDomain ?? hostedUiDomain,
      redirectUri: localOverrides.redirectUri ?? redirectUri,
      codeChallengeMethod: localOverrides.codeChallengeMethod ?? codeChallengeMethod,
      scopes: localOverrides.scopes ?? scopes,
      customScopes: localOverrides.customScopes ?? customScopes,
      identityProviderName: localOverrides.identityProviderName ?? identityProviderName,
      nonceLength: localOverrides.nonceLength ?? nonceLength,
      stateLength: localOverrides.stateLength ?? stateLength,
      pkceBundleLifetime: localOverrides.pkceBundleLifetime ?? pkceBundleLifetime,
      webAuthOptions: localOverrides.webAuthOptions ?? webAuthOptions,
    );
  }
}

/// Optional overrides for [CognitoIdpSignInOptions].
///
/// This class allows selective overriding of configuration options without
/// creating a completely new [CognitoIdpSignInOptions] instance. Any field
/// that is null will use the value from the original options.
///
/// ```dart
/// final overrides = CognitoIdpSignInOptionsOverrides(
///   nonceLength: 64,
///   stateLength: 64,
/// );
/// final newOptions = originalOptions.applyOverrides(overrides: overrides);
/// ```
class CognitoIdpSignInOptionsOverrides {
  const CognitoIdpSignInOptionsOverrides({
    this.nonceLength,
    this.stateLength,
    this.pkceBundleLifetime,
    this.scopes,
    this.customScopes,
    this.codeChallengeMethod,
    this.identityProviderName,
    this.redirectUri,
    this.clientId,
    this.clientSecret,
    this.hostedUiDomain,
    this.poolId,
    this.webAuthOptions,
  });

  /// Overrides the Cognito User Pool ID.
  final String? poolId;

  /// Overrides the OAuth 2.0 client ID.
  final String? clientId;

  /// Overrides the optional client secret.
  final String? clientSecret;

  /// Overrides the hosted UI domain.
  final String? hostedUiDomain;

  /// Overrides the redirect URI.
  final Uri? redirectUri;

  /// Overrides the PKCE code challenge method.
  final CodeChallengeMethod? codeChallengeMethod;

  /// Overrides the OAuth 2.0 scopes to request.
  final List<CognitoScope>? scopes;

  /// Overrides the custom scopes to request.
  final List<CustomScope>? customScopes;

  /// Overrides the identity provider name.
  final IdentityProviderName? identityProviderName;

  /// Overrides the nonce length in characters.
  final int? nonceLength;

  /// Overrides the state length in characters.
  final int? stateLength;

  /// Overrides the maximum lifetime for the PKCE bundle.
  final Duration? pkceBundleLifetime;

  /// Overrides the web authentication options.
  final CognitoIdpWebAuthOptions? webAuthOptions;
}
