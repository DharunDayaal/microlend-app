import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/features/exports/data/export_folder.dart';
import 'package:micro_lending_app/features/exports/domain/export_files.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// [ExportFiles] on a real phone. Files are saved to
/// `Lending Docs/<day>/` ([ExportFolder]), then opened or shared.
class DeviceExportFiles implements ExportFiles {
  /// [baseDir] and [now] are for tests.
  DeviceExportFiles({
    Future<String> Function()? baseDir,
    DateTime Function()? now,
  }) : _baseOverride = baseDir,
       _now = now ?? DateTime.now;

  final Future<String> Function()? _baseOverride;
  final DateTime Function() _now;

  /// Native side: android/app/src/main/kotlin/.../MainActivity.kt
  static const _storage = MethodChannel('thavanai/storage');

  // No auth interceptor on purpose: the signed link must not carry our token.
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(minutes: 3),
    ),
  );

  /// Download (Android) or Documents (iOS and others).
  Future<String> _base() async {
    final override = _baseOverride;
    if (override != null) return override();
    if (Platform.isAndroid) {
      final ok = await _storage.invokeMethod<bool>('ensureWriteAccess');
      if (ok != true) {
        throw const ApiException(
          message: 'Storage permission is needed to save files.',
          code: 'STORAGE_DENIED',
        );
      }
      final dir = await _storage.invokeMethod<String>('downloadsDir');
      if (dir != null && dir.isNotEmpty) return dir;
    }
    return (await getApplicationDocumentsDirectory()).path;
  }

  @override
  Future<String> download(
    String url,
    String fileName, {
    void Function(double? progress)? onProgress,
  }) async {
    final dir = Directory(ExportFolder.dayPath(await _base(), _now()));
    await dir.create(recursive: true);
    final path = ExportFolder.uniquePath(
      dir.path,
      ExportFolder.safeName(fileName),
    );

    // written under a temporary name, so a half-finished download never
    // shows up in Lending Docs as a real file
    final part = File('$path.part');
    try {
      await _dio.download(
        url,
        part.path,
        onReceiveProgress: (received, total) =>
            onProgress?.call(total > 0 ? received / total : null),
      );
    } on DioException {
      await _delete(part);
      throw const ApiException(
        message:
            'The download did not finish. Check your connection and try again.',
        code: 'DOWNLOAD_FAILED',
      );
    }

    if (!await part.exists() || await part.length() == 0) {
      await _delete(part);
      throw const ApiException(
        message: 'The downloaded file is empty. Try again.',
        code: 'DOWNLOAD_EMPTY',
      );
    }
    await part.rename(path);

    if (Platform.isAndroid && _baseOverride == null) {
      try {
        await _storage.invokeMethod<void>('scan', {'path': path});
      } on PlatformException {
        // only affects how fast it appears in the Files app
      }
    }
    return path;
  }

  static Future<void> _delete(File f) async {
    try {
      if (await f.exists()) await f.delete();
    } on FileSystemException {
      // nothing to clean up
    }
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
