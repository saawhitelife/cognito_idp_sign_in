import 'package:cognito_idp_sign_in/src/code_exchange/code_exchange.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthData', () {
    test('fromJson parses all fields correctly', () {
      final Map<String, Object> json = <String, Object>{
        'id_token': 'id-123',
        'access_token': 'acc-456',
        'refresh_token': 'ref-789',
        'token_type': 'Bearer',
        'expires_in': 3600,
      };

      final AuthData model = AuthData.fromJson(json);

      expect(model.idToken, 'id-123');
      expect(model.accessToken, 'acc-456');
      expect(model.refreshToken, 'ref-789');
      expect(model.tokenType, 'Bearer');
      expect(model.expiresIn, 3600);
    });

    test('toJson outputs all fields with correct JSON keys', () {
      const AuthData model = AuthData(
        idToken: 'id-123',
        accessToken: 'acc-456',
        refreshToken: 'ref-789',
        tokenType: 'Bearer',
        expiresIn: 3600,
      );

      final Map<String, dynamic> json = model.toJson();

      expect(json, <String, Object>{
        'id_token': 'id-123',
        'access_token': 'acc-456',
        'refresh_token': 'ref-789',
        'token_type': 'Bearer',
        'expires_in': 3600,
      });
    });

    test('round-trip conversion preserves values', () {
      const AuthData original = AuthData(
        idToken: 'id-123',
        accessToken: 'acc-456',
        refreshToken: 'ref-789',
        tokenType: 'Bearer',
        expiresIn: 3600,
      );

      final AuthData fromJson = AuthData.fromJson(original.toJson());

      expect(fromJson.idToken, original.idToken);
      expect(fromJson.accessToken, original.accessToken);
      expect(fromJson.refreshToken, original.refreshToken);
      expect(fromJson.tokenType, original.tokenType);
      expect(fromJson.expiresIn, original.expiresIn);
    });

    test('toString prints readable summary', () {
      const AuthData model = AuthData(
        idToken: 'id-123',
        accessToken: 'acc-456',
        refreshToken: 'ref-789',
        tokenType: 'Bearer',
        expiresIn: 3600,
      );

      expect(
        model.toString(),
        'AuthData(idToken: id-123, accessToken: acc-456, refreshToken: ref-789, tokenType: Bearer, expiresIn: 3600)',
      );
    });

    test('fromJson throws when required field is missing', () {
      final Map<String, Object> incompleteJson = <String, Object>{
        'refresh_token': 'ref-789',
        'token_type': 'Bearer',
        'expires_in': 3600,
      };

      expect(() => AuthData.fromJson(incompleteJson), throwsA(isA<Object>()));
    });

    test('same == and hashCode when all fields are the same', () {
      const AuthData model1 = AuthData(
        idToken: 'id-123',
        accessToken: 'acc-456',
        refreshToken: 'ref-789',
        tokenType: 'Bearer',
        expiresIn: 3600,
      );
      const AuthData model2 = AuthData(
        idToken: 'id-123',
        accessToken: 'acc-456',
        refreshToken: 'ref-789',
        tokenType: 'Bearer',
        expiresIn: 3600,
      );

      expect(model1 == model2, isTrue);
      expect(model1.hashCode, model2.hashCode);
    });

    test('== returns false when other is not AuthData', () {
      const AuthData model = AuthData(
        idToken: 'id-123',
        accessToken: 'acc-456',
        refreshToken: 'ref-789',
        tokenType: 'Bearer',
        expiresIn: 3600,
      );

      // ignore: unrelated_type_equality_checks
      expect(model == 'not-auth-data', isFalse);
      // ignore: unrelated_type_equality_checks
      expect(model == 123, isFalse);
    });

    test('== returns false when other is AuthData with different fields', () {
      const String idToken = 'id-123';
      const String accessToken = 'acc-456';
      const String refreshToken = 'ref-789';
      const String tokenType = 'Bearer';
      const int expiresIn = 3600;

      const AuthData baseModel = AuthData(
        idToken: idToken,
        accessToken: accessToken,
        refreshToken: refreshToken,
        tokenType: tokenType,
        expiresIn: expiresIn,
      );

      const AuthData differentIdTokenModel = AuthData(
        idToken: 'id-999',
        accessToken: accessToken,
        refreshToken: refreshToken,
        tokenType: tokenType,
        expiresIn: expiresIn,
      );

      expect(baseModel == differentIdTokenModel, isFalse);
      expect(baseModel.hashCode, isNot(differentIdTokenModel.hashCode));

      const AuthData differentAccessTokenModel = AuthData(
        idToken: idToken,
        accessToken: 'acc-789',
        refreshToken: refreshToken,
        tokenType: tokenType,
        expiresIn: expiresIn,
      );

      expect(baseModel == differentAccessTokenModel, isFalse);
      expect(baseModel.hashCode, isNot(differentAccessTokenModel.hashCode));

      const AuthData differentRefreshTokenModel = AuthData(
        idToken: idToken,
        accessToken: accessToken,
        refreshToken: 'ref-123',
        tokenType: tokenType,
        expiresIn: expiresIn,
      );

      expect(baseModel == differentRefreshTokenModel, isFalse);
      expect(baseModel.hashCode, isNot(differentRefreshTokenModel.hashCode));

      const AuthData differentTokenTypeModel = AuthData(
        idToken: idToken,
        accessToken: accessToken,
        refreshToken: refreshToken,
        tokenType: 'Not Bearer',
        expiresIn: expiresIn,
      );

      expect(baseModel == differentTokenTypeModel, isFalse);
      expect(baseModel.hashCode, isNot(differentTokenTypeModel.hashCode));

      const AuthData differentExpiresInModel = AuthData(
        idToken: idToken,
        accessToken: accessToken,
        refreshToken: refreshToken,
        tokenType: tokenType,
        expiresIn: expiresIn + 1,
      );

      expect(baseModel == differentExpiresInModel, isFalse);
      expect(baseModel.hashCode, isNot(differentExpiresInModel.hashCode));
    });
  });
}
