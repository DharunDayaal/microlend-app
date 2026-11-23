import 'package:micro_lending_app/core/pagination/paged_result.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/core/storage/storage_providers.dart';
import 'package:micro_lending_app/features/exports/data/dtos/export_dto.dart';
import 'package:micro_lending_app/features/exports/data/export_providers.dart';
import 'package:micro_lending_app/features/exports/domain/entities/export.dart';
import 'package:micro_lending_app/features/exports/domain/export_files.dart';
import 'package:micro_lending_app/features/exports/domain/export_repository.dart';
import 'package:micro_lending_app/features/exports/presentation/controllers/exports_controller.dart';
import 'package:micro_lending_app/features/exports/presentation/screens/downloads_screen.dart';
import 'package:micro_lending_app/features/exports/presentation/widgets/export_sheet.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/shared/design_system/theme/theme.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';

import '../../shared/session/session_fakes.dart';

ExportJob job(
  String id, {
  String status = 'running',
  String? url,
  String? expiresAt,
}) => ExportJobDto.fromJson({
  'id': id,
  'type': 'loans_register',
  'format': 'xlsx',
  'status': status,
  'created_at': '2026-11-20T10:00:00Z',
  'download_url': ?url,
  'expires_at': ?expiresAt,
});

class FakeExportRepository implements ExportRepository {
  /// What GET /exports/:id answers next, per job (last one repeats).
  final Map<String, List<Object>> answers = {};
  List<ExportJob> listed = [];
  int gets = 0;

  @override
  Future<ExportJob> get(String id) async {
    gets++;
    final q = answers[id]!;
    final a = q.length > 1 ? q.removeAt(0) : q.first;
    if (a is ExportJob) return a;
    throw a;
  }

  @override
  Future<ExportCreated> create({
    required ExportType type,
    required ExportFormat format,
    required Map<String, dynamic> filters,
  }) async => ExportCreated(job('j1'), false);

  @override
  Future<PagedResult<ExportJob>> list({int page = 1, int limit = 20}) async =>
      PagedResult(items: listed, page: page, hasNextPage: false);
}

class FakeExportFiles implements ExportFiles {
  int downloads = 0;
  ApiException? fail;
  Completer<void>? gate;
  final Set<String> present = {};
  final List<String> actions = [];

  @override
  Future<String> download(
    String url,
    String fileName, {
    void Function(double? progress)? onProgress,
  }) async {
    downloads++;
    onProgress?.call(0.5);
    if (gate != null) await gate!.future;
    if (fail != null) throw fail!;
    final path = '/tmp/$fileName';
    present.add(path);
    return path;
  }

  @override
  bool exists(String path) => present.contains(path);
  @override
  Future<void> open(String path) async => actions.add('open $path');
  @override
  Future<void> share(String path) async => actions.add('share $path');
}

void main() {
  late FakeExportRepository repo;
  late FakeExportFiles files;
  late ProviderContainer c;

  setUp(() {
    repo = FakeExportRepository();
    files = FakeExportFiles();
    c = ProviderContainer.test(
      overrides: [
        exportRepositoryProvider.overrideWithValue(repo),
        exportFilesProvider.overrideWithValue(files),
        tokenStorageProvider.overrideWithValue(FakeTokenStorage()),
        sessionStorageProvider.overrideWithValue(FakeSessionStorage()),
      ],
    );
    c.listen(exportsProvider, (_, _) {});
  });

  ExportsController ctrl() => c.read(exportsProvider.notifier);
  final done = job('j1', status: 'done', url: 'https://files/x.xlsx');

  testWidgets('a started job is polled until it is done', (tester) async {
    repo.answers['j1'] = [job('j1'), done];
    await ctrl().start(
      type: ExportType.loansRegister,
      format: ExportFormat.xlsx,
      filters: const {},
    );
    expect(ctrl().activeCount, 1);

    await tester.pump(const Duration(seconds: 2)); // still running
    expect(ctrl().activeCount, 1);
    await tester.pump(const Duration(seconds: 2)); // done
    expect(ctrl().activeCount, 0);
    expect(ctrl().job('j1')?.isReady, true);

    final calls = repo.gets;
    await tester.pump(const Duration(seconds: 10));
    expect(repo.gets, calls); // no more polling once done
  });

  testWidgets('a job the server no longer has is dropped', (tester) async {
    repo.answers['j1'] = [const ApiException(message: 'Export not found')];
    await ctrl().start(
      type: ExportType.loansRegister,
      format: ExportFormat.xlsx,
      filters: const {},
    );
    await tester.pump(const Duration(seconds: 2));
    expect(ctrl().job('j1'), isNull);
  });

  testWidgets('polling gives up after repeated failures', (tester) async {
    repo.answers['j1'] = [const ApiException(message: 'offline')];
    await ctrl().start(
      type: ExportType.loansRegister,
      format: ExportFormat.xlsx,
      filters: const {},
    );
    await tester.pump(const Duration(minutes: 2));
    expect(repo.gets, 6);
    expect(ctrl().activeCount, 1); // still shown as building
  });

  test(
    'refreshing keeps jobs still building that the list does not have yet',
    () async {
      repo.answers['j1'] = [job('j1')];
      await ctrl().start(
        type: ExportType.loansRegister,
        format: ExportFormat.xlsx,
        filters: const {},
      );
      repo.listed = [job('j0', status: 'done')];
      await ctrl().refreshList();
      expect(ctrl().jobs.map((j) => j.id).toSet(), {'j0', 'j1'});
      expect(ctrl().listLoaded, true);
      expect(ctrl().listLoading, false);
      ctrl().clear(); // stop the timer this test started
    },
  );

  group('download', () {
    test('an expired or unfinished file explains why, translated', () async {
      repo.answers['j1'] = [
        job('j1', status: 'done', url: 'u', expiresAt: '2000-01-01T00:00:00Z'),
      ];
      await expectLater(
        ctrl().download(done),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'This file has expired. Create it again.',
          ),
        ),
      );

      repo.answers['j1'] = [job('j1')];
      await expectLater(
        ctrl().download(done),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'NOT_READY')),
      );
      expect(files.downloads, 0);
      expect(ctrl().downloading, isEmpty);
    });

    test('a failed save is reported in the app language', () async {
      repo.answers['j1'] = [done];
      files.fail = const ApiException(message: 'x', code: 'DOWNLOAD_EMPTY');
      await expectLater(
        ctrl().download(done),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'The downloaded file is empty. Try again.',
          ),
        ),
      );
    });

    test('parallel taps share one download, then the file is reused', () async {
      repo.answers['j1'] = [done];
      files.gate = Completer();
      final a = ctrl().download(done);
      final b = ctrl().download(done);
      await Future<void>.delayed(Duration.zero);
      expect(ctrl().downloading['j1'], 0.5); // progress shows while saving
      files.gate!.complete();
      expect(await a, await b);
      expect(files.downloads, 1);
      expect(ctrl().downloading, isEmpty);

      await ctrl().use(done, share: true);
      await ctrl().use(done, share: false);
      expect(files.downloads, 1); // already on the phone
      expect(files.actions, [
        'share /tmp/export_j1.xlsx',
        'open /tmp/export_j1.xlsx',
      ]);
    });
  });

  test('signing out wipes every job and file', () async {
    repo.answers['j1'] = [done];
    final ctl = c.read(sessionProvider.notifier)..signedIn();
    await ctrl().start(
      type: ExportType.loansRegister,
      format: ExportFormat.xlsx,
      filters: const {},
    );
    await ctrl().download(done);
    expect(ctrl().files, isNotEmpty);

    ctl.signedOut();
    await Future<void>.delayed(Duration.zero);
    expect(ctrl().jobs, isEmpty);
    expect(ctrl().files, isEmpty);
  });

  testWidgets('Downloads lists the jobs from the server', (tester) async {
    repo.listed = [done];
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DownloadsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Loans register'), findsOneWidget);
    expect(find.text('READY'), findsOneWidget);
  });

  // Regression: initState picked the default range through localized
  // labels, which throws before the first build.
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('the export sheet opens with a default range ($locale)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: ExportSheet(
                type: ExportType.collections,
                preset: ExportPreset(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final l = lookupAppLocalizations(locale);
      final chip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, l.rangeLast30),
      );
      expect(chip.selected, true); // the default for a required range
    });
  }
}
