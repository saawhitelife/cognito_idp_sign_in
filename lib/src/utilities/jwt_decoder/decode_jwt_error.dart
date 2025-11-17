sealed class DecodeJwtError {
  const DecodeJwtError();
}

class DecodeJwtInvalidPayloadError extends DecodeJwtError {
  const DecodeJwtInvalidPayloadError();

  @override
  String toString() {
    return 'DecodeJwtInvalidPayloadError';
  }
}

class DecodeJwtUnexpectedError extends DecodeJwtError {
  const DecodeJwtUnexpectedError(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'DecodeJwtUnexpectedError(error: $error, stackTrace: $stackTrace)';
  }
}
