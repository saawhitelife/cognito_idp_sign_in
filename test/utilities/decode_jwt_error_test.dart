import 'package:cognito_idp_sign_in/src/utilities/utilities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DecodeJwtError', () {
    test('DecodeJwtInvalidPayloadError', () {
      expect(const DecodeJwtInvalidPayloadError().toString(), 'DecodeJwtInvalidPayloadError');
    });

    test('DecodeJwtUnexpectedError', () {
      final Exception error = Exception('Unexpected error');
      final StackTrace stackTrace = StackTrace.current;

      expect(
        DecodeJwtUnexpectedError(error, stackTrace).toString(),
        'DecodeJwtUnexpectedError(error: $error, stackTrace: $stackTrace)',
      );
    });
  });
}
