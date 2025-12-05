# Amazon Cognito Federated Sign-In
![Coverage](https://img.shields.io/codecov/c/github/saawhitelife/cognito_idp_sign_in)
![Build](https://img.shields.io/github/actions/workflow/status/saawhitelife/cognito_idp_sign_in/coverage.yml?branch=main&label=build)
![License](https://img.shields.io/github/license/saawhitelife/cognito_idp_sign_in)

A Flutter package for signing in with Amazon Cognito via third-party identity providers (IdPs) using OAuth 2.0 and PKCE. Built on top of [flutter_web_auth_2](https://pub.dev/packages/flutter_web_auth_2). The resulting Cognito tokens can be reused with [amazon_cognito_identity_dart_2](https://pub.dev/packages/amazon_cognito_identity_dart_2) for authenticated calls to AWS services.

## Features

Use this package to:
- Present the Cognito Hosted UI or IdP web view inside your Flutter app
- Exchange authorization codes for Cognito tokens
- Enforce OAuth 2.0 with PKCE state, nonce, and scope management
  
## Platform Setup

This package is built on [flutter_web_auth_2](https://pub.dev/packages/flutter_web_auth_2). **Per-platform configuration is required.**

For detailed platform-specific setup instructions (Android manifest, iOS configuration, Web auth callback page, etc.), see the [flutter_web_auth_2 setup guide](https://pub.dev/packages/flutter_web_auth_2#setup).

## Usage

- [Basic Authentication](#basic-authentication)
- [Error handling](#error-handling)
- [Custom scopes](#custom-scopes)
- [Advanced options](#advanced-options)

> See the [example app](https://github.com/saawhitelife/cognito_idp_sign_in/blob/main/example/lib/main.dart) for a complete implementation example.

### Basic Authentication

Configure a baseline once at instantiation, then override any option for specific identity providers as needed.

```dart
import 'package:cognito_idp_sign_in/cognito_idp_sign_in.dart';

// Configure authentication
final cognitoIdpSignIn = CognitoIdpSignIn(
  CognitoIdpSignInOptions(
    poolId: 'us-east-1_XXXXXXXXX',
    clientId: 'your-client-id',
    clientSecret: 'your-client-secret', // Optional
    hostedUiDomain: 'your-domain.auth.region.amazoncognito.com',
    redirectUri: Uri.parse('myapp://'),
    identityProviderName: 'SignInWithApple',
    scopes: [CognitoScope.email]
  ),
);

// Sign in
final IdpResult result = await cognitoIdpSignIn.signInWithCognitoIdp();

// Handle result
switch (result) {
  case SuccessResult<AuthData, CognitoIdpSignInError>(data: final authData):
    print('Access Token: ${authData.accessToken}');
    print('ID Token: ${authData.idToken}');
    print('Refresh Token: ${authData.refreshToken}');
  case FailureResult<AuthData, CognitoIdpSignInError>(error: final error):
    print('Authentication failed: $error');
}

// Sign in with Google into the same pool
final IdpResult facebookResult = await cognitoIdpSignIn.signInWithCognitoIdp(
  optionOverrides: CognitoIdpSignInOptionsOverrides(
    identityProviderName: 'Google',
    scopes: [CognitoScope.email, CognitoScope.openid, CognitoScope.profile],

  ),
);
```

### Error Handling
```dart
switch (result) {
  case SuccessResult():
    // Handle success
  case FailureResult(error: final error):
    switch (error) {
      case StateExpiredError():
        // State expired, ask user to retry
      case NonceMismatchFailure():
        // ID token nonce validation failed
      case ExchangeCodeHttpRequestFailedError(statusCode: final code):
        // HTTP error during token exchange
      case PkceBundleExpiredError():
        // PKCE bundle expired during flow
      // ... handle other error types
    }
}
```

### Custom Scopes

```dart
CognitoIdpSignInOptions(
  // ... required options
  scopes: [
    CognitoScope.openid,
    CognitoScope.email,
    CognitoScope.profile,
  ],
  customScopes: ['custom-scope-1', 'custom-scope-2'],
)
```

### Advanced Options

```dart
CognitoIdpSignInOptions(
  // ... required options
  codeChallengeMethod: CodeChallengeMethod.s256,   
  nonceLength: 43,
  stateLength: 43,
  pkceBundleLifetime: Duration(minutes: 5),
  webAuthOptions: CognitoIdpWebAuthOptions(
    preferEphemeral: true,
    // ... other flutter_web_auth_2 options
  ),
)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This package is licensed under the MIT License. See LICENSE for details.

## External References

- [AWS Cognito Documentation](https://docs.aws.amazon.com/cognito/)
- [flutter_web_auth_2](https://pub.dev/packages/flutter_web_auth_2) - Underlying web authentication package
- [OAuth 2.0 RFC 6749](https://tools.ietf.org/html/rfc6749)
- [PKCE RFC 7636](https://tools.ietf.org/html/rfc7636)
