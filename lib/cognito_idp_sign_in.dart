/// A Flutter library for signing in with Amazon Cognito using OAuth 2.0
/// and PKCE. Supports third-party identity providers (Apple, Google,
/// Facebook, etc.) exposed through the Cognito Hosted UI.
///
/// Built on top of `flutter_web_auth_2` with strongly-typed errors and
/// optional per-provider overrides.
library;

export 'src/cognito_idp_sign_in/cognito_idp_sign_in_impl.dart';
export 'src/cognito_idp_sign_in/cognito_idp_sign_in_options.dart';
export 'src/cognito_idp_sign_in/cognito_idp_sign_in_error.dart';
export 'src/cognito_idp_sign_in/cognito_scope.dart';
export 'src/utilities/pkce/code_challenge_method.dart';
export 'src/cognito_idp_web_auth/cognito_idp_web_auth_options.dart';
export 'src/code_exchange/auth_data.dart';
export 'src/generic/generic.dart';
export 'src/http/http_status_code.dart';
