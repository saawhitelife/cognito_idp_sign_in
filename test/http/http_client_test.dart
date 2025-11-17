import 'dart:convert';
import 'package:cognito_idp_sign_in/src/generic/generic.dart';
import 'package:cognito_idp_sign_in/src/http/http.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const String baseUrl = 'https://example.com';
  const String path = '/mock';

  group('HttpClient.post', () {
    test('returns Success when 200 and body is a JSON object', () async {
      final MockClient mock = MockClient((http.Request request) async {
        expect(request.url.toString(), '$baseUrl$path');
        expect(request.method, 'POST');
        expect(request.body, contains('valid'));
        return http.Response(jsonEncode(<String, String>{'valid': 'response'}), 200);
      });

      final HttpClient client = HttpClient(mock, baseUrl);

      final HttpResponse<Map<String, dynamic>> res = await client.post(path, body: <String, dynamic>{'valid': 'body'});

      expect(res, isA<SuccessResult<Map<String, dynamic>, HttpError>>());

      final SuccessResult<Map<String, dynamic>, HttpError> ok = res as SuccessResult<Map<String, dynamic>, HttpError>;

      expect(ok.data['valid'], 'response');
    });

    test('returns Failure(HttpInvalidResponseBodyError) when JSON is not an object', () async {
      final MockClient mock = MockClient((_) async => http.Response(jsonEncode(<String>['not', 'an', 'object']), 200));

      final HttpClient client = HttpClient(mock, baseUrl);

      final HttpResponse<Map<String, dynamic>> res = await client.post(path, body: <String, dynamic>{'valid': 'body'});

      expect(res, isA<FailureResult<Map<String, dynamic>, HttpError>>());
      final HttpError err = (res as FailureResult<Map<String, dynamic>, HttpError>).error;
      expect(err, isA<HttpInvalidResponseBodyError>());
      expect((err as HttpInvalidResponseBodyError).rawResponseBody, isNotEmpty);
    });

    test('returns Failure(HttpInvalidResponseBodyError) when JSON is not valid', () async {
      final String responseBody = 'not-a-json';

      final MockClient mock = MockClient((_) async => http.Response(responseBody, 200));

      final HttpClient client = HttpClient(mock, baseUrl);

      final HttpResponse<Map<String, dynamic>> res = await client.post(path, body: <String, dynamic>{'valid': 'body'});

      expect(res, isA<FailureResult<Map<String, dynamic>, HttpError>>());
      final HttpError err = (res as FailureResult<Map<String, dynamic>, HttpError>).error;
      expect(err, isA<HttpInvalidResponseBodyError>());

      final HttpInvalidResponseBodyError castedErr = err as HttpInvalidResponseBodyError;
      expect(castedErr.rawResponseBody, responseBody);
      expect(castedErr.requestBody, <String, String>{'valid': 'body'});
      expect(castedErr.requestParams, <dynamic, dynamic>{});
      expect(castedErr.requestPath, path);
    });

    test('returns Failure(HttpRequestFailedError) when status is non-success', () async {
      final Map<String, String> requestBody = <String, String>{'valid': 'body'};
      final Map<String, String> responseBody = <String, String>{'error': 'invalid_request'};

      final MockClient mock = MockClient((_) async => http.Response(jsonEncode(responseBody), 400));

      final HttpClient client = HttpClient(mock, baseUrl);

      final HttpResponse<Map<String, dynamic>> res = await client.post(path, body: requestBody);

      expect(res, isA<FailureResult<Map<String, dynamic>, HttpError>>());
      final HttpError err = (res as FailureResult<Map<String, dynamic>, HttpError>).error;
      expect(err, isA<HttpRequestFailedError>());

      final HttpRequestFailedError hre = err as HttpRequestFailedError;
      expect(hre.statusCode, HttpStatusCode.fromCode(400));
      expect(hre.responseBody, responseBody);
      expect(hre.requestBody, requestBody);
      expect(hre.requestParams, <dynamic, dynamic>{});
      expect(hre.requestPath, path);
    });

    test('returns Failure(HttpUnexpectedError) when client throws', () async {
      final MockClient mock = MockClient((_) async => throw Exception('network down'));

      final HttpClient client = HttpClient(mock, baseUrl);
      final HttpResponse<Map<String, dynamic>> res = await client.post(path, body: <String, dynamic>{'k': 'v'});

      expect(res, isA<FailureResult<Map<String, dynamic>, HttpError>>());
      expect((res as FailureResult<Map<String, dynamic>, HttpError>).error, isA<HttpUnexpectedError>());
    });

    test('returns HttpTimeoutError when request exceeds timeout', () async {
      final Map<String, String> body = <String, String>{
        'grant_type': 'authorization_code',
        'client_id': 'abc',
        'code': '123',
        'redirect_uri': 'app://cb',
        'code_verifier': 'ver',
      };

      const Duration reqTimeout = Duration(seconds: 1);

      final MockClient mockClient = MockClient((http.Request request) async {
        await Future<void>.delayed(const Duration(seconds: 5));
        return http.Response('{"ignored":true}', 200);
      });

      final HttpClient client = HttpClient(mockClient, baseUrl);

      final HttpResponse<Map<String, dynamic>> result = await client.post(path, body: body, timeout: reqTimeout);

      expect(result, isA<FailureResult<Map<String, dynamic>, HttpError>>());

      final FailureResult<Map<String, dynamic>, HttpError> failure =
          result as FailureResult<Map<String, dynamic>, HttpError>;
      expect(failure.error, isA<HttpTimeoutError>());

      final HttpTimeoutError err = failure.error as HttpTimeoutError;
      expect(err.timeout, reqTimeout);
      expect(err.requestPath, path);
      expect(err.requestBody, body);
      expect(err.requestParams, isEmpty);
    });
  });
}
