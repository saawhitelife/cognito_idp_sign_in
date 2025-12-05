// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authorization_request_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthorizationRequestParams _$AuthorizationRequestParamsFromJson(Map<String, dynamic> json) =>
    AuthorizationRequestParams(
      clientId: json['client_id'] as String,
      clientSecret: json['client_secret'] as String?,
      redirectUri: json['redirect_uri'] as String,
      state: json['state'] as String,
      nonce: json['nonce'] as String,
      identityProvider: json['identity_provider'] as String,
      codeChallenge: json['code_challenge'] as String,
      codeChallengeMethod: const CodeChallengeMethodConverter().fromJson(json['code_challenge_method'] as String),
      scopes: _$JsonConverterFromJson<String, List<CognitoScope>>(json['scope'], const ScopeListConverter().fromJson),
      responseType: json['response_type'] as String? ?? 'code',
    );

Map<String, dynamic> _$AuthorizationRequestParamsToJson(AuthorizationRequestParams instance) => <String, dynamic>{
  'response_type': instance.responseType,
  'client_id': instance.clientId,
  'client_secret': ?instance.clientSecret,
  'redirect_uri': instance.redirectUri,
  'scope': _$JsonConverterToJson<String, List<CognitoScope>>(instance.scopes, const ScopeListConverter().toJson),
  'state': instance.state,
  'nonce': instance.nonce,
  'identity_provider': instance.identityProvider,
  'code_challenge': instance.codeChallenge,
  'code_challenge_method': const CodeChallengeMethodConverter().toJson(instance.codeChallengeMethod),
};

Value? _$JsonConverterFromJson<Json, Value>(Object? json, Value? Function(Json json) fromJson) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(Value? value, Json? Function(Value value) toJson) =>
    value == null ? null : toJson(value);
