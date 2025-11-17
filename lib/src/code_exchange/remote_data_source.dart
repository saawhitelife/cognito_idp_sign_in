import 'auth_data.dart';
import 'code_exchange_data.dart';
import 'cognito_oauth_endpoints.dart';
import '../http/http.dart';

class RemoteDataSource {
  RemoteDataSource({required this.client});
  final HttpClient client;

  Future<HttpResponse<AuthData>> exchangeCodeForAuthData(CodeExchangeData codeExchangeData) async {
    return client
        .post(CognitoOAuthEndpoints.token, body: codeExchangeData.toJson())
        .toModel<AuthData>((Map<String, dynamic> data) => AuthData.fromJson(data));
  }
}
