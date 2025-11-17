import 'dart:convert';

import '../../generic/generic.dart';
import 'decode_jwt_error.dart';

typedef DecodeJwtResult = Result<Map<String, dynamic>, DecodeJwtError>;

class JwtDecoder {
  DecodeJwtResult decodePayload(String jwtToken) {
    try {
      final String payload = jwtToken.split('.')[1];
      final String normalizedPayload = base64Url.normalize(payload);

      final dynamic decoded = jsonDecode(utf8.decode(base64Url.decode(normalizedPayload)));

      if (decoded is! Map<String, dynamic>) {
        return FailureResult<Map<String, dynamic>, DecodeJwtError>(error: DecodeJwtInvalidPayloadError());
      }

      return SuccessResult<Map<String, dynamic>, DecodeJwtError>(data: decoded);
    } catch (error, stackTrace) {
      return FailureResult<Map<String, dynamic>, DecodeJwtError>(error: DecodeJwtUnexpectedError(error, stackTrace));
    }
  }
}
