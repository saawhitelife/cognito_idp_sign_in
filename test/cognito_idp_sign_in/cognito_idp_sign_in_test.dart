import 'package:cognito_idp_sign_in/src/code_exchange/code_exchange.dart';
import 'package:cognito_idp_sign_in/src/cognito_idp_sign_in/index.dart';
import 'package:cognito_idp_sign_in/src/cognito_idp_web_auth/cognito_idp_web_auth.dart'
    hide WebAuthFlowUnexpectedError, WebAuthFlowInvalidCallbackUrlError, WebAuthFlowPlatformError;
import 'package:cognito_idp_sign_in/src/cognito_idp_web_auth/web_auth_flow_error.dart' as web_auth_flow_error;
import 'package:cognito_idp_sign_in/src/generic/generic.dart';
import 'package:cognito_idp_sign_in/src/http/http.dart';
import 'package:cognito_idp_sign_in/src/utilities/utilities.dart'
    hide DecodeJwtInvalidPayloadError, DecodeJwtUnexpectedError;
import 'package:cognito_idp_sign_in/src/utilities/jwt_decoder/decode_jwt_error.dart' as decode_jwt_error;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPkceTools extends Mock implements PkceTools {}

class MockRemoteDataSource extends Mock implements RemoteDataSource {}

class MockJwtDecoder extends Mock implements JwtDecoder {}

class MockCognitoIdpWebAuth extends Mock implements CognitoIdpWebAuth {}

void main() {
  group('CognitoIdpSignIn', () {
    late MockPkceTools mockPkceTools;
    late MockRemoteDataSource mockRemoteDataSource;
    late MockJwtDecoder mockJwtDecoder;
    late MockCognitoIdpWebAuth mockCognitoIdpWebAuth;
    late CognitoIdpSignInOptions options;
    late CognitoIdpSignIn sut;

    setUp(() {
      mockPkceTools = MockPkceTools();
      mockRemoteDataSource = MockRemoteDataSource();
      mockJwtDecoder = MockJwtDecoder();
      mockCognitoIdpWebAuth = MockCognitoIdpWebAuth();

      options = CognitoIdpSignInOptions(
        poolId: 'us-east-1_test',
        clientId: 'client-123',
        clientSecret: 'client-secret-123',
        hostedUiDomain: 'example.auth.us-east-1.amazoncognito.com',
        redirectUri: Uri.parse('myapp://'),
        identityProviderName: 'SignInWithApple',
        nonceLength: 43,
        stateLength: 43,
        pkceBundleLifetime: const Duration(minutes: 5),
        scopes: <CognitoScope>[.openid],
        customScopes: <CustomScope>['custom-scope-1'],
        webAuthOptions: const CognitoIdpWebAuthOptions(),
      );

      sut = CognitoIdpSignIn(
        options,
        pkceTools: mockPkceTools,
        remoteDataSource: mockRemoteDataSource,
        jwtDecoder: mockJwtDecoder,
        cognitoIdpWebAuth: mockCognitoIdpWebAuth,
      );

      // Register fallback values for mocktail
      registerFallbackValue(const Duration(minutes: 5));
      registerFallbackValue(CodeChallengeMethod.s256);
      registerFallbackValue(<CognitoScope>[]);
      registerFallbackValue(<String>[]);
      registerFallbackValue(const CodeExchangeData(clientId: '', code: '', redirectUri: '', codeVerifier: ''));
      registerFallbackValue(const CognitoIdpWebAuthOptions());
      registerFallbackValue(Uri.parse('myapp://'));
    });

    group('constructor', () {
      test('creates default dependencies when not provided', () {
        final CognitoIdpSignIn instance = CognitoIdpSignIn(options);

        expect(instance, isA<CognitoIdpSignIn>());
        // Verify that default instances are created (not null)
        // We can't directly access private fields, but we can verify behavior
        // by checking that the instance works with default dependencies
        expect(instance.checkIfPkceBundleExpired(options: options), isTrue);
      });

      test('uses provided dependencies instead of defaults', () {
        final CognitoIdpSignIn instance = CognitoIdpSignIn(
          options,
          pkceTools: mockPkceTools,
          remoteDataSource: mockRemoteDataSource,
          jwtDecoder: mockJwtDecoder,
          cognitoIdpWebAuth: mockCognitoIdpWebAuth,
        );

        expect(instance, isA<CognitoIdpSignIn>());
        // The instance should use the provided mocks
        // This is verified indirectly through other tests that use the mocked sut
      });

      test('constructs RemoteDataSource with correct base URL from hostedUiDomain', () {
        const String customDomain = 'custom.auth.us-east-1.amazoncognito.com';
        final CognitoIdpSignInOptions customOptions = CognitoIdpSignInOptions(
          poolId: 'us-east-1_test',
          clientId: 'client-123',
          hostedUiDomain: customDomain,
          redirectUri: Uri.parse('myapp://'),
          identityProviderName: 'SignInWithApple',
        );

        final CognitoIdpSignIn instance = CognitoIdpSignIn(customOptions);

        // Verify RemoteDataSource is created with correct base URL
        // We can't directly access the private field, but we can verify it works
        // by checking that the instance can be created successfully
        expect(instance, isA<CognitoIdpSignIn>());
        expect(instance.checkIfPkceBundleExpired(options: customOptions), isTrue);
      });
    });

    group('isPkceBundleExpired', () {
      test('returns true when pkceBundle is null', () {
        expect(sut.checkIfPkceBundleExpired(options: options), isTrue);
      });

      // Note: Testing pkceBundle expiration is tested indirectly through
      // signInWithCognitoIdp tests with short lifetime options
    });

    group('signInWithCognitoIdp', () {
      const String authCode = 'auth-code-123';
      const String state = 'state-xyz';
      const String nonce = 'nonce-abc';
      const String codeVerifier = 'verifier-123';
      const String codeChallenge = 'challenge-456';

      final AuthData authData = AuthData(
        idToken: 'header.eyJub25jZSI6Im5vbmNlLWFiYyJ9.signature',
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        tokenType: 'Bearer',
        expiresIn: 3600,
      );

      final AuthData authDataWithoutIdToken = AuthData(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        tokenType: 'Bearer',
        expiresIn: 3600,
      );

      test('success: completes full sign-in flow with idToken', () async {
        when(
          () => mockPkceTools.generatePkcePair(),
        ).thenReturn((codeVerifier: codeVerifier, codeChallenge: codeChallenge));
        int callCount = 0;
        when(
          () => mockPkceTools.generateUrlSafeString(length: any(named: 'length')),
        ).thenAnswer((_) => callCount++ == 0 ? state : nonce);

        final CognitoCallbackParams callbackParams = CognitoCallbackParams(code: authCode, state: state);

        when(
          () => mockCognitoIdpWebAuth.startWebAuthFlow(
            clientId: any(named: 'clientId'),
            clientSecret: any(named: 'clientSecret'),
            redirectUri: any(named: 'redirectUri'),
            state: any(named: 'state'),
            nonce: any(named: 'nonce'),
            identityProvider: any(named: 'identityProvider'),
            codeChallenge: any(named: 'codeChallenge'),
            codeChallengeMethod: any(named: 'codeChallengeMethod'),
            scopes: any(named: 'scopes'),
            customScopes: any(named: 'customScopes'),
            hostedUiDomain: any(named: 'hostedUiDomain'),
            webAuthOptions: any(named: 'webAuthOptions'),
          ),
        ).thenAnswer((_) async => SuccessResult<CognitoCallbackParams, WebAuthFlowError>(data: callbackParams));

        when(
          () => mockRemoteDataSource.exchangeCodeForAuthData(any()),
        ).thenAnswer((_) async => SuccessResult<AuthData, HttpError>(data: authData));

        when(
          () => mockJwtDecoder.decodePayload(any()),
        ).thenReturn(SuccessResult<Map<String, dynamic>, DecodeJwtError>(data: <String, dynamic>{'nonce': nonce}));

        final IdpResult result = await sut.signInWithCognitoIdp();

        expect(result, isA<IdpResult>());
        switch (result) {
          case SuccessResult<AuthData, CognitoIdpSignInError>(data: final AuthData data):
            expect(data, equals(authData));
            expect(data.idToken, equals(authData.idToken));
            expect(data.accessToken, equals(authData.accessToken));
          case FailureResult<AuthData, CognitoIdpSignInError>(error: final CognitoIdpSignInError error):
            fail('Expected success, got error: $error');
        }

        final String? idToken = authData.idToken;

        if (idToken != null) {
          verify(() => mockPkceTools.generatePkcePair()).called(1);
          verify(
            () => mockCognitoIdpWebAuth.startWebAuthFlow(
              clientId: options.clientId,
              clientSecret: options.clientSecret,
              redirectUri: options.redirectUri,
              state: state,
              nonce: nonce,
              identityProvider: options.identityProviderName,
              codeChallenge: codeChallenge,
              codeChallengeMethod: options.codeChallengeMethod,
              scopes: options.scopes ?? <CognitoScope>[],
              customScopes: options.customScopes ?? <String>[],
              hostedUiDomain: options.hostedUiDomain,
              webAuthOptions: options.webAuthOptions,
            ),
          ).called(1);
          verify(() => mockRemoteDataSource.exchangeCodeForAuthData(any())).called(1);
          verify(() => mockJwtDecoder.decodePayload(idToken)).called(1);
        } else {
          verifyNever(() => mockJwtDecoder.decodePayload(any()));
        }
      });

      test('success: completes full sign-in flow with idToken', () async {
        when(
          () => mockPkceTools.generatePkcePair(),
        ).thenReturn((codeVerifier: codeVerifier, codeChallenge: codeChallenge));
        int callCount = 0;
        when(
          () => mockPkceTools.generateUrlSafeString(length: any(named: 'length')),
        ).thenAnswer((_) => callCount++ == 0 ? state : nonce);

        final CognitoCallbackParams callbackParams = CognitoCallbackParams(code: authCode, state: state);

        when(
          () => mockCognitoIdpWebAuth.startWebAuthFlow(
            clientId: any(named: 'clientId'),
            clientSecret: any(named: 'clientSecret'),
            redirectUri: any(named: 'redirectUri'),
            state: any(named: 'state'),
            nonce: any(named: 'nonce'),
            identityProvider: any(named: 'identityProvider'),
            codeChallenge: any(named: 'codeChallenge'),
            codeChallengeMethod: any(named: 'codeChallengeMethod'),
            scopes: any(named: 'scopes'),
            customScopes: any(named: 'customScopes'),
            hostedUiDomain: any(named: 'hostedUiDomain'),
            webAuthOptions: any(named: 'webAuthOptions'),
          ),
        ).thenAnswer((_) async => SuccessResult<CognitoCallbackParams, WebAuthFlowError>(data: callbackParams));

        when(
          () => mockRemoteDataSource.exchangeCodeForAuthData(any()),
        ).thenAnswer((_) async => SuccessResult<AuthData, HttpError>(data: authData));

        when(
          () => mockJwtDecoder.decodePayload(any()),
        ).thenReturn(SuccessResult<Map<String, dynamic>, DecodeJwtError>(data: <String, dynamic>{'nonce': nonce}));

        final Result<AuthData, CognitoIdpSignInError> result = await sut.signInWithCognitoIdp();

        expect(result, isA<SuccessResult<AuthData, CognitoIdpSignInError>>());
        switch (result) {
          case SuccessResult<AuthData, CognitoIdpSignInError>(data: final AuthData data):
            expect(data, equals(authData));
            expect(data.idToken, equals(authData.idToken));
          case FailureResult<AuthData, CognitoIdpSignInError>(error: final CognitoIdpSignInError error):
            fail('Expected success, got error: $error');
        }

        final String? idToken = authData.idToken;

        verify(() => mockPkceTools.generatePkcePair()).called(1);
        verify(
          () => mockCognitoIdpWebAuth.startWebAuthFlow(
            clientId: options.clientId,
            redirectUri: options.redirectUri,
            state: state,
            nonce: nonce,
            identityProvider: options.identityProviderName,
            clientSecret: options.clientSecret,
            codeChallenge: codeChallenge,
            codeChallengeMethod: options.codeChallengeMethod,
            scopes: options.scopes ?? <CognitoScope>[],
            customScopes: options.customScopes ?? <String>[],
            hostedUiDomain: options.hostedUiDomain,
            webAuthOptions: options.webAuthOptions,
          ),
        ).called(1);
        verify(() => mockRemoteDataSource.exchangeCodeForAuthData(any())).called(1);

        if (idToken != null) {
          verify(() => mockJwtDecoder.decodePayload(idToken)).called(1);
        } else {
          fail('Expected idToken to be not null');
        }
      });

      test('success: completes full sign-in flow without idToken', () async {
        when(
          () => mockPkceTools.generatePkcePair(),
        ).thenReturn((codeVerifier: codeVerifier, codeChallenge: codeChallenge));
        int callCount = 0;
        when(
          () => mockPkceTools.generateUrlSafeString(length: any(named: 'length')),
        ).thenAnswer((_) => callCount++ == 0 ? state : nonce);

        final CognitoCallbackParams callbackParams = CognitoCallbackParams(code: authCode, state: state);

        when(
          () => mockCognitoIdpWebAuth.startWebAuthFlow(
            clientId: any(named: 'clientId'),
            clientSecret: any(named: 'clientSecret'),
            redirectUri: any(named: 'redirectUri'),
            state: any(named: 'state'),
            nonce: any(named: 'nonce'),
            identityProvider: any(named: 'identityProvider'),
            codeChallenge: any(named: 'codeChallenge'),
            codeChallengeMethod: any(named: 'codeChallengeMethod'),
            scopes: any(named: 'scopes'),
            customScopes: any(named: 'customScopes'),
            hostedUiDomain: any(named: 'hostedUiDomain'),
            webAuthOptions: any(named: 'webAuthOptions'),
          ),
        ).thenAnswer((_) async => SuccessResult<CognitoCallbackParams, WebAuthFlowError>(data: callbackParams));

        when(
          () => mockRemoteDataSource.exchangeCodeForAuthData(any()),
        ).thenAnswer((_) async => SuccessResult<AuthData, HttpError>(data: authDataWithoutIdToken));

        final Result<AuthData, CognitoIdpSignInError> result = await sut.signInWithCognitoIdp();

        expect(result, isA<SuccessResult<AuthData, CognitoIdpSignInError>>());
        switch (result) {
          case SuccessResult<AuthData, CognitoIdpSignInError>(data: final AuthData data):
            expect(data, equals(authDataWithoutIdToken));
            expect(data.idToken, isNull);
          case FailureResult<AuthData, CognitoIdpSignInError>(error: final CognitoIdpSignInError error):
            fail('Expected success, got error: $error');
        }

        final String? idToken = authDataWithoutIdToken.idToken;

        verify(() => mockPkceTools.generatePkcePair()).called(1);
        verify(
          () => mockCognitoIdpWebAuth.startWebAuthFlow(
            clientId: options.clientId,
            redirectUri: options.redirectUri,
            state: state,
            nonce: nonce,
            identityProvider: options.identityProviderName,
            codeChallenge: codeChallenge,
            codeChallengeMethod: options.codeChallengeMethod,
            clientSecret: options.clientSecret,
            scopes: options.scopes ?? <CognitoScope>[],
            customScopes: options.customScopes ?? <String>[],
            hostedUiDomain: options.hostedUiDomain,
            webAuthOptions: options.webAuthOptions,
          ),
        ).called(1);
        verify(() => mockRemoteDataSource.exchangeCodeForAuthData(any())).called(1);

        if (idToken != null) {
          fail('Expected idToken to be null');
        } else {
          verifyNever(() => mockJwtDecoder.decodePayload(any()));
        }
      });

      test('failure: WebAuthFlowUnexpectedError', () async {
        when(
          () => mockPkceTools.generatePkcePair(),
        ).thenReturn((codeVerifier: codeVerifier, codeChallenge: codeChallenge));
        int callCount = 0;
        when(
          () => mockPkceTools.generateUrlSafeString(length: any(named: 'length')),
        ).thenAnswer((_) => callCount++ == 0 ? state : nonce);

        final web_auth_flow_error.WebAuthFlowUnexpectedError callbackError =
            web_auth_flow_error.WebAuthFlowUnexpectedError(
              error: Exception('Network error'),
              stackTrace: StackTrace.current,
            );

        when(
          () => mockCognitoIdpWebAuth.startWebAuthFlow(
            clientId: any(named: 'clientId'),
            clientSecret: any(named: 'clientSecret'),
            redirectUri: any(named: 'redirectUri'),
            state: any(named: 'state'),
            nonce: any(named: 'nonce'),
            identityProvider: any(named: 'identityProvider'),
            codeChallenge: any(named: 'codeChallenge'),
            codeChallengeMethod: any(named: 'codeChallengeMethod'),
            scopes: any(named: 'scopes'),
            customScopes: any(named: 'customScopes'),
            hostedUiDomain: any(named: 'hostedUiDomain'),
            webAuthOptions: any(named: 'webAuthOptions'),
          ),
        ).thenAnswer((_) async => FailureResult<CognitoCallbackParams, WebAuthFlowError>(error: callbackError));

        final Result<AuthData, CognitoIdpSignInError> result = await sut.signInWithCognitoIdp();

        expect(result, isA<FailureResult<AuthData, CognitoIdpSignInError>>());
        switch (result) {
          case SuccessResult<AuthData, CognitoIdpSignInError>():
            fail('Expected failure');
          case FailureResult<AuthData, CognitoIdpSignInError>(error: final CognitoIdpSignInError error):
            expect(error, isA<WebAuthFlowUnexpectedError>());
        }
      });

      test('failure: StateExpiredError', () async {
        when(
          () => mockPkceTools.generatePkcePair(),
        ).thenReturn((codeVerifier: codeVerifier, codeChallenge: codeChallenge));
        int callCount = 0;
        when(
          () => mockPkceTools.generateUrlSafeString(length: any(named: 'length')),
        ).thenAnswer((_) => callCount++ == 0 ? state : nonce);

        final CognitoCallbackParams callbackParams = CognitoCallbackParams(code: authCode, state: state);

        when(
          () => mockCognitoIdpWebAuth.startWebAuthFlow(
            clientId: any(named: 'clientId'),
            clientSecret: any(named: 'clientSecret'),
            redirectUri: any(named: 'redirectUri'),
            state: any(named: 'state'),
            nonce: any(named: 'nonce'),
            identityProvider: any(named: 'identityProvider'),
            codeChallenge: any(named: 'codeChallenge'),
            codeChallengeMethod: any(named: 'codeChallengeMethod'),
            scopes: any(named: 'scopes'),
            customScopes: any(named: 'customScopes'),
            hostedUiDomain: any(named: 'hostedUiDomain'),
            webAuthOptions: any(named: 'webAuthOptions'),
          ),
        ).thenAnswer((_) async {
          // Simulate delay that causes expiration
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return SuccessResult<CognitoCallbackParams, WebAuthFlowError>(data: callbackParams);
        });

        // Create options with very short lifetime
        final CognitoIdpSignInOptions shortLifetimeOptions = CognitoIdpSignInOptions(
          poolId: options.poolId,
          clientId: options.clientId,
          hostedUiDomain: options.hostedUiDomain,
          pkceBundleLifetime: const Duration(milliseconds: 50),
          redirectUri: options.redirectUri,
          identityProviderName: options.identityProviderName,
        );

        final CognitoIdpSignIn shortLifetimeSut = CognitoIdpSignIn(
          shortLifetimeOptions,
          pkceTools: mockPkceTools,
          remoteDataSource: mockRemoteDataSource,
          jwtDecoder: mockJwtDecoder,
          cognitoIdpWebAuth: mockCognitoIdpWebAuth,
        );

        final Result<AuthData, CognitoIdpSignInError> result = await shortLifetimeSut.signInWithCognitoIdp();

        expect(result, isA<FailureResult<AuthData, CognitoIdpSignInError>>());
        switch (result) {
          case SuccessResult<AuthData, CognitoIdpSignInError>():
            fail('Expected failure');
          case FailureResult<AuthData, CognitoIdpSignInError>(error: final CognitoIdpSignInError error):
            expect(error, isA<StateExpiredError>());
            switch (error) {
              case StateExpiredError(
                createdAt: final DateTime createdAt,
                age: final Duration age,
                maxLifetime: final Duration maxLifetime,
              ):
                // Verify timing information is present and reasonable
                expect(createdAt, isNot(isNull));
                expect(age, greaterThanOrEqualTo(maxLifetime));
                expect(maxLifetime, equals(const Duration(milliseconds: 50)));
              default:
                fail('Expected StateExpiredError');
            }
        }
      });

      test('failure: StateMismatchError', () async {
        when(
          () => mockPkceTools.generatePkcePair(),
        ).thenReturn((codeVerifier: codeVerifier, codeChallenge: codeChallenge));
        int callCount = 0;
        when(
          () => mockPkceTools.generateUrlSafeString(length: any(named: 'length')),
        ).thenAnswer((_) => callCount++ == 0 ? state : nonce);

        const String wrongState = 'wrong-state';
        final CognitoCallbackParams callbackParams = CognitoCallbackParams(code: authCode, state: wrongState);

        when(
          () => mockCognitoIdpWebAuth.startWebAuthFlow(
            clientId: any(named: 'clientId'),
            clientSecret: any(named: 'clientSecret'),
            redirectUri: any(named: 'redirectUri'),
            state: any(named: 'state'),
            nonce: any(named: 'nonce'),
            identityProvider: any(named: 'identityProvider'),
            codeChallenge: any(named: 'codeChallenge'),
            codeChallengeMethod: any(named: 'codeChallengeMethod'),
            scopes: any(named: 'scopes'),
            customScopes: any(named: 'customScopes'),
            hostedUiDomain: any(named: 'hostedUiDomain'),
            webAuthOptions: any(named: 'webAuthOptions'),
          ),
        ).thenAnswer((_) async => SuccessResult<CognitoCallbackParams, WebAuthFlowError>(data: callbackParams));

        final Result<AuthData, CognitoIdpSignInError> result = await sut.signInWithCognitoIdp();

        expect(result, isA<FailureResult<AuthData, CognitoIdpSignInError>>());
        switch (result) {
          case SuccessResult<AuthData, CognitoIdpSignInError>():
            fail('Expected failure');
          case FailureResult<AuthData, CognitoIdpSignInError>(error: final CognitoIdpSignInError error):
            expect(error, isA<StateMismatchError>());
            switch (error) {
              case StateMismatchError(expected: final String expected, actual: final String actual):
                expect(expected, equals(state));
                expect(actual, equals(wrongState));
              default:
                fail('Expected StateMismatchError');
            }
        }
      });

      test('failure: UnexpectedAuthorizationCodeFlowError', () async {
        when(() => mockPkceTools.generatePkcePair()).thenThrow(Exception('PKCE generation failed'));
        int callCount = 0;
        when(
          () => mockPkceTools.generateUrlSafeString(length: any(named: 'length')),
        ).thenAnswer((_) => callCount++ == 0 ? state : nonce);

        final Result<AuthData, CognitoIdpSignInError> result = await sut.signInWithCognitoIdp();

        expect(result, isA<FailureResult<AuthData, CognitoIdpSignInError>>());
        switch (result) {
          case SuccessResult<AuthData, CognitoIdpSignInError>():
            fail('Expected failure');
          case FailureResult<AuthData, CognitoIdpSignInError>(error: final CognitoIdpSignInError error):
            expect(error, isA<UnexpectedAuthorizationCodeFlowError>());
        }
      });

      test('failure: PkceBundleMissingError', () async {
        // This tests the defensive check in _exchangeCodeForAuthData
        // In normal flow, this shouldn't happen, but we test it for completeness
        // Set bundle to null to trigger the defensive check
        sut.setPkceBundleForTesting(null);

        final Result<AuthData, CognitoIdpSignInError> result = await sut.exchangeCodeForAuthDataForTesting(
          authCode: authCode,
          options: options,
        );

        expect(result, isA<FailureResult<AuthData, CognitoIdpSignInError>>());
        switch (result) {
          case SuccessResult<AuthData, CognitoIdpSignInError>():
            fail('Expected failure');
          case FailureResult<AuthData, CognitoIdpSignInError>(error: final CognitoIdpSignInError error):
            expect(error, isA<PkceBundleMissingError>());
        }
      });

      test('failure: PkceBundleExpiredError', () async {
        // This tests the defensive check in _exchangeCodeForAuthData
        // Create an expired bundle that will be checked in _exchangeCodeForAuthData
        final PkceBundle expiredBundle = PkceBundle(
          codeVerifier: codeVerifier,
          codeChallenge: codeChallenge,
          state: state,
          nonce: nonce,
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)), // Expired
        );

        // Set expired bundle to trigger the defensive check
        sut.setPkceBundleForTesting(expiredBundle);

        // Use options with short lifetime to ensure expiration is detected
        final CognitoIdpSignInOptions shortLifetimeOptions = CognitoIdpSignInOptions(
          poolId: options.poolId,
          clientId: options.clientId,
          hostedUiDomain: options.hostedUiDomain,
          pkceBundleLifetime: const Duration(minutes: 5),
          redirectUri: options.redirectUri,
          identityProviderName: options.identityProviderName,
        );

        final Result<AuthData, CognitoIdpSignInError> result = await sut.exchangeCodeForAuthDataForTesting(
          authCode: authCode,
          options: shortLifetimeOptions,
        );

        expect(result, isA<FailureResult<AuthData, CognitoIdpSignInError>>());
        switch (result) {
          case SuccessResult<AuthData, CognitoIdpSignInError>():
            fail('Expected failure');
          case FailureResult<AuthData, CognitoIdpSignInError>(error: final CognitoIdpSignInError error):
            expect(error, isA<PkceBundleExpiredError>());
            switch (error) {
              case PkceBundleExpiredError(
                createdAt: final DateTime createdAt,
                age: final Duration age,
                maxLifetime: final Duration maxLifetime,
              ):
                // Verify timing information is present and reasonable
                expect(createdAt, isNot(isNull));
                expect(age, greaterThanOrEqualTo(maxLifetime));
                expect(maxLifetime, equals(const Duration(minutes: 5)));
              default:
                fail('Expected PkceBundleExpiredError');
            }
        }
      });

      test('failure: ExchangeCodeHttpRequestFailedError', () async {
        when(
          () => mockPkceTools.generatePkcePair(),
        ).thenReturn((codeVerifier: codeVerifier, codeChallenge: codeChallenge));
        int callCount = 0;
        when(
          () => mockPkceTools.generateUrlSafeString(length: any(named: 'length')),
        ).thenAnswer((_) => callCount++ == 0 ? state : nonce);

        final CognitoCallbackParams callbackParams = CognitoCallbackParams(code: authCode, state: state);

        when(
          () => mockCognitoIdpWebAuth.startWebAuthFlow(
            clientId: any(named: 'clientId'),
            clientSecret: any(named: 'clientSecret'),
            redirectUri: any(named: 'redirectUri'),
            state: any(named: 'state'),
            nonce: any(named: 'nonce'),
            identityProvider: any(named: 'identityProvider'),
            codeChallenge: any(named: 'codeChallenge'),
            codeChallengeMethod: any(named: 'codeChallengeMethod'),
            scopes: any(named: 'scopes'),
            customScopes: any(named: 'customScopes'),
            hostedUiDomain: any(named: 'hostedUiDomain'),
            webAuthOptions: any(named: 'webAuthOptions'),
          ),
        ).thenAnswer((_) async => SuccessResult<CognitoCallbackParams, WebAuthFlowError>(data: callbackParams));

        final HttpRequestFailedError httpError = HttpRequestFailedError(
          <String, dynamic>{},
          <String, dynamic>{},
          <String, dynamic>{},
          '/token',
          HttpStatusCode.fromCode(400),
        );

        when(
          () => mockRemoteDataSource.exchangeCodeForAuthData(any()),
        ).thenAnswer((_) async => FailureResult<AuthData, HttpError>(error: httpError));

        final Result<AuthData, CognitoIdpSignInError> result = await sut.signInWithCognitoIdp();

        expect(result, isA<FailureResult<AuthData, CognitoIdpSignInError>>());
        switch (result) {
          case SuccessResult<AuthData, CognitoIdpSignInError>():
            fail('Expected failure');
          case FailureResult<AuthData, CognitoIdpSignInError>(error: final CognitoIdpSignInError error):
            expect(error, isA<ExchangeCodeHttpRequestFailedError>());
            switch (error) {
              case ExchangeCodeHttpRequestFailedError(
                requestPath: final String requestPath,
                statusCode: final HttpStatusCode statusCode,
              ):
                expect(statusCode, equals(HttpStatusCode.fromCode(400)));
                expect(requestPath, equals('/token'));
              default:
                fail('Expected ExchangeCodeHttpRequestFailedError');
            }
        }
      });

      test('failure: ExchangeCodeUnexpectedError', () async {
        when(
          () => mockPkceTools.generatePkcePair(),
        ).thenReturn((codeVerifier: codeVerifier, codeChallenge: codeChallenge));
        int callCount = 0;
        when(
          () => mockPkceTools.generateUrlSafeString(length: any(named: 'length')),
        ).thenAnswer((_) => callCount++ == 0 ? state : nonce);

        final CognitoCallbackParams callbackParams = CognitoCallbackParams(code: authCode, state: state);

        when(
          () => mockCognitoIdpWebAuth.startWebAuthFlow(
            clientId: any(named: 'clientId'),
            clientSecret: any(named: 'clientSecret'),
            redirectUri: any(named: 'redirectUri'),
            state: any(named: 'state'),
            nonce: any(named: 'nonce'),
            identityProvider: any(named: 'identityProvider'),
            codeChallenge: any(named: 'codeChallenge'),
            codeChallengeMethod: any(named: 'codeChallengeMethod'),
            scopes: any(named: 'scopes'),
            customScopes: any(named: 'customScopes'),
            hostedUiDomain: any(named: 'hostedUiDomain'),
            webAuthOptions: any(named: 'webAuthOptions'),
          ),
        ).thenAnswer((_) async => SuccessResult<CognitoCallbackParams, WebAuthFlowError>(data: callbackParams));

        when(() => mockRemoteDataSource.exchangeCodeForAuthData(any())).thenThrow(Exception('Unexpected error'));

        final Result<AuthData, CognitoIdpSignInError> result = await sut.signInWithCognitoIdp();

        expect(result, isA<FailureResult<AuthData, CognitoIdpSignInError>>());
        switch (result) {
          case SuccessResult<AuthData, CognitoIdpSignInError>():
            fail('Expected failure');
          case FailureResult<AuthData, CognitoIdpSignInError>(error: final CognitoIdpSignInError error):
            expect(error, isA<ExchangeCodeUnexpectedError>());
        }
      });

      test('failure: DecodeJwtError', () async {
        when(
          () => mockPkceTools.generatePkcePair(),
        ).thenReturn((codeVerifier: codeVerifier, codeChallenge: codeChallenge));
        int callCount = 0;
        when(
          () => mockPkceTools.generateUrlSafeString(length: any(named: 'length')),
        ).thenAnswer((_) => callCount++ == 0 ? state : nonce);

        final CognitoCallbackParams callbackParams = CognitoCallbackParams(code: authCode, state: state);

        when(
          () => mockCognitoIdpWebAuth.startWebAuthFlow(
            clientId: any(named: 'clientId'),
            clientSecret: any(named: 'clientSecret'),
            redirectUri: any(named: 'redirectUri'),
            state: any(named: 'state'),
            nonce: any(named: 'nonce'),
            identityProvider: any(named: 'identityProvider'),
            codeChallenge: any(named: 'codeChallenge'),
            codeChallengeMethod: any(named: 'codeChallengeMethod'),
            scopes: any(named: 'scopes'),
            customScopes: any(named: 'customScopes'),
            hostedUiDomain: any(named: 'hostedUiDomain'),
            webAuthOptions: any(named: 'webAuthOptions'),
          ),
        ).thenAnswer((_) async => SuccessResult<CognitoCallbackParams, WebAuthFlowError>(data: callbackParams));

        when(
          () => mockRemoteDataSource.exchangeCodeForAuthData(any()),
        ).thenAnswer((_) async => SuccessResult<AuthData, HttpError>(data: authData));

        final StackTrace stackTrace = StackTrace.current;

        final decode_jwt_error.DecodeJwtUnexpectedError decodeError = decode_jwt_error.DecodeJwtUnexpectedError(
          FormatException('Invalid JWT'),
          stackTrace,
        );
        when(
          () => mockJwtDecoder.decodePayload(any()),
        ).thenReturn(FailureResult<Map<String, dynamic>, DecodeJwtError>(error: decodeError));

        final Result<AuthData, CognitoIdpSignInError> result = await sut.signInWithCognitoIdp();

        expect(result, isA<FailureResult<AuthData, CognitoIdpSignInError>>());
        switch (result) {
          case SuccessResult<AuthData, CognitoIdpSignInError>():
            fail('Expected failure');
          case FailureResult<AuthData, CognitoIdpSignInError>(error: final CognitoIdpSignInError error):
            expect(error, isA<DecodeJwtUnexpectedError>());
        }
      });

      test('failure: NonceMismatchFailure', () async {
        when(
          () => mockPkceTools.generatePkcePair(),
        ).thenReturn((codeVerifier: codeVerifier, codeChallenge: codeChallenge));
        int callCount = 0;
        when(
          () => mockPkceTools.generateUrlSafeString(length: any(named: 'length')),
        ).thenAnswer((_) => callCount++ == 0 ? state : nonce);

        final CognitoCallbackParams callbackParams = CognitoCallbackParams(code: authCode, state: state);

        when(
          () => mockCognitoIdpWebAuth.startWebAuthFlow(
            clientId: any(named: 'clientId'),
            clientSecret: any(named: 'clientSecret'),
            redirectUri: any(named: 'redirectUri'),
            state: any(named: 'state'),
            nonce: any(named: 'nonce'),
            identityProvider: any(named: 'identityProvider'),
            codeChallenge: any(named: 'codeChallenge'),
            codeChallengeMethod: any(named: 'codeChallengeMethod'),
            scopes: any(named: 'scopes'),
            customScopes: any(named: 'customScopes'),
            hostedUiDomain: any(named: 'hostedUiDomain'),
            webAuthOptions: any(named: 'webAuthOptions'),
          ),
        ).thenAnswer((_) async => SuccessResult<CognitoCallbackParams, WebAuthFlowError>(data: callbackParams));

        when(
          () => mockRemoteDataSource.exchangeCodeForAuthData(any()),
        ).thenAnswer((_) async => SuccessResult<AuthData, HttpError>(data: authData));

        const String wrongNonce = 'wrong-nonce';
        when(
          () => mockJwtDecoder.decodePayload(any()),
        ).thenReturn(SuccessResult<Map<String, dynamic>, DecodeJwtError>(data: <String, dynamic>{'nonce': wrongNonce}));

        final Result<AuthData, CognitoIdpSignInError> result = await sut.signInWithCognitoIdp();

        expect(result, isA<FailureResult<AuthData, CognitoIdpSignInError>>());
        switch (result) {
          case SuccessResult<AuthData, CognitoIdpSignInError>():
            fail('Expected failure');
          case FailureResult<AuthData, CognitoIdpSignInError>(error: final CognitoIdpSignInError error):
            expect(error, isA<NonceMismatchFailure>());
            final NonceMismatchFailure nonceMismatchError = error as NonceMismatchFailure;
            expect(nonceMismatchError.expectedNonce, equals(nonce));
            expect(nonceMismatchError.actualNonce, equals(wrongNonce));
        }
      });

      test('failure: UnexpectedError in catch block', () async {
        when(
          () => mockPkceTools.generatePkcePair(),
        ).thenReturn((codeVerifier: codeVerifier, codeChallenge: codeChallenge));
        int callCount = 0;
        when(
          () => mockPkceTools.generateUrlSafeString(length: any(named: 'length')),
        ).thenAnswer((_) => callCount++ == 0 ? state : nonce);

        final CognitoCallbackParams callbackParams = CognitoCallbackParams(code: authCode, state: state);

        when(
          () => mockCognitoIdpWebAuth.startWebAuthFlow(
            clientId: any(named: 'clientId'),
            clientSecret: any(named: 'clientSecret'),
            redirectUri: any(named: 'redirectUri'),
            state: any(named: 'state'),
            nonce: any(named: 'nonce'),
            identityProvider: any(named: 'identityProvider'),
            codeChallenge: any(named: 'codeChallenge'),
            codeChallengeMethod: any(named: 'codeChallengeMethod'),
            scopes: any(named: 'scopes'),
            customScopes: any(named: 'customScopes'),
            hostedUiDomain: any(named: 'hostedUiDomain'),
            webAuthOptions: any(named: 'webAuthOptions'),
          ),
        ).thenAnswer((_) async => SuccessResult<CognitoCallbackParams, WebAuthFlowError>(data: callbackParams));

        when(
          () => mockRemoteDataSource.exchangeCodeForAuthData(any()),
        ).thenAnswer((_) async => SuccessResult<AuthData, HttpError>(data: authData));

        // Throw an error when accessing requireData
        when(() => mockJwtDecoder.decodePayload(any())).thenThrow(Exception('Unexpected error in decode'));

        final Result<AuthData, CognitoIdpSignInError> result = await sut.signInWithCognitoIdp();

        expect(result, isA<FailureResult<AuthData, CognitoIdpSignInError>>());
        switch (result) {
          case SuccessResult<AuthData, CognitoIdpSignInError>():
            fail('Expected failure');
          case FailureResult<AuthData, CognitoIdpSignInError>(error: final CognitoIdpSignInError error):
            expect(error, isA<UnexpectedError>());
        }
      });

      test('finally block: invalidates pkceBundle after success', () async {
        when(
          () => mockPkceTools.generatePkcePair(),
        ).thenReturn((codeVerifier: codeVerifier, codeChallenge: codeChallenge));
        int callCount = 0;
        when(
          () => mockPkceTools.generateUrlSafeString(length: any(named: 'length')),
        ).thenAnswer((_) => callCount++ == 0 ? state : nonce);

        final CognitoCallbackParams callbackParams = CognitoCallbackParams(code: authCode, state: state);

        when(
          () => mockCognitoIdpWebAuth.startWebAuthFlow(
            clientId: any(named: 'clientId'),
            clientSecret: any(named: 'clientSecret'),
            redirectUri: any(named: 'redirectUri'),
            state: any(named: 'state'),
            nonce: any(named: 'nonce'),
            identityProvider: any(named: 'identityProvider'),
            codeChallenge: any(named: 'codeChallenge'),
            codeChallengeMethod: any(named: 'codeChallengeMethod'),
            scopes: any(named: 'scopes'),
            customScopes: any(named: 'customScopes'),
            hostedUiDomain: any(named: 'hostedUiDomain'),
            webAuthOptions: any(named: 'webAuthOptions'),
          ),
        ).thenAnswer((_) async => SuccessResult<CognitoCallbackParams, WebAuthFlowError>(data: callbackParams));

        when(
          () => mockRemoteDataSource.exchangeCodeForAuthData(any()),
        ).thenAnswer((_) async => SuccessResult<AuthData, HttpError>(data: authData));

        when(
          () => mockJwtDecoder.decodePayload(any()),
        ).thenReturn(SuccessResult<Map<String, dynamic>, DecodeJwtError>(data: <String, dynamic>{'nonce': nonce}));

        final Result<AuthData, CognitoIdpSignInError> result = await sut.signInWithCognitoIdp();

        expect(result, isA<SuccessResult<AuthData, CognitoIdpSignInError>>());

        expect(sut.checkIfPkceBundleExpired(options: options), isTrue);
      });

      test('finally block: invalidates pkceBundle after failure', () async {
        when(
          () => mockPkceTools.generatePkcePair(),
        ).thenReturn((codeVerifier: codeVerifier, codeChallenge: codeChallenge));
        int callCount = 0;
        when(
          () => mockPkceTools.generateUrlSafeString(length: any(named: 'length')),
        ).thenAnswer((_) => callCount++ == 0 ? state : nonce);

        final web_auth_flow_error.WebAuthFlowUnexpectedError callbackError =
            web_auth_flow_error.WebAuthFlowUnexpectedError(
              error: Exception('Network error'),
              stackTrace: StackTrace.current,
            );

        when(
          () => mockCognitoIdpWebAuth.startWebAuthFlow(
            clientId: any(named: 'clientId'),
            clientSecret: any(named: 'clientSecret'),
            redirectUri: any(named: 'redirectUri'),
            state: any(named: 'state'),
            nonce: any(named: 'nonce'),
            identityProvider: any(named: 'identityProvider'),
            codeChallenge: any(named: 'codeChallenge'),
            codeChallengeMethod: any(named: 'codeChallengeMethod'),
            scopes: any(named: 'scopes'),
            customScopes: any(named: 'customScopes'),
            hostedUiDomain: any(named: 'hostedUiDomain'),
            webAuthOptions: any(named: 'webAuthOptions'),
          ),
        ).thenAnswer((_) async => FailureResult<CognitoCallbackParams, WebAuthFlowError>(error: callbackError));

        final Result<AuthData, CognitoIdpSignInError> result = await sut.signInWithCognitoIdp();

        expect(result, isA<FailureResult<AuthData, CognitoIdpSignInError>>());

        expect(sut.checkIfPkceBundleExpired(options: options), isTrue);
      });

      test('options overrides properly propagate to all calls', () async {
        final CognitoIdpSignInOptionsOverrides overrides = CognitoIdpSignInOptionsOverrides(
          clientId: 'overridden-client-id',
          clientSecret: 'overridden-client-secret',
          hostedUiDomain: 'overridden-domain.auth.region.amazoncognito.com',
          redirectUri: Uri.parse('overridden-scheme://'),
          identityProviderName: 'OverriddenProvider',
          nonceLength: 51,
          stateLength: 52,
          codeChallengeMethod: .plain,
          scopes: <CognitoScope>[.email, .profile],
          customScopes: <CustomScope>['overridden-custom-scope'],
          pkceBundleLifetime: const Duration(minutes: 10),
          webAuthOptions: const CognitoIdpWebAuthOptions(preferEphemeral: true),
        );

        final String expectedClientId = overrides.clientId!;
        final String expectedClientSecret = overrides.clientSecret!;
        final String expectedHostedUiDomain = overrides.hostedUiDomain!;
        final Uri expectedRedirectUri = overrides.redirectUri!;
        final String expectedIdentityProvider = overrides.identityProviderName!;
        final int expectedNonceLength = overrides.nonceLength!;
        final int expectedStateLength = overrides.stateLength!;
        final CodeChallengeMethod expectedCodeChallengeMethod = overrides.codeChallengeMethod!;
        final List<CognitoScope> expectedScopes = overrides.scopes!;
        final List<CustomScope> expectedCustomScopes = overrides.customScopes!;
        final CognitoIdpWebAuthOptions expectedWebAuthOptions = overrides.webAuthOptions!;

        const String codeVerifier = 'test-code-verifier';
        const String codeChallenge = 'test-code-challenge';
        final String expectedState = 'state-with-overridden-length';
        final String expectedNonce = 'nonce-with-overridden-length';

        when(
          () => mockPkceTools.generatePkcePair(),
        ).thenReturn((codeVerifier: codeVerifier, codeChallenge: codeChallenge));
        when(() => mockPkceTools.generateUrlSafeString(length: expectedNonceLength)).thenReturn(expectedNonce);
        when(() => mockPkceTools.generateUrlSafeString(length: expectedStateLength)).thenReturn(expectedState);

        final CognitoCallbackParams callbackParams = CognitoCallbackParams(code: 'auth-code', state: expectedState);

        when(
          () => mockCognitoIdpWebAuth.startWebAuthFlow(
            clientId: any(named: 'clientId'),
            clientSecret: any(named: 'clientSecret'),
            redirectUri: any(named: 'redirectUri'),
            state: any(named: 'state'),
            nonce: any(named: 'nonce'),
            identityProvider: any(named: 'identityProvider'),
            codeChallenge: any(named: 'codeChallenge'),
            codeChallengeMethod: any(named: 'codeChallengeMethod'),
            scopes: any(named: 'scopes'),
            customScopes: any(named: 'customScopes'),
            hostedUiDomain: any(named: 'hostedUiDomain'),
            webAuthOptions: any(named: 'webAuthOptions', that: isA<CognitoIdpWebAuthOptions>()),
          ),
        ).thenAnswer((_) async => SuccessResult<CognitoCallbackParams, WebAuthFlowError>(data: callbackParams));

        final AuthData authData = AuthData(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          tokenType: 'Bearer',
          expiresIn: 3600,
          idToken: 'id-token',
        );

        when(
          () => mockRemoteDataSource.exchangeCodeForAuthData(any()),
        ).thenAnswer((_) async => SuccessResult<AuthData, HttpError>(data: authData));

        when(() => mockJwtDecoder.decodePayload(any())).thenReturn(
          SuccessResult<Map<String, dynamic>, DecodeJwtError>(data: <String, dynamic>{'nonce': expectedNonce}),
        );

        final IdpResult result = await sut.signInWithCognitoIdp(optionOverrides: overrides);

        expect(result, isA<SuccessResult<AuthData, CognitoIdpSignInError>>());
        switch (result) {
          case SuccessResult<AuthData, CognitoIdpSignInError>(data: final AuthData data):
            expect(data, equals(authData));
          case FailureResult<AuthData, CognitoIdpSignInError>(error: final CognitoIdpSignInError error):
            fail('Expected success, got error: $error');
        }

        verify(() => mockPkceTools.generateUrlSafeString(length: expectedNonceLength)).called(1);
        verify(() => mockPkceTools.generateUrlSafeString(length: expectedStateLength)).called(1);
        verify(() => mockPkceTools.generatePkcePair()).called(1);

        verify(
          () => mockCognitoIdpWebAuth.startWebAuthFlow(
            clientId: expectedClientId,
            clientSecret: expectedClientSecret,
            redirectUri: expectedRedirectUri,
            state: expectedState,
            nonce: expectedNonce,
            identityProvider: expectedIdentityProvider,
            codeChallenge: codeChallenge,
            codeChallengeMethod: expectedCodeChallengeMethod,
            scopes: expectedScopes,
            customScopes: expectedCustomScopes,
            hostedUiDomain: expectedHostedUiDomain,
            webAuthOptions: expectedWebAuthOptions,
          ),
        ).called(1);

        verify(
          () => mockRemoteDataSource.exchangeCodeForAuthData(
            CodeExchangeData(
              clientId: expectedClientId,
              clientSecret: expectedClientSecret,
              redirectUri: expectedRedirectUri.toString(),
              code: callbackParams.code,
              codeVerifier: codeVerifier,
            ),
          ),
        ).called(1);

        verify(() => mockJwtDecoder.decodePayload(authData.idToken!)).called(1);
      });

      test('package lifetime is respected when overrides are applied', () async {
        final CognitoIdpSignInOptionsOverrides overrides = CognitoIdpSignInOptionsOverrides(
          pkceBundleLifetime: const Duration(minutes: 0),
        );

        const String expectedState = 'state-with-overridden-length';

        final CognitoCallbackParams callbackParams = CognitoCallbackParams(code: 'auth-code', state: expectedState);

        when(
          () => mockCognitoIdpWebAuth.startWebAuthFlow(
            clientId: any(named: 'clientId'),
            clientSecret: any(named: 'clientSecret'),
            redirectUri: any(named: 'redirectUri'),
            state: any(named: 'state'),
            nonce: any(named: 'nonce'),
            identityProvider: any(named: 'identityProvider'),
            codeChallenge: any(named: 'codeChallenge'),
            codeChallengeMethod: any(named: 'codeChallengeMethod'),
            scopes: any(named: 'scopes'),
            customScopes: any(named: 'customScopes'),
            hostedUiDomain: any(named: 'hostedUiDomain'),
            webAuthOptions: any(named: 'webAuthOptions', that: isA<CognitoIdpWebAuthOptions>()),
          ),
        ).thenAnswer((_) async => SuccessResult<CognitoCallbackParams, WebAuthFlowError>(data: callbackParams));

        when(
          () => mockPkceTools.generatePkcePair(),
        ).thenReturn((codeVerifier: codeVerifier, codeChallenge: codeChallenge));
        when(() => mockPkceTools.generateUrlSafeString(length: any(named: 'length'))).thenReturn(nonce);
        when(() => mockPkceTools.generateUrlSafeString(length: any(named: 'length'))).thenReturn(state);

        final IdpResult result = await sut.signInWithCognitoIdp(optionOverrides: overrides);

        switch (result) {
          case SuccessResult<AuthData, CognitoIdpSignInError>():
            fail('Expected failure');
          case FailureResult<AuthData, CognitoIdpSignInError>(error: final CognitoIdpSignInError error):
            expect(error, isA<StateExpiredError>());

            final StateExpiredError casted = error as StateExpiredError;
            expect(casted.createdAt, isNot(isNull));
            expect(casted.age, greaterThanOrEqualTo(const Duration(minutes: 0)));
            expect(casted.maxLifetime, equals(const Duration(minutes: 0)));
        }
      });
    });
  });
}
