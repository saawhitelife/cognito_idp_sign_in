import 'package:cognito_idp_sign_in/src/generic/generic.dart';
import 'package:cognito_idp_sign_in/src/http/http.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ToModel.toModel', () {
    test('maps SuccessResult<Map> -> SuccessResult<T> using fromJson', () async {
      int fromJsonCalls = 0;

      final Future<HttpResponse<Map<String, dynamic>>> input = Future<HttpResponse<Map<String, dynamic>>>.value(
        SuccessResult<Map<String, dynamic>, HttpError>(data: <String, dynamic>{'v': 42}),
      );

      final HttpResponse<int> res = await input.toModel<int>((Map<String, dynamic> m) {
        fromJsonCalls++;
        return m['v'] as int;
      });

      expect(fromJsonCalls, 1);
      expect(res, isA<SuccessResult<int, HttpError>>());
      switch (res) {
        case SuccessResult<int, HttpError>(:final int data):
          expect(data, 42);
        case FailureResult<int, HttpError>():
          fail('Expected success');
      }
    });

    test('passes through FailureResult unchanged (same error instance)', () async {
      final HttpUnexpectedError error = HttpUnexpectedError('boom', StackTrace.current);

      final Future<HttpResponse<Map<String, dynamic>>> input = Future<HttpResponse<Map<String, dynamic>>>.value(
        FailureResult<Map<String, dynamic>, HttpError>(error: error),
      );

      final HttpResponse<int> res = await input.toModel<int>((_) => 0);

      expect(res, isA<FailureResult<int, HttpError>>());
      switch (res) {
        case SuccessResult<int, HttpError>():
          fail('Expected failure');
        case FailureResult<int, HttpError>(:final HttpError error):
          expect(identical(error, error), isTrue, reason: 'Error instance should be preserved');
      }
    });

    test('bubbles exception thrown by fromJson', () async {
      final Future<HttpResponse<Map<String, dynamic>>> input = Future<HttpResponse<Map<String, dynamic>>>.value(
        SuccessResult<Map<String, dynamic>, HttpError>(data: <String, dynamic>{'bad': 'data'}),
      );

      // fromJson throws → Future should complete with error
      await expectLater(input.toModel<int>((_) => throw StateError('parse fail')), throwsA(isA<StateError>()));
    });
  });
}
