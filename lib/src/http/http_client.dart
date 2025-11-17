import 'dart:async';
import 'dart:convert';

import '../generic/generic.dart';
import 'http_error.dart';
import 'http_response.dart';
import 'http_status_code.dart';
import 'package:http/http.dart' as http;

class HttpClient {
  HttpClient(this._client, this._baseUrl);

  final String _baseUrl;
  final http.Client _client;

  Future<HttpResponse<Map<String, dynamic>>> post(
    String path, {
    required Map<String, dynamic> body,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final http.Response response = await _client.post(Uri.parse('$_baseUrl$path'), body: body).timeout(timeout);

      Map<String, dynamic> responseBody = <String, dynamic>{};

      final HttpStatusCode httpStatusCode = HttpStatusCode.fromCode(response.statusCode);

      try {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          return FailureResult<Map<String, dynamic>, HttpError>(
            error: HttpInvalidResponseBodyError(response.body, body, <String, dynamic>{}, path, httpStatusCode),
          );
        }
        responseBody = decoded;
      } catch (_) {
        return FailureResult<Map<String, dynamic>, HttpError>(
          error: HttpInvalidResponseBodyError(response.body, body, <String, dynamic>{}, path, httpStatusCode),
        );
      }

      if (!httpStatusCode.isSuccess) {
        return FailureResult<Map<String, dynamic>, HttpError>(
          error: HttpRequestFailedError(responseBody, body, <String, dynamic>{}, path, httpStatusCode),
        );
      }

      return SuccessResult<Map<String, dynamic>, HttpError>(data: responseBody);
    } on TimeoutException {
      return FailureResult<Map<String, dynamic>, HttpError>(
        error: HttpTimeoutError(timeout, body, <String, dynamic>{}, path),
      );
    } catch (e, stackTrace) {
      return FailureResult<Map<String, dynamic>, HttpError>(error: HttpUnexpectedError(e, stackTrace));
    }
  }
}
