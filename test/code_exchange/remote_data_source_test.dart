import 'package:cognito_idp_sign_in/src/code_exchange/code_exchange.dart';
import 'package:cognito_idp_sign_in/src/generic/generic.dart';
import 'package:cognito_idp_sign_in/src/http/http.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  late MockHttpClient http;
  late RemoteDataSource dataSource;

  setUp(() {
    http = MockHttpClient();
    dataSource = RemoteDataSource(client: http);
    registerFallbackValue(<String, dynamic>{});
  });

  test('calls /oauth2/token with CodeExchangeData.toJson body', () async {
    final CodeExchangeData code = CodeExchangeData(
      clientId: 'abc',
      code: 'theAuthCode',
      redirectUri: 'myapp://cb',
      codeVerifier: 'verifier123',
    );

    // Return a successful response with model-shaped JSON
    when(() => http.post(any(), body: any(named: 'body'))).thenAnswer((_) async {
      return SuccessResult<Map<String, dynamic>, HttpError>(
        data: <String, dynamic>{
          'id_token': 'id',
          'access_token': 'acc',
          'refresh_token': 'ref',
          'expires_in': 3600,
          'token_type': 'Bearer',
        },
      );
    });

    await dataSource.exchangeCodeForAuthData(code);

    verify(() => http.post(CognitoOAuthEndpoints.token, body: code.toJson())).called(1);
  });

  test('maps success payload into AuthData', () async {
    when(() => http.post(any(), body: any(named: 'body'))).thenAnswer(
      (_) async => SuccessResult<Map<String, dynamic>, HttpError>(
        data: <String, dynamic>{
          'id_token': 'ID123',
          'access_token': 'ACC456',
          'refresh_token': 'REF789',
          'expires_in': 3600,
          'token_type': 'Bearer',
        },
      ),
    );

    final HttpResponse<AuthData> response = await dataSource.exchangeCodeForAuthData(
      CodeExchangeData(clientId: 'abc', code: 'theAuthCode', redirectUri: 'myapp://cb', codeVerifier: 'verifier123'),
    );

    switch (response) {
      case SuccessResult<AuthData, HttpError>(data: final AuthData auth):
        expect(auth.idToken, 'ID123');
        expect(auth.accessToken, 'ACC456');
        expect(auth.refreshToken, 'REF789');
      case FailureResult<AuthData, HttpError>(error: final HttpError err):
        fail('Expected success, got failure: $err');
    }
  });

  test('propagates failure from HttpClient', () async {
    when(() => http.post(any(), body: any(named: 'body'))).thenAnswer(
      (_) async => FailureResult<Map<String, dynamic>, HttpError>(
        error: HttpRequestFailedError(
          <String, dynamic>{},
          <String, dynamic>{},
          <String, dynamic>{},
          '/some/path',
          HttpStatusCode.fromCode(400),
        ),
      ),
    );

    final HttpResponse<AuthData> res = await dataSource.exchangeCodeForAuthData(
      CodeExchangeData(clientId: 'abc', code: 'code', redirectUri: 'uri', codeVerifier: 'ver'),
    );

    switch (res) {
      case SuccessResult<AuthData, HttpError>():
        fail('Expected failure');
      case FailureResult<AuthData, HttpError>(error: final HttpError err):
        expect(err, isA<HttpRequestFailedError>());
    }
  });

  test('passes through original error details', () async {
    final CodeExchangeData codeExchangeData = CodeExchangeData(
      clientId: 'abc',
      code: 'theAuthCode',
      redirectUri: 'myapp://cb',
      codeVerifier: 'verifier123',
    );

    final Map<String, String> responseBody = <String, String>{'error': 'invalid_grant'};
    final Map<String, dynamic> requestBody = codeExchangeData.toJson();
    final String requestPath = CognitoOAuthEndpoints.token;
    final HttpStatusCode status = HttpStatusCode.fromCode(400);

    final HttpRequestFailedError returnedError = HttpRequestFailedError(
      responseBody,
      requestBody,
      <String, dynamic>{}, // params
      requestPath,
      status,
    );

    when(
      () => http.post(any(), body: any(named: 'body')),
    ).thenAnswer((_) async => FailureResult<Map<String, dynamic>, HttpError>(error: returnedError));

    final HttpResponse<AuthData> response = await dataSource.exchangeCodeForAuthData(codeExchangeData);

    switch (response) {
      case SuccessResult<AuthData, HttpError>():
        fail('Expected failure');
      case FailureResult<AuthData, HttpError>(error: final HttpError err):
        switch (err) {
          case final HttpRequestFailedError error:
            expect(identical(error, returnedError), isTrue, reason: 'Error instance should be preserved');
          default:
            fail('Expected HttpRequestFailedError');
        }
    }
  });
}
