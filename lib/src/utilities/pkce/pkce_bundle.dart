class PkceBundle {
  PkceBundle({
    required this.codeVerifier,
    required this.codeChallenge,
    required this.state,
    required this.nonce,
    required this.createdAt,
  });

  final String codeVerifier;
  final String codeChallenge;
  final String state;
  final String nonce;

  final DateTime createdAt;

  Duration get age => DateTime.now().difference(createdAt);
}
