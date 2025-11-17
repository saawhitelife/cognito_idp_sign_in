// ignore_for_file: unused_local_variable

import 'package:cognito_idp_sign_in/cognito_idp_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cognito IdP Sign In Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      home: const MyHomePage(title: 'Cognito IdP Sign In Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AuthData? _authData;
  CognitoIdpSignInError? _error;

  Uri get _redirectUri {
    /// Run flutter run -d chrome --web-port=5050
    if (kIsWeb) {
      return Uri.parse('http://localhost:5050/auth.html');
    }
    return Uri.parse('uniqueredirectscheme://');
  }

  late final CognitoIdpSignIn _cognitoIdpSignIn = CognitoIdpSignIn(
    CognitoIdpSignInOptions(
      poolId: 'eu-central-1_XXXXXXXXX',
      clientId: 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
      hostedUiDomain:
          'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.auth.eu-central-1.amazoncognito.com',
      redirectUri: _redirectUri,
      identityProviderName: 'SignInWithApple',
      scopes: [CognitoScope.email],
    ),
  );

  void _handleIdpResult(IdpResult result) {
    // ignore: avoid_print
    print('result: $result');

    switch (result) {
      case SuccessResult<AuthData, CognitoIdpSignInError>(
        data: final AuthData data,
      ):
        setState(() {
          _authData = data;
        });
      case FailureResult<AuthData, CognitoIdpSignInError>(
        error: final CognitoIdpSignInError error,
      ):
        setState(() {
          _error = error;
        });

        // Full error breakdown, useful for debugging
        switch (error) {
          case StateExpiredError(
            createdAt: final DateTime createdAt,
            age: final Duration age,
            maxLifetime: final Duration maxLifetime,
          ):
            // Handle state expired
            break;
          case StateMismatchError(
            expected: final String expected,
            actual: final String actual,
          ):
            // Handle state mismatch
            break;
          case UnexpectedAuthorizationCodeFlowError(
            error: final Object innerError,
            stackTrace: final StackTrace stackTrace,
          ):
            // Handle unexpected authorization code flow error
            break;
          case WebAuthFlowUnexpectedError(
            error: final Object innerError,
            stackTrace: final StackTrace stackTrace,
          ):
            // Handle unexpected web auth flow error
            break;
          case WebAuthFlowInvalidCallbackUrlError(
            callbackUrl: final String callbackUrl,
            error: final Object innerError,
            stackTrace: final StackTrace stackTrace,
          ):
            // Handle invalid callback URL error
            break;
          case WebAuthFlowPlatformError(
            error: final PlatformException platformException,
            stackTrace: final StackTrace stackTrace,
          ):
            // Handle platform error (e.g., user cancellation)
            break;
          case PkceBundleExpiredError(
            createdAt: final DateTime createdAt,
            age: final Duration age,
            maxLifetime: final Duration maxLifetime,
          ):
            // Handle PKCE bundle expired
            break;
          case PkceBundleMissingError():
            // Handle PKCE bundle missing
            break;
          // HTTP Errors (converted from HttpError at boundary)
          case ExchangeCodeHttpRequestFailedError(
            responseBody: final Map<String, dynamic> responseBody,
            requestBody: final Map<String, dynamic> requestBody,
            requestParams: final Map<String, dynamic> requestParams,
            requestPath: final String requestPath,
            statusCode: final HttpStatusCode statusCode,
          ):
            // Handle HTTP request failure (e.g., 400, 401, 500)
            // Check statusCode for specific error handling
            if (statusCode == HttpStatusCode.unauthorized) {
              // Handle 401
            } else if (statusCode == HttpStatusCode.tooManyRequests) {
              // Handle 429
            }
            break;
          case ExchangeCodeHttpInvalidResponseBodyError(
            rawResponseBody: final String rawResponseBody,
            requestBody: final Map<String, dynamic> requestBody,
            requestParams: final Map<String, dynamic> requestParams,
            requestPath: final String requestPath,
            statusCode: final HttpStatusCode statusCode,
          ):
            // Handle invalid response body (parsing failed)
            break;
          case ExchangeCodeHttpTimeoutError(
            timeout: final Duration timeout,
            requestBody: final Map<String, dynamic> requestBody,
            requestParams: final Map<String, dynamic> requestParams,
            requestPath: final String requestPath,
          ):
            // Handle HTTP timeout
            break;
          case ExchangeCodeUnexpectedError(
            error: final Object innerError,
            stackTrace: final StackTrace stackTrace,
          ):
            // Handle unexpected exchange error
            break;
          case DecodeJwtInvalidPayloadError():
            // Handle invalid JWT payload
            break;
          case DecodeJwtUnexpectedError(
            error: final Object innerError,
            stackTrace: final StackTrace stackTrace,
          ):
            // Handle unexpected JWT decode error
            break;
          // Other Errors
          case NonceMismatchFailure(
            expectedNonce: final String expected,
            actualNonce: final String actual,
          ):
            // Handle nonce mismatch
            // Expected: $expected, Got: $actual
            break;
          case UnexpectedError(
            error: final Object innerError,
            stackTrace: final StackTrace stackTrace,
          ):
            // Handle unexpected errors
            break;
        }
    }
  }

  void _clearAuthData() {
    setState(() {
      _authData = null;
      _error = null;
    });
  }

  Future<void> _signInWithApple() async {
    _clearAuthData();
    final IdpResult result = await _cognitoIdpSignIn.signInWithCognitoIdp();
    _handleIdpResult(result);
  }

  Future<void> _signInWithGoogle() async {
    _clearAuthData();
    final IdpResult result = await _cognitoIdpSignIn.signInWithCognitoIdp(
      optionOverrides: CognitoIdpSignInOptionsOverrides(
        identityProviderName: 'Google',
        scopes: [CognitoScope.email, CognitoScope.openid, CognitoScope.profile],
      ),
    );
    _handleIdpResult(result);
  }

  Future<void> _signInWithFacebook() async {
    _clearAuthData();
    final IdpResult result = await _cognitoIdpSignIn.signInWithCognitoIdp(
      optionOverrides: CognitoIdpSignInOptionsOverrides(
        identityProviderName: 'Facebook',
      ),
    );
    _handleIdpResult(result);
  }

  @override
  Widget build(BuildContext context) {
    final authData = _authData;
    final error = _error;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              if (authData != null) _AuthDataWidget(authData: authData),
              if (error != null) _ErrorWidget(error: error),
              if (authData != null || error != null) const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _signInWithApple,
                child: const Text('Sign In With Apple'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _signInWithGoogle,
                child: const Text('Sign In With Google'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _signInWithFacebook,
                child: const Text('Sign In With Facebook'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.error});

  final CognitoIdpSignInError error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Text(
        error.toString(),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _AuthDataWidget extends StatelessWidget {
  const _AuthDataWidget({required this.authData});

  final AuthData authData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          overflow: TextOverflow.ellipsis,
        ).merge(Theme.of(context).textTheme.bodyMedium),
        maxLines: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _InfoText(label: 'ID Token:', value: authData.idToken ?? ''),
            Divider(color: Colors.grey),
            _InfoText(label: 'Access Token:', value: authData.accessToken),
            Divider(color: Colors.grey),
            _InfoText(label: 'Refresh Token:', value: authData.refreshToken),
            Divider(color: Colors.grey),
            _InfoText(label: 'Token Type:', value: authData.tokenType),
            Divider(color: Colors.grey),
            _InfoText(
              label: 'Expires In:',
              value: '${authData.expiresIn} seconds',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoText extends StatelessWidget {
  const _InfoText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style;

    return RichText(
      maxLines: 3,
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: label,
            style: style.copyWith(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' '),
          TextSpan(text: value, style: style),
        ],
      ),
    );
  }
}
