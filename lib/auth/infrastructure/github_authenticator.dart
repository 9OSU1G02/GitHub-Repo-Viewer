import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:git_hub_repo_viewer/auth/domain/auth_failure.dart';
import 'package:git_hub_repo_viewer/auth/infrastructure/credentials_storage/credentials_storage.dart';
import 'package:oauth2/oauth2.dart';
import 'package:http/http.dart' as http;

class GithubOAuthHttpClient extends http.BaseClient {
  final httpClient = http.Client();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers["Accept"] = "application/json";
    return httpClient.send(request);
  }
}

class GithubAuthenticator {
  final CredentialsStorage _credentialsStorage;
  static const clientId = "f7fb4a16b00f2bbff87a";
  static const clientSecret = "52a0fb60e95e30fc52c2e985b4d1787d0a4374e2";
  static const scopes = ["repo", "user"];
  static final authorizationEndpoint =
      Uri.parse("https://github.com/login/oauth/authorize");
  static final tokenEndpoint =
      Uri.parse("https://github.com/login/oauth/access_token");
  static final redirectUrl = Uri.parse("http://localhost:3000/callback");
  GithubAuthenticator(this._credentialsStorage);
  Future<Credentials?> getSignedInCredentials() async {
    try {
      final storedCredentials = await _credentialsStorage.read();
      if (storedCredentials != null) {
        if (storedCredentials.canRefresh && storedCredentials.isExpired) {
          // TODO: Refresh token
        }
      }
      return storedCredentials;
    } on PlatformException {
      return null;
    }
  }

  Future<bool> isSignedIn() async {
    return getSignedInCredentials().then((credential) => null != credential);
  }

  AuthorizationCodeGrant createGrant() {
    return AuthorizationCodeGrant(
      clientId,
      authorizationEndpoint,
      tokenEndpoint,
      secret: clientSecret,
      httpClient: GithubOAuthHttpClient(),
    );
  }

  Uri getAuthorizationUrl(AuthorizationCodeGrant grant) {
    return grant.getAuthorizationUrl(redirectUrl, scopes: scopes);
  }

  Future<Either<AuthFailure, Unit>> handleAuthorizationResponse(
    AuthorizationCodeGrant grant,
    Map<String, String> queryParameters,
  ) async {
    try {
      final httpClient =
          await grant.handleAuthorizationResponse(queryParameters);
      await _credentialsStorage.save(httpClient.credentials);
      return right(unit);
    } on FormatException {
      return left(const AuthFailure.server());
    } on AuthorizationException catch (e) {
      return left(AuthFailure.server("${e.error}: ${e.description}"));
    }
  }
}
