import 'dart:io';

import 'package:dio/dio.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/features/exports/domain/export_files.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// [ExportFiles] on a real phone: temp folder, open_filex, share sheet.
class DeviceExportFiles implements ExportFiles {
  DeviceExportFiles();

  // No auth interceptor on purpose: the signed link must not carry our token.
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(minutes: 3),
    ),
  );

  static String _safe(String n) =>
      n.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');

  @override
  Future<String> download(
    String url,
    String fileName, {
    void Function(double? progress)? onProgress,
  }) async {
    final dir = Directory('${(await getTemporaryDirectory()).path}/exports');
    await dir.create(recursive: true);
    final path = '${dir.path}/${_safe(fileName)}';

    try {
      await _dio.download(
        url,
        path,
        onReceiveProgress: (received, total) =>
            onProgress?.call(total > 0 ? received / total : null),
      );
    } on DioException {
      throw const ApiException(
        message:
            'The download did not finish. Check your connection and try again.',
        code: 'DOWNLOAD_FAILED',
      );
    }

    final f = File(path);
    if (!await f.exists() || await f.length() == 0) {
      throw const ApiException(
        message: 'The downloaded file is empty. Try again.',
        code: 'DOWNLOAD_EMPTY',
      );
    }
    return path;
  }

  @override
  bool exists(String path) => File(path).existsSync();

  @override
  Future<void> open(String path) async {
    final r = await OpenFilex.open(path);
    if (r.type != ResultType.done) await share(path); // no app for this type
  }

  @override
  Future<void> share(String path) =>
      SharePlus.instance.share(ShareParams(files: [XFile(path)]));
}
