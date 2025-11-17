import 'package:cognito_idp_sign_in/src/http/http.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HttpStatusCode', () {
    test('fromCode returns known code', () {
      expect(HttpStatusCode.fromCode(200), HttpStatusCode.ok);
      expect(HttpStatusCode.fromCode(404), HttpStatusCode.notFound);
    });

    test('fromCode returns unknown for unmapped code', () {
      expect(HttpStatusCode.fromCode(999), HttpStatusCode.unknown);
      expect(HttpStatusCode.fromCode(-1), HttpStatusCode.unknown);
    });

    test('category getters work', () {
      expect(HttpStatusCode.ok.isSuccess, isTrue);
      expect(HttpStatusCode.notFound.isClientError, isTrue);
      expect(HttpStatusCode.badGateway.isServerError, isTrue);
      expect(HttpStatusCode.temporaryRedirect.isRedirection, isTrue);
      expect(HttpStatusCode.continue_.isInformational, isTrue);
    });

    test('toString works', () {
      expect(HttpStatusCode.ok.toString(), '200 OK');
      expect(HttpStatusCode.notFound.toString(), '404 Not Found');
      expect(HttpStatusCode.badGateway.toString(), '502 Bad Gateway');
      expect(HttpStatusCode.temporaryRedirect.toString(), '307 Temporary Redirect');
      expect(HttpStatusCode.continue_.toString(), '100 Continue');
    });
  });
}
