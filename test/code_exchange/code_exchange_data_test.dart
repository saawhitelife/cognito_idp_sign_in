import 'package:cognito_idp_sign_in/src/code_exchange/code_exchange.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CodeExchangeData', () {
    test('fromJson parses all fields correctly', () {
      final Map<String, String> json = <String, String>{
        'grant_type': 'authorization_code',
        'client_id': 'client-123',
        'code': 'auth-code-xyz',
        'redirect_uri': 'myapp://callback',
        'code_verifier': 'verifier-abc',
      };

      final CodeExchangeData model = CodeExchangeData.fromJson(json);

      expect(model.grantType, 'authorization_code');
      expect(model.clientId, 'client-123');
      expect(model.code, 'auth-code-xyz');
      expect(model.redirectUri, 'myapp://callback');
      expect(model.codeVerifier, 'verifier-abc');
    });

    test('toJson outputs all fields with correct JSON keys', () {
      const CodeExchangeData model = CodeExchangeData(
        clientId: 'client-123',
        code: 'auth-code-xyz',
        redirectUri: 'myapp://callback',
        codeVerifier: 'verifier-abc',
      );

      final Map<String, dynamic> json = model.toJson();

      expect(json, <String, String>{
        'grant_type': 'authorization_code',
        'client_id': 'client-123',
        'code': 'auth-code-xyz',
        'redirect_uri': 'myapp://callback',
        'code_verifier': 'verifier-abc',
      });
    });

    test('round-trip: toJson → fromJson preserves data', () {
      const CodeExchangeData original = CodeExchangeData(
        clientId: 'client-123',
        code: 'auth-code-xyz',
        redirectUri: 'myapp://callback',
        codeVerifier: 'verifier-abc',
      );

      final CodeExchangeData reconstructed = CodeExchangeData.fromJson(original.toJson());

      expect(reconstructed.clientId, original.clientId);
      expect(reconstructed.code, original.code);
      expect(reconstructed.redirectUri, original.redirectUri);
      expect(reconstructed.codeVerifier, original.codeVerifier);
      expect(reconstructed.grantType, original.grantType);
    });

    test('uses default grantType when missing in JSON', () {
      final Map<String, String> json = <String, String>{
        // no grant_type
        'client_id': 'client-123',
        'code': 'auth-code-xyz',
        'redirect_uri': 'myapp://callback',
        'code_verifier': 'verifier-abc',
      };

      final CodeExchangeData model = CodeExchangeData.fromJson(json);
      expect(model.grantType, 'authorization_code');
    });

    test('throws when a required field is missing', () {
      final Map<String, String> incomplete = <String, String>{
        'client_id': 'client-123',
        'redirect_uri': 'myapp://callback',
        'code_verifier': 'verifier-abc',
      };

      expect(() => CodeExchangeData.fromJson(incomplete), throwsA(isA<Object>()));
    });

    test('toString returns all fields', () {
      const CodeExchangeData model = CodeExchangeData(
        grantType: 'authorization_code',
        clientId: 'client-123',
        code: 'auth-code-xyz',
        redirectUri: 'myapp://callback',
        codeVerifier: 'verifier-abc',
      );

      expect(
        model.toString(),
        'CodeExchangeData(grantType: authorization_code, clientId: client-123, code: auth-code-xyz, redirectUri: myapp://callback, codeVerifier: verifier-abc)',
      );
    });

    group('equality operator', () {
      test('returns true for identical instances', () {
        const CodeExchangeData model = CodeExchangeData(
          clientId: 'client-123',
          code: 'auth-code-xyz',
          redirectUri: 'myapp://callback',
          codeVerifier: 'verifier-abc',
        );

        expect(model == model, isTrue);
      });

      test('returns true for instances with same values', () {
        const CodeExchangeData model1 = CodeExchangeData(
          grantType: 'authorization_code',
          clientId: 'client-123',
          code: 'auth-code-xyz',
          redirectUri: 'myapp://callback',
          codeVerifier: 'verifier-abc',
        );

        const CodeExchangeData model2 = CodeExchangeData(
          grantType: 'authorization_code',
          clientId: 'client-123',
          code: 'auth-code-xyz',
          redirectUri: 'myapp://callback',
          codeVerifier: 'verifier-abc',
        );

        expect(model1 == model2, isTrue);
      });

      test('returns false when grantType differs', () {
        const CodeExchangeData model1 = CodeExchangeData(
          grantType: 'authorization_code',
          clientId: 'client-123',
          code: 'auth-code-xyz',
          redirectUri: 'myapp://callback',
          codeVerifier: 'verifier-abc',
        );

        const CodeExchangeData model2 = CodeExchangeData(
          grantType: 'refresh_token',
          clientId: 'client-123',
          code: 'auth-code-xyz',
          redirectUri: 'myapp://callback',
          codeVerifier: 'verifier-abc',
        );

        expect(model1 == model2, isFalse);
      });

      test('returns false when clientId differs', () {
        const CodeExchangeData model1 = CodeExchangeData(
          clientId: 'client-123',
          code: 'auth-code-xyz',
          redirectUri: 'myapp://callback',
          codeVerifier: 'verifier-abc',
        );

        const CodeExchangeData model2 = CodeExchangeData(
          clientId: 'client-456',
          code: 'auth-code-xyz',
          redirectUri: 'myapp://callback',
          codeVerifier: 'verifier-abc',
        );

        expect(model1 == model2, isFalse);
      });

      test('returns false when code differs', () {
        const CodeExchangeData model1 = CodeExchangeData(
          clientId: 'client-123',
          code: 'auth-code-xyz',
          redirectUri: 'myapp://callback',
          codeVerifier: 'verifier-abc',
        );

        const CodeExchangeData model2 = CodeExchangeData(
          clientId: 'client-123',
          code: 'auth-code-different',
          redirectUri: 'myapp://callback',
          codeVerifier: 'verifier-abc',
        );

        expect(model1 == model2, isFalse);
      });

      test('returns false when redirectUri differs', () {
        const CodeExchangeData model1 = CodeExchangeData(
          clientId: 'client-123',
          code: 'auth-code-xyz',
          redirectUri: 'myapp://callback',
          codeVerifier: 'verifier-abc',
        );

        const CodeExchangeData model2 = CodeExchangeData(
          clientId: 'client-123',
          code: 'auth-code-xyz',
          redirectUri: 'different://callback',
          codeVerifier: 'verifier-abc',
        );

        expect(model1 == model2, isFalse);
      });

      test('returns false when codeVerifier differs', () {
        const CodeExchangeData model1 = CodeExchangeData(
          clientId: 'client-123',
          code: 'auth-code-xyz',
          redirectUri: 'myapp://callback',
          codeVerifier: 'verifier-abc',
        );

        const CodeExchangeData model2 = CodeExchangeData(
          clientId: 'client-123',
          code: 'auth-code-xyz',
          redirectUri: 'myapp://callback',
          codeVerifier: 'verifier-different',
        );

        expect(model1 == model2, isFalse);
      });
    });

    group('hashCode', () {
      test('is consistent for same instance', () {
        const CodeExchangeData model = CodeExchangeData(
          clientId: 'client-123',
          code: 'auth-code-xyz',
          redirectUri: 'myapp://callback',
          codeVerifier: 'verifier-abc',
        );

        expect(model.hashCode, equals(model.hashCode));
      });

      test('is same for equal instances', () {
        const CodeExchangeData model1 = CodeExchangeData(
          grantType: 'authorization_code',
          clientId: 'client-123',
          code: 'auth-code-xyz',
          redirectUri: 'myapp://callback',
          codeVerifier: 'verifier-abc',
        );

        const CodeExchangeData model2 = CodeExchangeData(
          grantType: 'authorization_code',
          clientId: 'client-123',
          code: 'auth-code-xyz',
          redirectUri: 'myapp://callback',
          codeVerifier: 'verifier-abc',
        );

        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('is different for instances with different values', () {
        const CodeExchangeData model1 = CodeExchangeData(
          clientId: 'client-123',
          code: 'auth-code-xyz',
          redirectUri: 'myapp://callback',
          codeVerifier: 'verifier-abc',
        );

        const CodeExchangeData model2 = CodeExchangeData(
          clientId: 'client-456',
          code: 'auth-code-different',
          redirectUri: 'different://callback',
          codeVerifier: 'verifier-different',
        );

        expect(model1.hashCode, isNot(equals(model2.hashCode)));
      });
    });
  });
}
