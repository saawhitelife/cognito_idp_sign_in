import 'package:flutter/services.dart' show PlatformException;

sealed class WebAuthFlowError {
  const WebAuthFlowError();
}

class WebAuthFlowUnexpectedError extends WebAuthFlowError {
  const WebAuthFlowUnexpectedError({required this.error, required this.stackTrace});
  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'WebAuthFlowUnexpectedError(error: $error, stackTrace: $stackTrace)';
  }
}

class WebAuthFlowInvalidCallbackUrlError extends WebAuthFlowError {
  const WebAuthFlowInvalidCallbackUrlError({required this.callbackUrl, required this.error, required this.stackTrace});

  final String callbackUrl;
  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'WebAuthFlowInvalidCallbackUrlError(callbackUrl: $callbackUrl, error: $error, stackTrace: $stackTrace)';
  }
}

class WebAuthFlowPlatformError extends WebAuthFlowError {
  const WebAuthFlowPlatformError({required this.error, required this.stackTrace});
  final PlatformException error;
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'WebAuthFlowPlatformError(error: $error, stackTrace: $stackTrace)';
  }
}
