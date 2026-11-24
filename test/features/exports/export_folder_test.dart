import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/features/exports/data/device_export_files.dart';
import 'package:micro_lending_app/features/exports/data/export_folder.dart';
import 'package:micro_lending_app/features/exports/presentation/controllers/exports_controller.dart';

void main() {
  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('lending_docs_'));
  tearDown(() => tmp.deleteSync(recursive: true));

  group('ExportFolder', () {
    test('one folder per day, named so it sorts by date', () {
      expect(ExportFolder.dayName(DateTime(2026, 3, 7, 23, 59)), '2026-03-07');
      expect(
        ExportFolder.dayPath('/base', DateTime(2026, 11, 24)),
        '/base/Lending Docs/2026-11-24',
      );
      expect(
        ExportFolder.relativeDay(DateTime(2026, 11, 24)),
        'Lending Docs/2026-11-24',
      );
    });

    test('file names are made safe', () {
      expect(
        ExportFolder.safeName('Loans register (Nov).xlsx'),
        'Loans_register__Nov_.xlsx',
      );
      expect(ExportFolder.safeName('../../etc'), 'export.._.._etc');
      expect(ExportFolder.safeName('  '), 'export');
    });

    test('a second file with the same name gets (1), (2)...', () {
      final dir = tmp.path;
      expect(ExportFolder.uniquePath(dir, 'r.pdf'), '$dir/r.pdf');
      File('$dir/r.pdf').writeAsStringSync('x');
      expect(ExportFolder.uniquePath(dir, 'r.pdf'), '$dir/r (1).pdf');
      File('$dir/r (1).pdf').writeAsStringSync('x');
      expect(ExportFolder.uniquePath(dir, 'r.pdf'), '$dir/r (2).pdf');
      expect(ExportFolder.uniquePath(dir, 'noext'), '$dir/noext');
    });

    test('the saved-in label comes from the path', () {
      expect(
        ExportsController.folderLabel(
          '/storage/emulated/0/Download/Lending Docs/2026-11-24/a.pdf',
        ),
        'Lending Docs/2026-11-24',
      );
    });
  });

  group('DeviceExportFiles', () {
    late HttpServer server;
    late String body;
    setUp(() async {
      body = 'loan,amount\nl1,500\n';
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((req) {
        req.response
          ..statusCode = req.uri.path == '/missing' ? 404 : 200
          ..write(req.uri.path == '/empty' ? '' : body);
        req.response.close();
      });
    });
    tearDown(() => server.close(force: true));

    String url(String p) => 'http://127.0.0.1:${server.port}$p';

    DeviceExportFiles files(DateTime day) =>
        DeviceExportFiles(baseDir: () async => tmp.path, now: () => day);

    test('saves into Lending Docs/<day>/ and keeps both days apart', () async {
      final a = await files(DateTime(2026, 11, 24))
          .download(url('/f'), 'r.csv');
      final b = await files(DateTime(2026, 11, 24))
          .download(url('/f'), 'r.csv');
      final c = await files(DateTime(2026, 11, 25))
          .download(url('/f'), 'r.csv');

      expect(a, '${tmp.path}/Lending Docs/2026-11-24/r.csv');
      expect(
        b,
        '${tmp.path}/Lending Docs/2026-11-24/r (1).csv',
      ); // no overwrite
      expect(c, '${tmp.path}/Lending Docs/2026-11-25/r.csv');
      expect(File(a).readAsStringSync(), body);
      // no half-written temp files left behind
      expect(
        Directory('${tmp.path}/Lending Docs')
            .listSync(recursive: true)
            .where((e) => e.path.endsWith('.part')),
        isEmpty,
      );
    });

    test('a failed or empty download leaves nothing in the folder', () async {
      final f = files(DateTime(2026, 11, 24));
      await expectLater(
        f.download(url('/missing'), 'r.csv'),
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', 'DOWNLOAD_FAILED'),
        ),
      );
      await expectLater(
        f.download(url('/empty'), 'r.csv'),
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', 'DOWNLOAD_EMPTY'),
        ),
      );
      final day = Directory('${tmp.path}/Lending Docs/2026-11-24');
      expect(day.listSync(), isEmpty);
    });
  });
}
