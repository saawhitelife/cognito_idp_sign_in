import 'package:json_annotation/json_annotation.dart';

part 'cognito_callback_params.g.dart';

@JsonSerializable()
class CognitoCallbackParams {
  const CognitoCallbackParams({required this.code, required this.state});

  final String code;
  final String state;

  factory CognitoCallbackParams.fromJson(Map<String, dynamic> json) => _$CognitoCallbackParamsFromJson(json);
  Map<String, dynamic> toJson() => _$CognitoCallbackParamsToJson(this);
}
