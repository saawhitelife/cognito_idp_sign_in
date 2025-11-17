/// A result type representing either success with data or failure with an error.
///
/// This sealed class ensures exhaustive pattern matching when handling results.
/// Use with switch expressions or switch statements to handle both cases.
sealed class Result<T, E> {
  const Result();

  /// Returns the data if this is a [SuccessResult], otherwise throws an exception.
  ///
  /// Use this when you're certain the result is a success or want to fail fast
  /// on errors. For safer handling, use pattern matching instead.
  T get requireData => switch (this) {
    SuccessResult<T, E>(:final T data) => data,
    FailureResult<T, E>(:final E error) => throw Exception('Expected data, but got error: $error'),
  };
}

/// A successful result containing data of type [T].
class SuccessResult<T, E> extends Result<T, E> {
  const SuccessResult({required this.data});

  /// The successful data value.
  final T data;

  @override
  String toString() {
    return 'SuccessResult(data: $data)';
  }
}

/// A failed result containing an error of type [E].
class FailureResult<T, E> extends Result<T, E> {
  const FailureResult({required this.error});

  /// The error that caused the failure.
  final E error;

  @override
  String toString() {
    return 'FailureResult(error: $error)';
  }
}
