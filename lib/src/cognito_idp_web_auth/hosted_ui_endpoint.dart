import '../code_exchange/cognito_oauth_endpoints.dart';

class HostedUiEndpoint {
  HostedUiEndpoint({this.scheme = 'https', required this.host, this.path = CognitoOAuthEndpoints.authorize});

  final String scheme;
  final String host;
  final String path;
}
