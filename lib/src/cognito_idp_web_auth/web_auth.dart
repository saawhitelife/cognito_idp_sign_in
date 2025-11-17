import 'cognito_idp_web_auth_options.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

abstract class WebAuth {
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    CognitoIdpWebAuthOptions? options,
  });
}

class WebAuthFlutter implements WebAuth {
  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    CognitoIdpWebAuthOptions? options,
  }) {
    return FlutterWebAuth2.authenticate(
      url: url,
      callbackUrlScheme: callbackUrlScheme,
      options: options?.toFlutterWebAuth2Options() ?? FlutterWebAuth2Options(),
    );
  }
}
