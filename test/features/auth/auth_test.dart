import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/app/app.dart';
import 'package:micro_lending_app/core/network/api_client.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/core/storage/storage_providers.dart';
import 'package:micro_lending_app/features/auth/data/auth_providers.dart';
import 'package:micro_lending_app/features/auth/data/auth_repository_impl.dart';
import 'package:micro_lending_app/features/auth/data/sources/auth_remote_data_source.dart';
import 'package:micro_lending_app/features/auth/domain/login_result.dart';
import 'package:micro_lending_app/features/auth/presentation/controllers/auth_actions.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';
import 'package:micro_lending_app/shared/session/session_state.dart';

import '../../shared/session/session_fakes.dart';

class _NoApi extends Fake implements ApiClient {}

/// Answers every call with [reply] (a body Map, or an error to throw).
class FakeRemote extends AuthRemoteDataSource {
  FakeRemote() : super(_NoApi());
  Object reply = const {};
  final List<String> calls = [];

  Future<dynamic> _answer(String call) async {
    calls.add(call);
    final r = reply;
    if (r is Map) return r;
    throw r;
  }

  @override
  Future<dynamic> loginWithEmail(String email, String password) =>
      _answer('email $email');
  @override
  Future<dynamic> loginWithPhone(String phone, String otp, String purpose) =>
      _answer('phone $phone');
  @override
  Future<dynamic> register(Map<String, dynamic> body) => _answer('register');
  @override
  Future<dynamic> logout(String refreshToken) =>
      _answer('logout $refreshToken');
}

Map<String, dynamic> signedInBody({bool? verified, bool? active}) => {
  'success': true,
  'data': {
    'is_verified': ?verified,
    'is_active': ?active,
    'tokens': {'access_token': 'a1', 'refresh_token': 'r1'},
    'admin': {'id': 'u1', 'user_name': 'Dharun', 'role': 'ADMIN'},
  },
};

void main() {
  late FakeRemote remote;
  late AuthRepositoryImpl repo;

  setUp(() {
    remote = FakeRemote();
    repo = AuthRepositoryImpl(remote);
  });

  group('AuthRepositoryImpl login', () {
    Future<LoginResult> login() =>
        repo.loginWithEmail(email: 'd@x.in', password: 'pw');

    test('a good answer carries tokens and the user', () async {
      remote.reply = signedInBody();
      final r = await login() as LoginSucceeded;
      expect(r.refreshToken, 'r1');
      expect(r.user.userName, 'Dharun');
    });

    test('account flags win over tokens', () async {
      remote.reply = signedInBody(verified: false);
      expect(await login(), isA<LoginPendingApproval>());
      remote.reply = signedInBody(active: false);
      expect(await login(), isA<LoginDeactivated>());
    });

    test('403s for pending or deactivated accounts are results', () async {
      remote.reply = const ApiException(
        message: 'x',
        statusCode: 403,
        code: 'ACCOUNT_PENDING_APPROVAL',
      );
      expect(await login(), isA<LoginPendingApproval>());
      remote.reply = const ApiException(
        message: 'Account deactivated',
        statusCode: 403,
      );
      expect(await login(), isA<LoginDeactivated>());
    });

    test('other failures and broken answers are errors', () async {
      remote.reply = const ApiException(
        message: 'wrong password',
        statusCode: 401,
      );
      await expectLater(login(), throwsA(isA<ApiException>()));
      remote.reply = {
        'success': true,
        'data': {'tokens': {}},
      };
      await expectLater(
        login(),
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', 'BAD_RESPONSE'),
        ),
      );
    });
  });

  group('AuthActions', () {
    late FakeTokenStorage tokens;
    late FakeSessionStorage profile;
    late ProviderContainer c;

    setUp(() {
      tokens = FakeTokenStorage();
      profile = FakeSessionStorage();
      c = ProviderContainer.test(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          tokenStorageProvider.overrideWithValue(tokens),
          sessionStorageProvider.overrideWithValue(profile),
        ],
      );
    });

    AuthActions actions() => c.read(authActionsProvider);

    test('a login stores tokens and the user, then signs in', () async {
      remote.reply = signedInBody();
      await actions().loginWithPhone(
        phoneNumber: '+91',
        optCode: '123456',
        purpose: 'LOGIN',
      );
      expect(tokens.access, 'a1');
      expect(profile.saved?.userName, 'Dharun');
      expect(c.read(sessionProvider).status, AuthStatus.signedIn);
    });

    test('a pending account stores nothing and waits for approval', () async {
      remote.reply = signedInBody(verified: false);
      await actions().loginWithEmail(email: 'd@x.in', password: 'pw');
      expect(tokens.access, isNull);
      expect(c.read(sessionProvider).isPendingApproval, true);
    });

    test('registering waits for approval', () async {
      remote.reply = {
        'success': true,
        'data': {
          'admin': {
            'id': 'u2',
            'user_name': 'New',
            'phone_number': '+91',
            'role': 'ADMIN',
            'is_verified': false,
            'is_active': true,
            'default_upfront_fee_percentage': 10,
            'default_interest_percentage': 20,
            'default_total_months': 3,
            'default_total_weeks': 12,
            'created_at': '2026-11-21T00:00:00Z',
            'updated_at': '2026-11-21T00:00:00Z',
          },
        },
      };
      final r = await actions().register(
        userName: 'New',
        phoneNumber: '+91',
        password: 'pw',
        defaultUpfrontFeePercentage: 10,
        defaultInterestPercentage: 20,
        defaultTotalMonths: 3,
      );
      expect(r?.userName, 'New');
      expect(c.read(sessionProvider).isPendingApproval, true);
    });

    test('logout signs out locally even when the server call fails', () async {
      tokens.refresh = 'r9';
      c.read(sessionProvider.notifier).signedIn();
      remote.reply = const ApiException(message: 'offline');
      await actions().logout();
      expect(remote.calls, ['logout r9']);
      expect(tokens.cleared, true);
      expect(c.read(sessionProvider).status, AuthStatus.signedOut);
    });
  });

  testWidgets('signing in from the email screen follows the router', (
    tester,
  ) async {
    remote.reply = signedInBody(verified: false); // lands on "pending"
    final c = ProviderContainer.test(
      overrides: [
        authRemoteDataSourceProvider.overrideWithValue(remote),
        tokenStorageProvider.overrideWithValue(FakeTokenStorage()),
        sessionStorageProvider.overrideWithValue(FakeSessionStorage()),
      ],
    );
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    c.read(sessionProvider.notifier).signedOut(); // as restore() would
    await tester.pumpWidget(
      UncontrolledProviderScope(container: c, child: const App()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Email & Password')); // anywhere on the card
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'dharun@example.com');
    await tester.enterText(
      fields.at(1),
      'secret1' /* older, weaker password */,
    );
    await tester.tap(find.text('SIGN IN'));
    await tester.pumpAndSettle();

    expect(remote.calls, ['email dharun@example.com']);
    expect(find.text('Approval Pending'), findsOneWidget);
  });
}
