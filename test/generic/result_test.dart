import 'package:cognito_idp_sign_in/src/generic/generic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('SuccessResult', () {
      final SuccessResult<String, dynamic> result = SuccessResult<String, dynamic>(data: 'data');
      expect(result.toString(), 'SuccessResult(data: data)');
    });

    test('FailureResult', () {
      final FailureResult<String, dynamic> result = FailureResult<String, dynamic>(error: 'error');
      expect(result.toString(), 'FailureResult(error: error)');
    });

    test('requireData works', () {
      final SuccessResult<String, dynamic> result = SuccessResult<String, dynamic>(data: 'data');
      expect(result.requireData, 'data');
    });

    test('requireData throws when result is FailureResult', () {
      final FailureResult<String, dynamic> result = FailureResult<String, dynamic>(error: 'error');
      expect(() => result.requireData, throwsA(isA<Exception>()));
    });
  });
}
