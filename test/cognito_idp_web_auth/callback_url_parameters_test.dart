import 'package:cognito_idp_sign_in/src/cognito_idp_web_auth/cognito_idp_web_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CallbackUrlParameters', () {
    test('fromJson parses code and state', () {
      const String code = 'AUTH_CODE';
      const String state = 'STATE_XYZ';

      final CognitoCallbackParams params = CognitoCallbackParams.fromJson(<String, dynamic>{
        'code': code,
        'state': state,
      });

      expect(params.code, code);
      expect(params.state, state);
    });

    test('toJson round-trips', () {
      const String code = 'C123';
      const String state = 'S456';

      const CognitoCallbackParams original = CognitoCallbackParams(code: code, state: state);

      final Map<String, dynamic> json = original.toJson();

      expect(json, <String, String>{'code': code, 'state': state});

      final CognitoCallbackParams roundTripped = CognitoCallbackParams.fromJson(json);
      expect(roundTripped.code, code);
      expect(roundTripped.state, state);
    });

    test('can be created from real callback URL query parameters', () {
      const String code = 'AUTH_CODE';
      const String state = 'STATE_XYZ';

      final Uri callback = Uri.parse('myapp://cb?code=$code&state=$state&extra=ignored');

      // Uri.queryParameters is Map<String, String>, which is fine for fromJson
      final CognitoCallbackParams params = CognitoCallbackParams.fromJson(callback.queryParameters);

      expect(params.code, code);
      expect(params.state, state);
    });

    test('throws when a required field is missing', () {
      // json_serializable will throw a cast/TypeError
      expect(() => CognitoCallbackParams.fromJson(<String, dynamic>{'code': 'ONLY_CODE'}), throwsA(isA<Object>()));
    });
  });
}
