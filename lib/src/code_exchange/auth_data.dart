import 'package:json_annotation/json_annotation.dart';

part 'auth_data.g.dart';

/// Authentication tokens returned after successful sign-in.
///
/// Contains the OAuth 2.0 tokens issued by AWS Cognito, including access,
/// refresh, and optionally ID tokens. These tokens are used to authenticate
/// API requests and access user information.
@JsonSerializable()
class AuthData {
  const AuthData({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    this.idToken,
  });

  /// The OpenID Connect ID token containing user identity claims.
  ///
  /// This JWT contains user attributes and is used to retrieve user information.
  /// May be null if the `openid` scope was not requested.
  @JsonKey(name: 'id_token')
  final String? idToken;

  /// The OAuth 2.0 access token for API authorization.
  ///
  /// This token is used to authorize requests to APIs and the Cognito User Pools API.
  @JsonKey(name: 'access_token')
  final String accessToken;

  /// The refresh token used to obtain new access tokens.
  ///
  /// This long-lived token can be used to request new access and ID tokens
  /// without requiring the user to sign in again.
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  /// The type of the access token, typically "Bearer".
  @JsonKey(name: 'token_type')
  final String tokenType;

  /// The lifetime of the access token in seconds.
  ///
  /// Indicates how many seconds until the access token expires and needs to be refreshed.
  @JsonKey(name: 'expires_in')
  final int expiresIn;

  factory AuthData.fromJson(Map<String, dynamic> json) => _$AuthDataFromJson(json);
  Map<String, dynamic> toJson() => _$AuthDataToJson(this);

  @override
  String toString() {
    return 'AuthData(idToken: $idToken, accessToken: $accessToken, refreshToken: $refreshToken, tokenType: $tokenType, expiresIn: $expiresIn)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthData &&
        other.idToken == idToken &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.tokenType == tokenType &&
        other.expiresIn == expiresIn;
  }

  @override
  int get hashCode => Object.hash(idToken, accessToken, refreshToken, tokenType, expiresIn);
}
