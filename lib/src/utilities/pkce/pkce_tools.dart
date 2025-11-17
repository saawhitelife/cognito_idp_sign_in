import 'dart:convert';
import 'dart:math';

import 'code_challenge_method.dart';
import 'package:crypto/crypto.dart';

typedef PkcePair = ({String codeVerifier, String codeChallenge});

/// RFC 7636 helpers for PKCE (S256).
/// - code_verifier: 43..128 chars, URL-safe
/// - code_challenge: BASE64URL-encoded SHA256(verifier), no padding
class PkceTools {
  /// Generate a new verifier/challenge pair.
  /// [length] must be in 43..128 (64 is a good default).
  PkcePair generatePkcePair({int length = 64, CodeChallengeMethod codeChallengeMethod = .s256}) {
    assert(length >= 43 && length <= 128, 'PKCE code_verifier length must be 43..128');

    final String verifier = generateUrlSafeString(length: length);

    final String challenge = switch (codeChallengeMethod) {
      .s256 => challengeS256(verifier),
      .plain => challengePlain(verifier),
    };

    return (codeVerifier: verifier, codeChallenge: challenge);
  }

  /// Generate a code_verifier consisting of URL-safe characters.
  /// Allowed char set per spec: ALPHA / DIGIT / "-" / "." / "_" / "~"
  String generateUrlSafeString({required int length}) {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final Random rnd = Random.secure();
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < length; i++) {
      buf.write(chars[rnd.nextInt(chars.length)]);
    }
    return buf.toString();
  }

  /// Compute S256 code_challenge from a code_verifier.
  /// Encoded as base64url without padding (= removed).
  String challengeS256(String verifier) {
    final List<int> bytes = utf8.encode(verifier);
    final List<int> digest = sha256.convert(bytes).bytes;
    return _base64UrlNoPadding(digest);
  }

  /// Compute plain code_challenge from a code_verifier.
  String challengePlain(String verifier) {
    return verifier;
  }

  /// Base64url encode without '=' padding.
  String _base64UrlNoPadding(List<int> bytes) => base64Url.encode(bytes).replaceAll('=', '');
}
