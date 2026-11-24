import 'dart:convert';
import 'dart:io';

import 'package:micro_lending_app/core/logging/app_logger.dart';
import 'package:micro_lending_app/features/loans/domain/entities/pending_payment.dart';
import 'package:micro_lending_app/features/loans/domain/payment_outbox_store.dart';
import 'package:path_provider/path_provider.dart';

/// Keeps the queue in a JSON file in the app's private support folder.
/// Each write goes to a temp file first and is then renamed over the old
/// one, so a crash mid-write never leaves a half-written queue.
class FilePaymentOutboxStore implements PaymentOutboxStore {
  FilePaymentOutboxStore({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _directory;
  static const _name = 'payment_outbox_v1.json';

  Future<File> _file() async => File('${(await _directory()).path}/$_name');

  @override
  Future<List<PendingPayment>> read() async {
    final file = await _file();
    if (!await file.exists()) return [];
    try {
      final list = jsonDecode(await file.readAsString()) as List;
      return [
        for (final e in list)
          PendingPayment.fromJson(e as Map<String, dynamic>),
      ];
    } catch (e, st) {
      // Never delete it: it may be the only record of collected money.
      AppLogger.error('Unreadable payment queue', error: e, stack: st);
      await file.copy('${file.path}.corrupt');
      return [];
    }
  }

  @override
  Future<void> write(List<PendingPayment> payments) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(
      jsonEncode([for (final p in payments) p.toJson()]),
      flush: true,
    );
    await tmp.rename(file.path);
  }
}
