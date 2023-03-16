import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:git_hub_repo_viewer/auth/domain/auth_failure.dart';
import 'package:git_hub_repo_viewer/auth/infrastructure/credentials_storage/credentials_storage.dart';
import 'package:git_hub_repo_viewer/auth/infrastructure/infrastructure/dio_extensions.dart';
import 'package:git_hub_repo_viewer/core/shared/encoder.dart';
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
  final Dio _dio;
  static const clientId = "f7fb4a16b00f2bbff87a";
  static const clientSecret = "52a0fb60e95e30fc52c2e985b4d1787d0a4374e2";
  static const scopes = ["repo", "user"];
  static final authorizationEndpoint =
      Uri.parse("https://github.com/login/oauth/authorize");
  static final tokenEndpoint =
      Uri.parse("https://github.com/login/oauth/access_token");
  static final redirectUrl = Uri.parse("http://localhost:3000/callback");
  static final revocationEndpoint =
      Uri.parse("https://api.github.com/applications/$clientId/tokens");
  GithubAuthenticator(this._credentialsStorage, this._dio);
  Future<Credentials?> getSignedInCredentials() async {
    try {
      final storedCredentials = await _credentialsStorage.read();
      if (storedCredentials != null) {
        if (storedCredentials.canRefresh && storedCredentials.isExpired) {
          final failureOrCredentials = await refresh(storedCredentials);
          return failureOrCredentials.fold(
            (f) => null,
            (credentials) => credentials,
          );
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

  Future<Either<AuthFailure, Unit>> signOut() async {
    final accessToken = await _credentialsStorage
        .read()
        .then((credential) => credential?.accessToken);
    final usernameAndPassword =
        stringToBase64.encode("$clientId:$clientSecret");
    try {
      try {
        _dio.deleteUri(revocationEndpoint,
            data: {
              "access_token": accessToken,
            },
            options: Options(
              headers: {"Authorization": "basic $usernameAndPassword"},
            ));
      } on DioError catch (e) {
        if (e.isConnectionError) {
          // Ignore connection error
          print("e.isConnectionError");
        } else {
          rethrow;
        }
      }
      await _credentialsStorage.clear();
      return right(unit);
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }

  Future<Either<AuthFailure, Credentials>> refresh(
      Credentials credentials) async {
    try {
      final refreshCredentials = await credentials.refresh(
        identifier: clientId,
        secret: clientSecret,
        httpClient: GithubOAuthHttpClient(),
      );
      await _credentialsStorage.save(refreshCredentials);
      return right(refreshCredentials);
    } on FormatException {
      return left(const AuthFailure.server());
    } on AuthorizationException catch (e) {
      return left(AuthFailure.server("${e.error}: ${e.description}"));
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }
}
