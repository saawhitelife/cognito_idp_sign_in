import '../utilities/pkce/code_challenge_method.dart';
import '../cognito_idp_sign_in/cognito_scope.dart';
import 'authorization_request_params.dart';
import 'cognito_callback_params.dart';
import 'cognito_idp_web_auth_options.dart';
import 'hosted_ui_endpoint.dart';
import 'web_auth.dart';
import 'web_auth_flow_error.dart';
import '../generic/generic.dart';
import 'package:flutter/services.dart';

typedef WebAuthFlowResult = Result<CognitoCallbackParams, WebAuthFlowError>;

class CognitoIdpWebAuth {
  CognitoIdpWebAuth(this._webAuth);

  final WebAuth _webAuth;

  Future<WebAuthFlowResult> startWebAuthFlow({
    required String clientId,
    required Uri redirectUri,
    required String state,
    required String nonce,
    required String identityProvider,
    required String codeChallenge,
    required CodeChallengeMethod codeChallengeMethod,
    required List<CognitoScope> scopes,
    required List<String> customScopes,
    required String hostedUiDomain,
    CognitoIdpWebAuthOptions? webAuthOptions,
  }) async {
    try {
      final AuthorizationRequestParams authorizationUriQueryParams = AuthorizationRequestParams(
        clientId: clientId,
        redirectUri: redirectUri.toString(),
        state: state,
        nonce: nonce,
        identityProvider: identityProvider,
        codeChallenge: codeChallenge,
        codeChallengeMethod: codeChallengeMethod,
        scopes: scopes,
        customScopes: customScopes,
      );

      final HostedUiEndpoint authorizationUriParams = HostedUiEndpoint(host: hostedUiDomain);

      final Uri authorizeUri = Uri(
        scheme: authorizationUriParams.scheme,
        host: authorizationUriParams.host,
        path: authorizationUriParams.path,
        queryParameters: authorizationUriQueryParams.toJson(),
      );

      final String callbackUrl = await _webAuth.authenticate(
        url: authorizeUri.toString(),
        callbackUrlScheme: redirectUri.scheme,
        options: webAuthOptions,
      );

      try {
        final CognitoCallbackParams parameters = CognitoCallbackParams.fromJson(Uri.parse(callbackUrl).queryParameters);
        return SuccessResult<CognitoCallbackParams, WebAuthFlowError>(data: parameters);
      } catch (e, stackTrace) {
        return FailureResult<CognitoCallbackParams, WebAuthFlowError>(
          error: WebAuthFlowInvalidCallbackUrlError(callbackUrl: callbackUrl, error: e, stackTrace: stackTrace),
        );
      }
    } on PlatformException catch (e, stackTrace) {
      return FailureResult<CognitoCallbackParams, WebAuthFlowError>(
        error: WebAuthFlowPlatformError(error: e, stackTrace: stackTrace),
      );
    } catch (e, stackTrace) {
      return FailureResult<CognitoCallbackParams, WebAuthFlowError>(
        error: WebAuthFlowUnexpectedError(error: e, stackTrace: stackTrace),
      );
    }
  }
}
