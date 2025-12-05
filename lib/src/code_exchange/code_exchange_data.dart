import 'package:json_annotation/json_annotation.dart';

part 'code_exchange_data.g.dart';

@JsonSerializable()
class CodeExchangeData {
  const CodeExchangeData({
    this.grantType = 'authorization_code',
    required this.clientId,
    this.clientSecret,
    required this.code,
    required this.redirectUri,
    required this.codeVerifier,
  });
  @JsonKey(name: 'grant_type')
  final String grantType;
  @JsonKey(name: 'client_id')
  final String clientId;
  @JsonKey(name: 'client_secret', includeIfNull: false)
  final String? clientSecret;
  @JsonKey(name: 'code')
  final String code;
  @JsonKey(name: 'redirect_uri')
  final String redirectUri;
  @JsonKey(name: 'code_verifier')
  final String codeVerifier;

  factory CodeExchangeData.fromJson(Map<String, dynamic> json) => _$CodeExchangeDataFromJson(json);
  Map<String, dynamic> toJson() => _$CodeExchangeDataToJson(this);

  @override
  String toString() {
    return 'CodeExchangeData(grantType: $grantType, clientId: $clientId, clientSecret: $clientSecret, code: $code, redirectUri: $redirectUri, codeVerifier: $codeVerifier)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CodeExchangeData &&
        other.grantType == grantType &&
        other.clientId == clientId &&
        other.clientSecret == clientSecret &&
        other.code == code &&
        other.redirectUri == redirectUri &&
        other.codeVerifier == codeVerifier;
  }

  @override
  int get hashCode => Object.hash(grantType, clientId, clientSecret, code, redirectUri, codeVerifier);
}
