import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/features/audit/data/audit_providers.dart';
import 'package:micro_lending_app/features/audit/data/dtos/audit_dto.dart';
import 'package:micro_lending_app/features/audit/domain/audit_error.dart';
import 'package:micro_lending_app/features/audit/domain/audit_repository.dart';
import 'package:micro_lending_app/features/audit/domain/entities/audit_log.dart';
import 'package:micro_lending_app/features/audit/presentation/audit_filters.dart';
import 'package:micro_lending_app/features/audit/presentation/controllers/audit_logs_controller.dart';
import 'package:micro_lending_app/features/audit/presentation/screens/audit_details.dart';
import 'package:micro_lending_app/features/audit/presentation/screens/audit_logs.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/shared/design_system/theme/theme.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';
import 'package:micro_lending_app/shared/session/session_state.dart';

import '../../shared/session/session_fakes.dart';
import '../loans/fakes.dart' show settle;

AuditLog log(String id, {String action = 'LOAN_CREATED'}) =>
    AuditLogDto.fromJson({
      'id': id,
      'created_at': '2026-11-20T10:00:00Z',
      'action': action,
      'module': 'LOAN',
      'entity_type': 'LOAN',
      'entity_id': 'l1',
      'actor': {'id': 'u1', 'name': 'Dharun', 'role': 'ADMIN'},
    });

/// Answers queued results in order; each is an [AuditPage] or an error.
class FakeAuditRepository implements AuditRepository {
  final Queue<Object> answers = Queue();
  final List<Map<String, dynamic>> queries = [];

  @override
  Future<AuditPage> list(Map<String, dynamic> query) async {
    queries.add(query);
    final a = answers.removeFirst();
    if (a is AuditPage) return a;
    throw a;
  }

  @override
  Future<AuditLog> get(String id) async => log(id);

  @override
  Future<List<AuditActionOption>> actions({
    String? module,
    String? adminId,
  }) async => const [];
}

class _SignedIn extends SessionController {
  final String role;
  _SignedIn(this.role);
  @override
  SessionState build() => SessionState(
    status: AuthStatus.signedIn,
    user: adminUser(role: role),
  );
}

void main() {
  group('classifyAudit', () {
    test('maps status codes and network errors', () {
      expect(
        classifyAudit(const ApiException(message: 'x', statusCode: 403)),
        AuditErrorKind.forbidden,
      );
      expect(
        classifyAudit(const ApiException(message: 'x', statusCode: 404)),
        AuditErrorKind.notFound,
      );
      expect(
        classifyAudit(const ApiException(message: 'x', statusCode: 400)),
        AuditErrorKind.badRequest,
      );
      expect(
        classifyAudit(const ApiException(message: 'offline')),
        AuditErrorKind.network,
      );
    });
  });

  group('AuditLogsController', () {
    late FakeAuditRepository repo;
    late ProviderContainer c;
    final all = auditLogsProvider(null);

    setUp(() {
      repo = FakeAuditRepository();
      c = ProviderContainer.test(
        overrides: [
          auditRepositoryProvider.overrideWithValue(repo),
          sessionProvider.overrideWith(() => _SignedIn('ADMIN')),
        ],
      );
    });

    Future<void> start([AuditScope? scope]) async {
      c.listen(auditLogsProvider(scope), (_, _) {});
      await settle();
    }

    test('loads the first page with its total', () async {
      repo.answers.add(AuditPage([log('1'), log('2')], true, 40));
      await start();
      final s = c.read(all);
      expect(s.items.length, 2);
      expect(s.total, 40);
      expect(s.loading, false);
    });

    test(
      'a filter change reloads and asks the screen to jump to the top',
      () async {
        repo.answers
          ..add(AuditPage([log('1')], false, 1))
          ..add(AuditPage([log('3')], false, 1));
        await start();
        c.read(all.notifier).filters.setModule('LOAN');
        await settle();
        expect(c.read(all).items.single.id, '3');
        expect(c.read(all).filterVersion, 1);
        expect(repo.queries.last['module'], 'LOAN');
      },
    );

    test('a History scope narrows the query', () async {
      const scope = AuditScope(entityType: 'LOAN', entityId: 'l9');
      repo.answers.add(AuditPage(const [], false, 0));
      await start(scope);
      expect(repo.queries.single['entity_id'], 'l9');
      // equal scopes share one list
      expect(
        identical(
          c.read(auditLogsProvider(scope).notifier),
          c.read(
            auditLogsProvider(
              const AuditScope(entityType: 'LOAN', entityId: 'l9'),
            ).notifier,
          ),
        ),
        true,
      );
    });

    test('forbidden hides the list', () async {
      repo.answers.add(const ApiException(message: 'no', statusCode: 403));
      await start();
      expect(c.read(all).forbidden, true);
    });

    test(
      'a bad request or failed reload keeps the list with a notice',
      () async {
        repo.answers
          ..add(AuditPage([log('1')], false, 1))
          ..add(const ApiException(message: 'bad range', statusCode: 400))
          ..add(const ApiException(message: 'offline'));
        await start();

        await c.read(all.notifier).load();
        expect(c.read(all).notice, 'bad range');
        expect(c.read(all).items.length, 1);

        await c.read(all.notifier).load(pull: true);
        expect(c.read(all).notice, 'offline');
        expect(c.read(all).error, isNull);
        expect(c.read(all).silent, false);
      },
    );

    test(
      'a first-load failure shows the error page; a bug is translated',
      () async {
        repo.answers.add(const ApiException(message: 'offline'));
        await start();
        expect(c.read(all).error, 'offline');

        repo.answers.add(StateError('bad data'));
        await c.read(all.notifier).load();
        expect(c.read(all).error, 'Something went wrong. Please try again.');
      },
    );

    test('the next page drops rows already shown', () async {
      repo.answers
        ..add(AuditPage([log('1'), log('2')], true, 3))
        ..add(AuditPage([log('2'), log('3')], false, 3));
      await start();
      await c.read(all.notifier).loadMore();
      expect(c.read(all).items.map((l) => l.id), ['1', '2', '3']);
      expect(repo.queries.last['page'], 2);
    });
  });

  group('screens', () {
    Widget app(Widget screen, FakeAuditRepository repo) => ProviderScope(
      overrides: [
        auditRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWith(() => _SignedIn('ADMIN')),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: screen,
      ),
    );

    testWidgets('audit log lists entries', (tester) async {
      final repo = FakeAuditRepository()
        ..answers.add(AuditPage([log('1')], false, 1));
      await tester.pumpWidget(app(const AuditListScreen(), repo));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Dharun'), findsWidgets);
      expect(find.text('1 of 1 entries'), findsOneWidget);
    });

    testWidgets('audit entry loads and shows the change', (tester) async {
      await tester.pumpWidget(
        app(const AuditDetailScreen(id: '1'), FakeAuditRepository()),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Audit entry'), findsOneWidget);
      expect(find.textContaining('Dharun'), findsWidgets);
    });
  });
}
