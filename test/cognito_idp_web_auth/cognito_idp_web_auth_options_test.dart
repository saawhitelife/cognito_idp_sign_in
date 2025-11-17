import 'package:cognito_idp_sign_in/src/cognito_idp_web_auth/cognito_idp_web_auth_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CognitoIdpWebAuthOptions', () {
    test('== returns true for identical instances', () {
      const CognitoIdpWebAuthOptions options1 = CognitoIdpWebAuthOptions(preferEphemeral: true);
      const CognitoIdpWebAuthOptions options2 = CognitoIdpWebAuthOptions(preferEphemeral: true);

      expect(options1 == options2, isTrue);
      expect(options1.hashCode, equals(options2.hashCode));
    });

    test('== returns false for different instances', () {
      const CognitoIdpWebAuthOptions options1 = CognitoIdpWebAuthOptions(preferEphemeral: true);
      const CognitoIdpWebAuthOptions options2 = CognitoIdpWebAuthOptions(preferEphemeral: false);

      expect(options1 == options2, isFalse);
    });

    test('== compares all fields correctly', () {
      const CognitoIdpWebAuthOptions options1 = CognitoIdpWebAuthOptions(
        preferEphemeral: true,
        debugOrigin: 'http://localhost',
        intentFlags: 123,
        windowName: 'test-window',
        timeout: 300,
        landingPageHtml: '<html>test</html>',
        silentAuth: true,
        useWebview: false,
        httpsHost: 'example.com',
        httpsPath: '/callback',
        customTabsPackageOrder: <String>['com.chrome.browser'],
      );

      const CognitoIdpWebAuthOptions options2 = CognitoIdpWebAuthOptions(
        preferEphemeral: true,
        debugOrigin: 'http://localhost',
        intentFlags: 123,
        windowName: 'test-window',
        timeout: 300,
        landingPageHtml: '<html>test</html>',
        silentAuth: true,
        useWebview: false,
        httpsHost: 'example.com',
        httpsPath: '/callback',
        customTabsPackageOrder: <String>['com.chrome.browser'],
      );

      expect(options1 == options2, isTrue);
      expect(options1.hashCode, equals(options2.hashCode));
    });

    test('== returns false when customTabsPackageOrder differs', () {
      const CognitoIdpWebAuthOptions options1 = CognitoIdpWebAuthOptions(
        customTabsPackageOrder: <String>['com.chrome.browser'],
      );

      const CognitoIdpWebAuthOptions options2 = CognitoIdpWebAuthOptions(
        customTabsPackageOrder: <String>['com.firefox.browser'],
      );

      expect(options1 == options2, isFalse);
    });

    test('== handles null customTabsPackageOrder correctly', () {
      const CognitoIdpWebAuthOptions options1 = CognitoIdpWebAuthOptions(customTabsPackageOrder: null);
      const CognitoIdpWebAuthOptions options2 = CognitoIdpWebAuthOptions(customTabsPackageOrder: null);

      expect(options1 == options2, isTrue);
    });

    test('== returns false when one has null and other has list for customTabsPackageOrder', () {
      const CognitoIdpWebAuthOptions options1 = CognitoIdpWebAuthOptions(customTabsPackageOrder: null);
      const CognitoIdpWebAuthOptions options2 = CognitoIdpWebAuthOptions(
        customTabsPackageOrder: <String>['com.chrome.browser'],
      );

      expect(options1 == options2, isFalse);
    });

    test('hashCode is consistent', () {
      const CognitoIdpWebAuthOptions options = CognitoIdpWebAuthOptions(preferEphemeral: true);

      expect(options.hashCode, equals(options.hashCode));
    });

    test('hashCode differs for different instances', () {
      const CognitoIdpWebAuthOptions options1 = CognitoIdpWebAuthOptions(preferEphemeral: true);
      const CognitoIdpWebAuthOptions options2 = CognitoIdpWebAuthOptions(preferEphemeral: false);

      expect(options1.hashCode, isNot(equals(options2.hashCode)));
    });
  });

  group('CognitoIdpWebAuthOptions.fromJson', () {
    test('parses all fields correctly', () {
      final CognitoIdpWebAuthOptions options = CognitoIdpWebAuthOptions.fromJson(<String, dynamic>{
        'preferEphemeral': true,
        'debugOrigin': 'http://localhost',
        'intentFlags': 123,
        'windowName': 'test-window',
        'timeout': 300,
        'landingPageHtml': '<html>test</html>',
        'silentAuth': true,
        'useWebview': false,
        'httpsHost': 'example.com',
        'httpsPath': '/callback',
        'customTabsPackageOrder': <String>['com.chrome.browser'],
      });

      expect(options.preferEphemeral, isTrue);
      expect(options.debugOrigin, 'http://localhost');
      expect(options.intentFlags, 123);
      expect(options.windowName, 'test-window');
      expect(options.timeout, 300);
      expect(options.landingPageHtml, '<html>test</html>');
      expect(options.silentAuth, isTrue);
      expect(options.useWebview, isFalse);
      expect(options.httpsHost, 'example.com');
      expect(options.httpsPath, '/callback');
      expect(options.customTabsPackageOrder, <String>['com.chrome.browser']);
    });

    test('handles null values', () {
      final CognitoIdpWebAuthOptions options = CognitoIdpWebAuthOptions.fromJson(<String, dynamic>{
        'preferEphemeral': false,
        'debugOrigin': null,
        'windowName': null,
        'httpsHost': null,
        'httpsPath': null,
        'customTabsPackageOrder': null,
      });

      expect(options.debugOrigin, isNull);
      expect(options.windowName, isNull);
      expect(options.httpsHost, isNull);
      expect(options.httpsPath, isNull);
      expect(options.customTabsPackageOrder, isNull);
    });
  });

  group('CognitoIdpWebAuthOptions.toJson', () {
    test('converts all fields to JSON', () {
      const CognitoIdpWebAuthOptions options = CognitoIdpWebAuthOptions(
        preferEphemeral: true,
        debugOrigin: 'http://localhost',
        intentFlags: 123,
        windowName: 'test-window',
        timeout: 300,
        landingPageHtml: '<html>test</html>',
        silentAuth: true,
        useWebview: false,
        httpsHost: 'example.com',
        httpsPath: '/callback',
        customTabsPackageOrder: <String>['com.chrome.browser'],
      );

      final Map<String, dynamic> json = options.toJson();

      expect(json['preferEphemeral'], isTrue);
      expect(json['debugOrigin'], 'http://localhost');
      expect(json['intentFlags'], 123);
      expect(json['windowName'], 'test-window');
      expect(json['timeout'], 300);
      expect(json['landingPageHtml'], '<html>test</html>');
      expect(json['silentAuth'], isTrue);
      expect(json['useWebview'], isFalse);
      expect(json['httpsHost'], 'example.com');
      expect(json['httpsPath'], '/callback');
      expect(json['customTabsPackageOrder'], <String>['com.chrome.browser']);
    });

    test('toJson round-trips with fromJson', () {
      const CognitoIdpWebAuthOptions original = CognitoIdpWebAuthOptions(
        preferEphemeral: true,
        debugOrigin: 'http://localhost',
        intentFlags: 123,
        windowName: 'test-window',
        timeout: 300,
        landingPageHtml: '<html>test</html>',
        silentAuth: true,
        useWebview: false,
        httpsHost: 'example.com',
        httpsPath: '/callback',
        customTabsPackageOrder: <String>['com.chrome.browser'],
      );

      final Map<String, dynamic> json = original.toJson();
      final CognitoIdpWebAuthOptions roundTripped = CognitoIdpWebAuthOptions.fromJson(json);

      expect(roundTripped, equals(original));
    });
  });

  group('CognitoIdpWebAuthOptions.copyWith', () {
    test('creates a copy with updated fields', () {
      const CognitoIdpWebAuthOptions original = CognitoIdpWebAuthOptions(
        preferEphemeral: false,
        debugOrigin: 'http://localhost',
        timeout: 300,
      );

      final CognitoIdpWebAuthOptions copied = original.copyWith(preferEphemeral: true, timeout: 600);

      expect(copied.preferEphemeral, isTrue);
      expect(copied.debugOrigin, 'http://localhost'); // unchanged
      expect(copied.timeout, 600);
    });

    test('creates a copy with all fields unchanged when no parameters provided', () {
      const CognitoIdpWebAuthOptions original = CognitoIdpWebAuthOptions(
        preferEphemeral: true,
        debugOrigin: 'http://localhost',
        intentFlags: 123,
        windowName: 'test-window',
        timeout: 300,
        landingPageHtml: '<html>test</html>',
        silentAuth: true,
        useWebview: false,
        httpsHost: 'example.com',
        httpsPath: '/callback',
        customTabsPackageOrder: <String>['com.chrome.browser'],
      );

      final CognitoIdpWebAuthOptions copied = original.copyWith();

      expect(copied, equals(original));
    });

    test('passing null in copyWith preserves existing values', () {
      const CognitoIdpWebAuthOptions original = CognitoIdpWebAuthOptions(
        debugOrigin: 'http://localhost',
        httpsHost: 'example.com',
      );

      final CognitoIdpWebAuthOptions copied = original.copyWith(debugOrigin: null, httpsHost: null);

      // copyWith uses ?? operator, so null values preserve the original
      expect(copied.debugOrigin, 'http://localhost');
      expect(copied.httpsHost, 'example.com');
    });
  });
}
