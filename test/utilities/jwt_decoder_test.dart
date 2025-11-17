// test/jwt_decoder_test.dart
import 'package:cognito_idp_sign_in/src/generic/generic.dart';
import 'package:cognito_idp_sign_in/src/utilities/utilities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JwtDecoder.decodePayload', () {
    late JwtDecoder decoder;

    setUp(() {
      decoder = JwtDecoder();
    });

    test('decodes a valid JWT payload', () {
      // header {"alg":"none"}
      const String header = 'eyJhbGciOiJub25lIn0';
      // payload {"sub":"123","name":"Alice"}
      const String payload = 'eyJzdWIiOiIxMjMiLCJuYW1lIjoiQWxpY2UifQ';
      const String token = '$header.$payload.';

      final DecodeJwtResult result = decoder.decodePayload(token);

      expect(result, isA<SuccessResult<Map<String, dynamic>, Object>>());
      switch (result) {
        case SuccessResult<Map<String, dynamic>, Object>(:final Map<String, dynamic> data):
          expect(data['sub'], '123');
          expect(data['name'], 'Alice');
        case FailureResult<Map<String, dynamic>, Object>():
          fail('Expected success');
      }
    });

    test('returns FailureResult on invalid base64', () {
      const String token = 'a.invalid.b';

      final DecodeJwtResult result = decoder.decodePayload(token);

      expect(result, isA<FailureResult<Map<String, dynamic>, Object>>());
    });

    test('returns DecodeJwtInvalidPayloadError when JSON is not a map', () {
      // payload is a JSON string, not an object
      const String header = 'eyJhbGciOiJub25lIn0';
      const String payload = 'ImhlbGxvIg'; // "hello"
      const String token = '$header.$payload.';

      final DecodeJwtResult result = decoder.decodePayload(token);

      switch (result) {
        case SuccessResult<Map<String, dynamic>, Object>():
          fail('Expected failure');
        case FailureResult<Map<String, dynamic>, DecodeJwtError>(:final DecodeJwtError error):
          expect(error, isA<DecodeJwtInvalidPayloadError>());
      }
    });
  });
}
