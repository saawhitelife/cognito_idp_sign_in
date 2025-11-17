import 'package:cognito_idp_sign_in/src/cognito_idp_sign_in/index.dart';
import 'package:cognito_idp_sign_in/src/cognito_idp_web_auth/cognito_idp_web_auth.dart';
import 'package:cognito_idp_sign_in/src/utilities/utilities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CognitoIdpSignInOptions', () {
    test('applyOverrides', () {
      const CognitoIdpWebAuthOptions webAuthOptions = CognitoIdpWebAuthOptions(
        preferEphemeral: false,
        debugOrigin: 'https://example.com',
        intentFlags: 1,
        windowName: 'window-name',
        timeout: 1000,
        landingPageHtml: 'landing-page-html',
        silentAuth: true,
        useWebview: false,
        httpsHost: 'https://example.com',
      );
      final CognitoIdpSignInOptions options = CognitoIdpSignInOptions(
        poolId: 'us-east-1_test',
        clientId: 'client-123',
        hostedUiDomain: 'example.auth.us-east-1.amazoncognito.com',
        redirectUri: Uri.parse('myapp://'),
        identityProviderName: 'SignInWithApple',
        scopes: <CognitoScope>[.openid],
        customScopes: <CustomScope>['custom-scope-1'],
        codeChallengeMethod: .plain,
        nonceLength: 43,
        stateLength: 43,
        pkceBundleLifetime: Duration(minutes: 5),
        webAuthOptions: webAuthOptions,
      );

      const CognitoIdpWebAuthOptions newWebAuthOptions = CognitoIdpWebAuthOptions(preferEphemeral: true);

      final CognitoIdpSignInOptionsOverrides overrides = CognitoIdpSignInOptionsOverrides(
        poolId: 'us-east-1_test_overriden',
        clientId: 'client-123_overriden',
        hostedUiDomain: 'example.auth.us-east-1.amazoncognito.com_overriden',
        redirectUri: Uri.parse('myappoverriden://'),
        identityProviderName: 'SignInWithApple_overriden',
        scopes: <CognitoScope>[.email],
        customScopes: <CustomScope>['custom-scope-1_overriden', 'custom-scope-2_overriden'],
        codeChallengeMethod: .s256,
        nonceLength: 43 + 1,
        stateLength: 43 + 1,
        pkceBundleLifetime: const Duration(minutes: 5) + const Duration(minutes: 1),
        webAuthOptions: newWebAuthOptions,
      );

      final CognitoIdpSignInOptions result = options.applyOverrides(overrides: overrides);

      expect(result.poolId, 'us-east-1_test_overriden');
      expect(result.clientId, 'client-123_overriden');
      expect(result.hostedUiDomain, 'example.auth.us-east-1.amazoncognito.com_overriden');
      expect(result.redirectUri, Uri.parse('myappoverriden://'));
      expect(result.identityProviderName, 'SignInWithApple_overriden');
      expect(result.scopes, <CognitoScope>[.email]);
      expect(result.customScopes, <CustomScope>['custom-scope-1_overriden', 'custom-scope-2_overriden']);
      expect(result.codeChallengeMethod, CodeChallengeMethod.s256);
      expect(result.nonceLength, 43 + 1);
      expect(result.stateLength, 43 + 1);
      expect(result.pkceBundleLifetime, const Duration(minutes: 5) + const Duration(minutes: 1));
      expect(result.webAuthOptions, newWebAuthOptions);

      expect(result.webAuthOptions.toJson(), newWebAuthOptions.toJson());
    });
  });
}
