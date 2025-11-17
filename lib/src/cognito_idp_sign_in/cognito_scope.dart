/// OpenID Connect (OIDC) scopes for AWS Cognito user pools.
///
/// These scopes authorize your app to read user information from the userInfo
/// endpoint of your user pool. When requested in OAuth 2.0 flows, they determine
/// what user attributes are included in ID tokens and userInfo responses.
///
/// Reference: [AWS Cognito Scopes Documentation](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-define-resource-servers.html)
enum CognitoScope {
  /// The minimum scope for OpenID Connect (OIDC) queries.
  ///
  /// Authorizes the ID token, the unique-identifier claim `sub`, and the ability
  /// to request other scopes. When you request the `openid` scope and no others,
  /// your user pool ID token and userInfo response include claims for all user
  /// attributes that your app client can read.
  ///
  /// Note: When you request `openid` with other OIDC scopes like `profile`,
  /// `email`, and `phone`, the contents of the ID token and userInfo response
  /// are limited to the constraints of the additional scopes.
  openid('openid'),

  /// Grants access to the user's email address.
  ///
  /// When granted, the ID token and userInfo response will include the `email`
  /// and `email_verified` claims.
  email('email'),

  /// Grants access to the user's profile information.
  ///
  /// When granted, the ID token and userInfo response will include claims such
  /// as `name`, `family_name`, `given_name`, `middle_name`, `nickname`,
  /// `preferred_username`, `profile`, `picture`, `website`, `gender`,
  /// `birthdate`, `zoneinfo`, `locale`, and `updated_at`.
  profile('profile'),

  /// The user pools reserved API scope.
  ///
  /// Authorizes self-service operations for the current user in the Amazon
  /// Cognito user pools API. It authorizes the bearer of an access token to
  /// query and update all information about the bearer with operations like
  /// GetUser and UpdateUserAttributes.
  ///
  /// This scope alone is not sufficient to request user attributes from the
  /// userInfo endpoint. For access tokens that authorize both user pools API
  /// and userInfo requests, you must request both `openid` and
  /// `aws.cognito.signin.user.admin` scopes.
  awsCognitoSigninUserAdmin('aws.cognito.signin.user.admin'),

  /// Grants access to the user's phone number.
  ///
  /// When granted, the ID token and userInfo response will include the
  /// `phone_number` and `phone_number_verified` claims.
  phone('phone');

  const CognitoScope(this.value);

  /// The string value of this scope as used in OAuth 2.0 requests.
  final String value;
}
