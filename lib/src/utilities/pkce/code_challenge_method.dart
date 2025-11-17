/// PKCE code challenge methods for OAuth 2.0 authorization.
///
/// The code challenge method determines how the code verifier is transformed
/// into a code challenge during the PKCE flow. S256 is the recommended method
/// for security.
///
/// Reference: [RFC 7636 - PKCE](https://tools.ietf.org/html/rfc7636)
enum CodeChallengeMethod {
  /// SHA-256 hash transformation method (recommended).
  ///
  /// Transforms the code verifier using SHA-256 hashing and base64url encoding.
  /// This is the most secure option and should be used whenever supported.
  s256('S256'),

  /// Plain text transformation method (fallback only).
  ///
  /// Uses the code verifier directly without transformation. This method is less
  /// secure and should only be used when S256 is not supported on the device.
  plain('plain');

  const CodeChallengeMethod(this.value);

  /// The string value of this method as used in OAuth 2.0 requests.
  final String value;
}
