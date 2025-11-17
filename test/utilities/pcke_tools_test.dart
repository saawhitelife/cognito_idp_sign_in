import 'package:cognito_idp_sign_in/src/utilities/utilities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PkceTools', () {
    final PkceTools pkce = PkceTools();

    const String allowedCharsPattern = r'^[A-Za-z0-9\-\.\_\~]+$';
    final RegExp allowedRegex = RegExp(allowedCharsPattern);

    test('generateUrlSafeString: returns correct length and allowed charset (default 64)', () {
      final String s = pkce.generateUrlSafeString(length: 64);
      expect(s.length, 64);
      expect(allowedRegex.hasMatch(s), isTrue, reason: 'Verifier contains characters outside ALPHA/DIGIT/-._~');
    });

    test('generateUrlSafeString: respects min (43) and max (128) lengths', () {
      final String vMin = pkce.generateUrlSafeString(length: 43);
      final String vMax = pkce.generateUrlSafeString(length: 128);
      expect(vMin.length, 43);
      expect(vMax.length, 128);
      expect(allowedRegex.hasMatch(vMin), isTrue);
      expect(allowedRegex.hasMatch(vMax), isTrue);
    });

    test('generateUrlSafeString: asserts when length is out of bounds', () {
      // Dart tests run with asserts enabled by default; expect AssertionError.
      expect(() => pkce.generatePkcePair(length: 42), throwsA(isA<AssertionError>()));
      expect(() => pkce.generatePkcePair(length: 129), throwsA(isA<AssertionError>()));
    });

    test('challengeS256: matches RFC 7636 known vector (Appendix B)', () {
      // From RFC 7636 Appendix B (S256 example)
      // https://datatracker.ietf.org/doc/html/rfc7636#appendix-B
      const String verifier = 'dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk';
      const String expectedChallenge = 'E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM';

      expect(pkce.challengeS256(verifier), expectedChallenge);
    });

    test('challengeS256: result is URL-safe base64 without padding', () {
      final String challenge = pkce.challengeS256('someVerifierValue-._~123ABCxyz');
      // URL-safe: no '+' or '/'
      expect(challenge.contains('+'), isFalse);
      expect(challenge.contains('/'), isFalse);
      // No padding '='
      expect(challenge.contains('='), isFalse);
      // Non-empty
      expect(challenge.isNotEmpty, isTrue);
    });

    test('generatePkcePair: returns self-consistent verifier/challenge', () {
      final PkcePair pair = pkce.generatePkcePair(length: 64);
      expect(pair.codeVerifier.length, 64);
      expect(allowedRegex.hasMatch(pair.codeVerifier), isTrue);
      expect(pair.codeChallenge, pkce.challengeS256(pair.codeVerifier));
    });

    test('generatePkcePair: different calls produce different verifiers (very likely)', () {
      // Not a statistical test, just a sanity check to catch accidental determinism.
      final PkcePair a = pkce.generatePkcePair(length: 64);
      final PkcePair b = pkce.generatePkcePair(length: 64);
      expect(
        a.codeVerifier == b.codeVerifier,
        isFalse,
        reason: 'Verifiers should be random (Random.secure) and rarely equal',
      );
    });

    test('generatePkcePair: plain challenge method', () {
      final PkcePair pair = pkce.generatePkcePair(length: 64, codeChallengeMethod: .plain);
      expect(pair.codeChallenge, pair.codeVerifier);
    });
  });
}
