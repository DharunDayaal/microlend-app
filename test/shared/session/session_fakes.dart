import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/core/storage/session_storage.dart';
import 'package:micro_lending_app/core/storage/token_storage.dart';
import 'package:micro_lending_app/shared/session/models/user_role.dart';

AdminUser adminUser({String role = 'ADMIN'}) =>
    AdminUser.fromJson({'id': 'u1', 'user_name': 'Dharun', 'role': role});

class FakeTokenStorage extends Fake implements TokenStorage {
  bool hasTokens;
  bool cleared = false;
  String? refresh;
  FakeTokenStorage({this.hasTokens = false, this.refresh});

  @override
  Future<String?> get refreshToken async => refresh;

  String? access;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
    hasTokens = true;
  }

  @override
  Future<bool> get hasSession async => hasTokens;

  @override
  Future<void> clear() async {
    cleared = true;
    hasTokens = false;
  }
}

class FakeSessionStorage extends Fake implements SessionStorage {
  AdminUser? saved;
  bool failSave = false;
  FakeSessionStorage([this.saved]);

  @override
  Future<AdminUser?> read() async => saved;

  @override
  Future<void> save(AdminUser user) async {
    if (failSave) throw Exception('disk full');
    saved = user;
  }

  @override
  Future<void> clear() async => saved = null;
}
