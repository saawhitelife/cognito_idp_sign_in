import 'package:cognito_idp_sign_in/src/cognito_idp_sign_in/index.dart';
import 'package:cognito_idp_sign_in/src/cognito_idp_web_auth/cognito_idp_web_auth.dart';
import 'package:cognito_idp_sign_in/src/utilities/utilities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthorizationRequestParams.toJson', () {
    test('merges scopes and customScopes into "scope" string', () {
      final String challenge = 'challenge';
      final String identityProvider = 'SignInWithApple';
      final String clientId = 'client';
      final String redirectUri = 'myapp://cb';
      final String state = 'state123';
      final String nonce = 'nonce123';
      final String responseType = 'code';

      final AuthorizationRequestParams params = AuthorizationRequestParams(
        clientId: clientId,
        responseType: responseType,
        redirectUri: redirectUri,
        state: state,
        nonce: nonce,
        identityProvider: identityProvider,
        codeChallenge: challenge,
        codeChallengeMethod: .s256,
        scopes: const <CognitoScope>[.openid, .email],
        customScopes: const <String>['profile.read', 'phone.write'],
      );

      final Map<String, dynamic> json = params.toJson();

      // Standard fields
      expect(json['client_id'], clientId);
      expect(json['redirect_uri'], redirectUri);
      expect(json['state'], state);
      expect(json['nonce'], nonce);
      expect(json['identity_provider'], identityProvider);
      expect(json['code_challenge'], challenge);
      expect(json['code_challenge_method'], CodeChallengeMethod.s256.value);
      expect(json['response_type'], responseType);

      // Scope should contain both enum scopes and custom scopes
      final String scope = json['scope'] as String;
      expect(scope, 'openid email profile.read phone.write');

      // No accidental double spaces
      expect(scope.contains('  '), isFalse);
    });

    test('fromJson works', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'client_id': 'client',
        'redirect_uri': 'myapp://cb',
        'state': 's',
        'nonce': 'n',
        'identity_provider': 'SignInWithApple',
        'code_challenge': 'c',
        'code_challenge_method': CodeChallengeMethod.s256.value,
        'response_type': 'code',
        'scope': 'openid email',
      };

      final AuthorizationRequestParams params = AuthorizationRequestParams.fromJson(json);

      expect(params.clientId, 'client');
      expect(params.redirectUri, 'myapp://cb');
      expect(params.state, 's');
      expect(params.nonce, 'n');
      expect(params.identityProvider, 'SignInWithApple');
      expect(params.codeChallenge, 'c');
      expect(params.codeChallengeMethod, CodeChallengeMethod.s256);
      expect(params.responseType, 'code');
      expect(params.scopes, <CognitoScope>[.openid, .email]);
    });

    test('keeps scope from scopes when customScopes is null', () {
      final String clientId = 'client';
      final String redirectUri = 'myapp://cb';
      final String state = 's';
      final String nonce = 'n';
      final String identityProvider = 'SignInWithApple';
      final String challenge = 'c';
      final CodeChallengeMethod codeChallengeMethod = .s256;

      final AuthorizationRequestParams params = AuthorizationRequestParams(
        clientId: clientId,
        redirectUri: redirectUri,
        state: state,
        nonce: nonce,
        identityProvider: identityProvider,
        codeChallenge: challenge,
        codeChallengeMethod: codeChallengeMethod,
        scopes: const <CognitoScope>[.openid],
        customScopes: null,
      );

      final Map<String, dynamic> json = params.toJson();
      expect(json['scope'], 'openid');
    });

    test('handles empty scopes + customScopes gracefully', () {
      final AuthorizationRequestParams params = AuthorizationRequestParams(
        clientId: 'client',
        redirectUri: 'myapp://cb',
        state: 's',
        nonce: 'n',
        identityProvider: 'SignInWithApple',
        codeChallenge: 'c',
        codeChallengeMethod: .s256,
        scopes: const <CognitoScope>[], // Empty
        customScopes: const <String>['profile.read'],
      );

      final Map<String, dynamic> json = params.toJson();

      expect(json['scope'], 'profile.read');
    });
  });

  group('ScopeListConverter', () {
    const ScopeListConverter converter = ScopeListConverter();

    test('toJson joins scopes with spaces', () {
      final String s = converter.toJson(const <CognitoScope>[.openid, .email]);
      expect(s, 'openid email');
    });

    test('toJson returns empty string for empty list', () {
      expect(converter.toJson(const <CognitoScope>[]), '');
    });

    test('fromJson parses space-separated list', () {
      final List<CognitoScope> list = converter.fromJson('openid email');
      expect(list, <CognitoScope>[.openid, .email]);
    });

    test('fromJson returns empty list for empty string', () {
      expect(converter.fromJson(''), isEmpty);
    });

    test('fromJson throws on unknown scope', () {
      expect(() => converter.fromJson('unknown_scope'), throwsA(isA<ArgumentError>()));
    });
  });

  group('CodeChallengeMethodConverter', () {
    const CodeChallengeMethodConverter conv = CodeChallengeMethodConverter();

    test('round-trip conversion', () {
      final String encoded = conv.toJson(.s256);
      final CodeChallengeMethod decoded = conv.fromJson(encoded);
      expect(decoded, CodeChallengeMethod.s256);
    });
  });
}
