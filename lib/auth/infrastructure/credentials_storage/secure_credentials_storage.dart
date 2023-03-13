// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oauth2/oauth2.dart';
import 'package:git_hub_repo_viewer/auth/infrastructure/credentials_storage/credentials_storage.dart';

class SecureCredentialsStorage implements CredentialsStorage {
  final FlutterSecureStorage _storage;
  Credentials? _cacheCredentials;
  static const _key = "oauth2_credentials";

  SecureCredentialsStorage(
    this._storage,
  );

  @override
  Future<void> clear() {
    _cacheCredentials = null;
    return _storage.delete(key: _key);
  }

  @override
  Future<Credentials?> read() async {
    if (_cacheCredentials != null) {
      return _cacheCredentials;
    }
    final json = await _storage.read(key: _key);
    if (json == null) {
      return null;
    }
    try {
      return _cacheCredentials = Credentials.fromJson(json);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> save(Credentials credentials) {
    _cacheCredentials = credentials;
    return _storage.write(key: _key, value: credentials.toJson());
  }
}
