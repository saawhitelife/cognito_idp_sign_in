import 'package:cognito_idp_sign_in/src/code_exchange/code_exchange.dart';
import 'package:cognito_idp_sign_in/src/cognito_idp_sign_in/index.dart'
    hide WebAuthFlowUnexpectedError, WebAuthFlowInvalidCallbackUrlError, WebAuthFlowPlatformError;
import 'package:cognito_idp_sign_in/src/cognito_idp_web_auth/cognito_idp_web_auth.dart';
import 'package:cognito_idp_sign_in/src/generic/generic.dart';
import 'package:cognito_idp_sign_in/src/utilities/utilities.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

class FakeWebAuth implements WebAuth {
  FakeWebAuth({required this.result});
  final Future<String> result;

  String? lastUrl;
  String? lastScheme;

  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    CognitoIdpWebAuthOptions? options,
  }) {
    lastUrl = url;
    lastScheme = callbackUrlScheme;
    return result;
  }
}

void main() {
  group('CognitoIdpWebAuth.startWebAuthFlow', () {
    const String hostedUiDomain = 'example.auth.us-east-1.amazoncognito.com';
    const String redirectUriString = 'myapp://cb';
    final Uri redirectUri = Uri.parse(redirectUriString);
    const String clientId = 'client-123';
    const String clientSecret = 'client-secret-xyz';
    const String state = 'st-xyz';
    const String nonce = 'nonce-abc';
    const String identityProvider = 'SignInWithApple';
    const String codeChallenge = 'challenge123';
    const CodeChallengeMethod codeChallengeMethod = .s256;
    const List<CognitoScope> scopes = <CognitoScope>[.openid, .email, .profile, .awsCognitoSigninUserAdmin];
    const List<String> customScopes = <String>['profile.read'];

    CognitoIdpWebAuth buildCognitoIdpWebAuth(FakeWebAuth fake) => CognitoIdpWebAuth(fake);

    test('success: constructs URL correctly and parses callback params', () async {
      // Simulate the redirect back with code & state in the URL:
      final String code = 'authCode';
      final String callback = '$redirectUriString?code=$code&state=$state';

      final FakeWebAuth fake = FakeWebAuth(result: Future<String>.value(callback));
      final CognitoIdpWebAuth sut = buildCognitoIdpWebAuth(fake);

      final WebAuthFlowResult res = await sut.startWebAuthFlow(
        clientId: clientId,
        clientSecret: clientSecret,
        redirectUri: redirectUri,
        state: state,
        nonce: nonce,
        identityProvider: identityProvider,
        codeChallenge: codeChallenge,
        codeChallengeMethod: codeChallengeMethod,
        scopes: scopes,
        customScopes: customScopes,
        hostedUiDomain: hostedUiDomain,
      );

      // 1) Verify we got Success with parsed params:
      expect(res, isA<SuccessResult<CognitoCallbackParams, Object>>());
      switch (res) {
        case SuccessResult<CognitoCallbackParams, Object>(data: final CognitoCallbackParams data):
          expect(data.code, code);
          expect(data.state, state);
        case FailureResult<CognitoCallbackParams, Object>():
          fail('Expected success');
      }

      // 2) Verify the URL we asked FlutterWebAuth2 to open:
      expect(fake.lastScheme, redirectUri.scheme);
      expect(fake.lastUrl, isNotNull);

      final Uri uri = Uri.parse(fake.lastUrl!);

      expect(uri.scheme, equals('https'));
      expect(uri.host, hostedUiDomain);
      expect(uri.path, CognitoOAuthEndpoints.authorize);

      final Map<String, String> qp = uri.queryParameters;
      expect(qp['client_id'], clientId);
      expect(qp['client_secret'], clientSecret);
      expect(qp['redirect_uri'], redirectUri.toString());
      expect(qp['state'], state);
      expect(qp['nonce'], nonce);
      expect(qp['identity_provider'], identityProvider);
      expect(qp['code_challenge'], codeChallenge);
      expect(qp['code_challenge_method'], equals(CodeChallengeMethod.s256.value));

      expect(qp['scope'], contains(CognitoScope.openid.value));
      expect(qp['scope'], contains(CognitoScope.email.value));
      expect(qp['scope'], contains(CognitoScope.awsCognitoSigninUserAdmin.value));
      expect(qp['scope'], contains(CognitoScope.profile.value));
      expect(qp['scope'], contains(customScopes.join(' ')));
    });

    test('failure: surfaces generic exceptions in WebAuthFlowUnexpectedError', () async {
      final FakeWebAuth fake = FakeWebAuth(result: Future<String>.error(Exception('boom')));
      final CognitoIdpWebAuth sut = buildCognitoIdpWebAuth(fake);

      final WebAuthFlowResult res = await sut.startWebAuthFlow(
        clientId: clientId,
        clientSecret: clientSecret,
        redirectUri: redirectUri,
        state: state,
        nonce: nonce,
        identityProvider: identityProvider,
        codeChallenge: codeChallenge,
        codeChallengeMethod: codeChallengeMethod,
        scopes: scopes,
        customScopes: customScopes,
        hostedUiDomain: hostedUiDomain,
      );

      expect(res, isA<FailureResult<CognitoCallbackParams, WebAuthFlowError>>());
      switch (res) {
        case SuccessResult<CognitoCallbackParams, WebAuthFlowError>():
          fail('Expected failure');
        case FailureResult<CognitoCallbackParams, WebAuthFlowError>(error: final WebAuthFlowError error):
          expect(error, isA<WebAuthFlowError>());
          expect(error, isA<WebAuthFlowUnexpectedError>());
          switch (error) {
            case WebAuthFlowUnexpectedError(
              error: final Object innerError,
              stackTrace: final StackTrace innerStackTrace,
            ):
              expect(innerError, isA<Exception>());
              expect(innerStackTrace, isNotNull);
            default:
              fail('Expected WebAuthFlowUnexpectedError');
          }
      }
    });

    test('failure: surfaces PlatformException (e.g., user cancellation)', () async {
      final FakeWebAuth fake = FakeWebAuth(
        result: Future<String>.error(PlatformException(code: 'canceled', message: 'User canceled')),
      );
      final CognitoIdpWebAuth sut = buildCognitoIdpWebAuth(fake);

      final WebAuthFlowResult res = await sut.startWebAuthFlow(
        clientId: clientId,
        clientSecret: clientSecret,
        redirectUri: redirectUri,
        state: state,
        nonce: nonce,
        identityProvider: identityProvider,
        codeChallenge: codeChallenge,
        codeChallengeMethod: codeChallengeMethod,
        scopes: scopes,
        customScopes: customScopes,
        hostedUiDomain: hostedUiDomain,
      );

      expect(res, isA<FailureResult<CognitoCallbackParams, WebAuthFlowError>>());
      switch (res) {
        case SuccessResult<CognitoCallbackParams, WebAuthFlowError>():
          fail('Expected failure');
        case FailureResult<CognitoCallbackParams, WebAuthFlowError>(error: final WebAuthFlowError error):
          expect(error, isA<WebAuthFlowError>());
          expect(error, isA<WebAuthFlowPlatformError>());
          switch (error) {
            case WebAuthFlowPlatformError(
              error: final PlatformException innerError,
              stackTrace: final StackTrace innerStackTrace,
            ):
              expect(innerError, isA<PlatformException>());
              expect(innerStackTrace, isNotNull);
            default:
              fail('Expected WebAuthFlowPlatformError');
          }
      }
    });

    test('failure: surfaces TypeError in WebAuthFlowInvalidCallbackUrlError', () async {
      final FakeWebAuth fake = FakeWebAuth(result: Future<String>.value('invalid-callback-url'));
      final CognitoIdpWebAuth sut = buildCognitoIdpWebAuth(fake);

      final WebAuthFlowResult res = await sut.startWebAuthFlow(
        clientId: clientId,
        clientSecret: clientSecret,
        redirectUri: redirectUri,
        state: state,
        nonce: nonce,
        identityProvider: identityProvider,
        codeChallenge: codeChallenge,
        codeChallengeMethod: codeChallengeMethod,
        scopes: scopes,
        customScopes: customScopes,
        hostedUiDomain: hostedUiDomain,
      );

      expect(res, isA<FailureResult<CognitoCallbackParams, WebAuthFlowError>>());
      switch (res) {
        case SuccessResult<CognitoCallbackParams, WebAuthFlowError>():
          fail('Expected failure');
        case FailureResult<CognitoCallbackParams, WebAuthFlowError>(error: final WebAuthFlowError error):
          expect(error, isA<WebAuthFlowError>());
          expect(error, isA<WebAuthFlowInvalidCallbackUrlError>());
          switch (error) {
            case WebAuthFlowInvalidCallbackUrlError(
              callbackUrl: final String innerCallbackUrl,
              error: final Object innerError,
              stackTrace: final StackTrace innerStackTrace,
            ):
              expect(innerCallbackUrl, 'invalid-callback-url');
              expect(innerError, isA<TypeError>());
              expect(innerStackTrace, isNotNull);
            default:
              fail('Expected WebAuthFlowInvalidCallbackUrlError');
          }
      }
    });
  });
}
