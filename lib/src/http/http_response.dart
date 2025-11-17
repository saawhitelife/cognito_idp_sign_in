import 'dart:async';

import '../generic/generic.dart';
import 'http_error.dart';

typedef HttpResponse<T> = Result<T, HttpError>;

extension ToModel on Future<HttpResponse<Map<String, dynamic>>> {
  Future<HttpResponse<T>> toModel<T>(T Function(Map<String, dynamic>) fromJson) {
    return then((HttpResponse<Map<String, dynamic>> response) {
      return switch (response) {
        SuccessResult<Map<String, dynamic>, HttpError>(:final Map<String, dynamic> data) => SuccessResult<T, HttpError>(
          data: fromJson(data),
        ),
        FailureResult<Map<String, dynamic>, HttpError>(:final HttpError error) => FailureResult<T, HttpError>(
          error: error,
        ),
      };
    });
  }
}
