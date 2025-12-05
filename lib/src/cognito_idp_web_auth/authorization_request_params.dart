import '../utilities/pkce/code_challenge_method.dart';
import '../cognito_idp_sign_in/cognito_scope.dart';
import 'package:json_annotation/json_annotation.dart';

part 'authorization_request_params.g.dart';

@JsonSerializable()
class AuthorizationRequestParams {
  AuthorizationRequestParams({
    required this.clientId,
    this.clientSecret,
    required this.redirectUri,
    required this.state,
    required this.nonce,
    required this.identityProvider,
    required this.codeChallenge,
    required this.codeChallengeMethod,
    required this.scopes,
    this.responseType = 'code',
    this.customScopes,
  });

  @JsonKey(name: 'response_type')
  final String responseType;
  @JsonKey(name: 'client_id')
  final String clientId;
  @JsonKey(name: 'client_secret', includeIfNull: false)
  final String? clientSecret;
  @JsonKey(name: 'redirect_uri')
  final String redirectUri;
  @ScopeListConverter()
  @JsonKey(name: 'scope')
  final List<CognitoScope>? scopes;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<String>? customScopes;
  final String state;
  final String nonce;
  @JsonKey(name: 'identity_provider')
  final String identityProvider;
  @JsonKey(name: 'code_challenge')
  final String codeChallenge;
  @CodeChallengeMethodConverter()
  @JsonKey(name: 'code_challenge_method')
  final CodeChallengeMethod codeChallengeMethod;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$AuthorizationRequestParamsToJson(this);

    final List<String>? localCustomScopes = customScopes;

    if (localCustomScopes == null) {
      return json;
    }

    final dynamic currentScope = json['scope'];

    final String newScope = '$currentScope ${localCustomScopes.join(' ')}'.trim();

    json['scope'] = newScope;

    return json;
  }

  factory AuthorizationRequestParams.fromJson(Map<String, dynamic> json) => _$AuthorizationRequestParamsFromJson(json);
}

class ScopeListConverter implements JsonConverter<List<CognitoScope>, String> {
  const ScopeListConverter();

  @override
  List<CognitoScope> fromJson(String json) {
    if (json.isEmpty) return <CognitoScope>[];
    return json
        .split(' ')
        .map(
          (String e) => CognitoScope.values.firstWhere(
            (CognitoScope v) => v.name == e,
            orElse: () => throw ArgumentError('Unknown CognitoScope enum value: $e'),
          ),
        )
        .toList();
  }

  @override
  String toJson(List<CognitoScope> object) {
    if (object.isEmpty) {
      return '';
    }
    return object.map((CognitoScope e) => e.value).join(' ');
  }
}

class CodeChallengeMethodConverter implements JsonConverter<CodeChallengeMethod, String> {
  const CodeChallengeMethodConverter();

  @override
  CodeChallengeMethod fromJson(String json) {
    return CodeChallengeMethod.values.firstWhere((CodeChallengeMethod e) => e.value == json);
  }

  @override
  String toJson(CodeChallengeMethod object) {
    return object.value;
  }
}
