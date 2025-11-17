/// HTTP status codes for API responses.
///
/// This enum represents the standard HTTP status codes used in API responses.
/// It provides methods to convert between status codes and their corresponding
/// string representations, as well as to check if a status code belongs to
/// specific categories like informational, success, redirection, client error,
/// or server error.
enum HttpStatusCode {
  continue_(100, 'Continue'),
  switchingProtocols(101, 'Switching Protocols'),
  processing(102, 'Processing'),

  ok(200, 'OK'),
  created(201, 'Created'),
  accepted(202, 'Accepted'),
  nonAuthoritativeInformation(203, 'Non-Authoritative Information'),
  noContent(204, 'No Content'),
  resetContent(205, 'Reset Content'),
  partialContent(206, 'Partial Content'),
  multiStatus(207, 'Multi-Status'),

  multipleChoices(300, 'Multiple Choices'),
  movedPermanently(301, 'Moved Permanently'),
  movedTemporarily(302, 'Moved Temporarily'),
  seeOther(303, 'See Other'),
  notModified(304, 'Not Modified'),
  @Deprecated('Deprecated in RFC 7231 due to security concerns')
  useProxy(305, 'Use Proxy'),
  temporaryRedirect(307, 'Temporary Redirect'),
  permanentRedirect(308, 'Permanent Redirect'),

  badRequest(400, 'Bad Request'),
  unauthorized(401, 'Unauthorized'),
  paymentRequired(402, 'Payment Required'),
  forbidden(403, 'Forbidden'),
  notFound(404, 'Not Found'),
  methodNotAllowed(405, 'Method Not Allowed'),
  notAcceptable(406, 'Not Acceptable'),
  proxyAuthenticationRequired(407, 'Proxy Authentication Required'),
  requestTimeout(408, 'Request Timeout'),
  conflict(409, 'Conflict'),
  gone(410, 'Gone'),
  lengthRequired(411, 'Length Required'),
  preconditionFailed(412, 'Precondition Failed'),
  requestTooLong(413, 'Request Too Long'),
  requestUriTooLong(414, 'Request-URI Too Long'),
  unsupportedMediaType(415, 'Unsupported Media Type'),
  requestedRangeNotSatisfiable(416, 'Requested Range Not Satisfiable'),
  expectationFailed(417, 'Expectation Failed'),
  imATeapot(418, "I'm a Teapot"),
  insufficientSpaceOnResource(419, 'Insufficient Space on Resource'),
  @Deprecated('Spring-specific; not an official HTTP status')
  methodFailure(420, 'Method Failure'),
  unprocessableEntity(422, 'Unprocessable Entity'),
  locked(423, 'Locked'),
  failedDependency(424, 'Failed Dependency'),
  preconditionRequired(428, 'Precondition Required'),
  tooManyRequests(429, 'Too Many Requests'),
  requestHeaderFieldsTooLarge(431, 'Request Header Fields Too Large'),
  unavailableForLegalReasons(451, 'Unavailable For Legal Reasons'),

  internalServerError(500, 'Internal Server Error'),
  notImplemented(501, 'Not Implemented'),
  badGateway(502, 'Bad Gateway'),
  serviceUnavailable(503, 'Service Unavailable'),
  gatewayTimeout(504, 'Gateway Timeout'),
  httpVersionNotSupported(505, 'HTTP Version Not Supported'),
  insufficientStorage(507, 'Insufficient Storage'),
  networkAuthenticationRequired(511, 'Network Authentication Required'),
  // Fallback for unknown status codes
  unknown(0, 'Unknown');

  final int code;
  final String message;
  const HttpStatusCode(this.code, this.message);

  static final Map<int, HttpStatusCode> byCode = <int, HttpStatusCode>{
    for (final HttpStatusCode s in HttpStatusCode.values) s.code: s,
  };

  static HttpStatusCode? tryFromCode(int code) => byCode[code];

  static HttpStatusCode fromCode(int code) {
    final HttpStatusCode? s = tryFromCode(code);
    if (s == null) {
      return HttpStatusCode.unknown;
    }
    return s;
  }

  bool get isInformational => code >= 100 && code < 200;
  bool get isSuccess => code >= 200 && code < 300;
  bool get isRedirection => code >= 300 && code < 400;
  bool get isClientError => code >= 400 && code < 500;
  bool get isServerError => code >= 500 && code < 600;

  @override
  String toString() => '$code $message';
}
