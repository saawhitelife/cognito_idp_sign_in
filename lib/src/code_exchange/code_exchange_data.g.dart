// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_exchange_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodeExchangeData _$CodeExchangeDataFromJson(Map<String, dynamic> json) => CodeExchangeData(
  grantType: json['grant_type'] as String? ?? 'authorization_code',
  clientId: json['client_id'] as String,
  clientSecret: json['client_secret'] as String?,
  code: json['code'] as String,
  redirectUri: json['redirect_uri'] as String,
  codeVerifier: json['code_verifier'] as String,
);

Map<String, dynamic> _$CodeExchangeDataToJson(CodeExchangeData instance) => <String, dynamic>{
  'grant_type': instance.grantType,
  'client_id': instance.clientId,
  'client_secret': ?instance.clientSecret,
  'code': instance.code,
  'redirect_uri': instance.redirectUri,
  'code_verifier': instance.codeVerifier,
};
