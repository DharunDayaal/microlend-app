import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:micro_lending_app/data/models/export_model.dart';
import 'package:micro_lending_app/utils/constants/api_endpoints.dart';
import 'package:micro_lending_app/utils/network/api_client.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';
import 'package:micro_lending_app/utils/network/body_unwrap.dart';

class ExportService {
  ExportService._();
  static final ApiClient _api = ApiClient.instance;

  static ExportJob _job(dynamic res) {
    final v = unwrapBody(res)['export'];
    if (v is! Map) {
      throw const ApiException(
        message: 'Unexpected response from server',
        code: 'BAD_RESPONSE',
      );
    }
    return ExportJob.fromJson(Map<String, dynamic>.from(v));
  }

  static Future<ExportCreated> create({
    required ExportType type,
    required ExportFormat format,
    required Map<String, dynamic> filters,
  }) async {
    final res = await _api.post(
      ApiEndpoints.exports,
      data: {'type': type.spec.api, 'format': format.name, 'filters': filters},
    );
    return ExportCreated(_job(res), unwrapBody(res)['already_running'] == true);
  }

  static Future<ExportJob> get(String id) async =>
      _job(await _api.get(ApiEndpoints.exportById(id)));

  /// The last 20, newest first. Never carries a download link.
  static Future<List<ExportJob>> list() async {
    final v = unwrapBody(await _api.get(ApiEndpoints.exports))['exports'];
    return v is List
        ? [
            for (final e in v)
              if (e is Map) ExportJob.fromJson(Map<String, dynamic>.from(e)),
          ]
        : <ExportJob>[];
  }
}

class ExportFiles {
  ExportFiles._();

  // No auth interceptor on purpose: the signed link must not carry our token.
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(minutes: 3),
    ),
  );

  static String _safe(String n) =>
      n.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');

  /// Asks for a fresh link, then saves the file. Returns the local path.
  static Future<String> download(
    ExportJob job, {
    void Function(double? p)? onProgress,
  }) async {
    final fresh = await ExportService.get(job.id);
    final url = fresh.downloadUrl;

    if (fresh.isExpired) {
      throw const ApiException(
        message: 'This file has expired. Create it again.',
        code: 'EXPIRED',
      );
    }
    if (fresh.status != ExportStatus.done || url == null) {
      throw const ApiException(
        message: 'The file is not ready yet.',
        code: 'NOT_READY',
      );
    }

    final dir = Directory('${(await getTemporaryDirectory()).path}/exports');
    await dir.create(recursive: true);
    final name = _safe(
      fresh.fileName ?? 'export_${job.id}.${fresh.format.ext}',
    );
    final path = '${dir.path}/$name';

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
        code: 'DOWNLOAD_FAILED',
      );
    }
    return path;
  }

  static Future<void> open(String path) async {
    final r = await OpenFilex.open(path);
    if (r.type != ResultType.done) await share(path); // no app for this type
  }

  static Future<void> share(String path) =>
      SharePlus.instance.share(ShareParams(files: [XFile(path)]));
}
