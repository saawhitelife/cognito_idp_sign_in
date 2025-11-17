import 'package:cognito_idp_sign_in/src/cognito_idp_web_auth/cognito_idp_web_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel methodChannel = MethodChannel('flutter_web_auth_2');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(methodChannel, null);
  });

  group('WebAuth', () {
    test('WebAuthFlutter delegates to FlutterWebAuth2 with correct args', () async {
      final String url = 'https://example.com';
      final String callbackUrlScheme = 'example';
      final CognitoIdpWebAuthOptions options = CognitoIdpWebAuthOptions(
        preferEphemeral: false,
        debugOrigin: 'https://example.com',
        intentFlags: 1,
        windowName: 'window-name',
      );

      bool handlerCalled = false;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(methodChannel, (
        MethodCall methodCall,
      ) async {
        handlerCalled = true;

        expect(methodCall.method, 'authenticate');
        expect(methodCall.arguments, isMap);
        expect(methodCall.arguments['url'], url);
        expect(methodCall.arguments['callbackUrlScheme'], callbackUrlScheme);
        expect(methodCall.arguments['options'], options.toJson());

        return 'example://callback?code=authCode&state=state';
      });

      final WebAuthFlutter webAuth = WebAuthFlutter();

      final String result = await webAuth.authenticate(
        url: url,
        callbackUrlScheme: callbackUrlScheme,
        options: options,
      );

      expect(result, equals('example://callback?code=authCode&state=state'));
      expect(handlerCalled, isTrue);
    });

    test('Surfaces PlatformExceptions', () async {
      final String url = 'https://example.com';
      final String callbackUrlScheme = 'example';
      final CognitoIdpWebAuthOptions options = CognitoIdpWebAuthOptions(
        preferEphemeral: false,
        debugOrigin: 'https://example.com',
        intentFlags: 1,
        windowName: 'window-name',
      );

      bool handlerCalled = false;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(methodChannel, (
        MethodCall methodCall,
      ) async {
        handlerCalled = true;
        throw PlatformException(code: 'canceled', message: 'User canceled');
      });

      final WebAuthFlutter webAuth = WebAuthFlutter();

      final Future<String> call = webAuth.authenticate(
        url: url,
        callbackUrlScheme: callbackUrlScheme,
        options: options,
      );

      expect(call, throwsA(isA<PlatformException>()));
      expect(handlerCalled, isTrue);
    });
  });
}
