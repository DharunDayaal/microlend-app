import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:micro_lending_app/data/models/export_model.dart';
import 'package:micro_lending_app/data/services/export_service.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

class ExportsTracker extends ChangeNotifier {
  ExportsTracker._();
  static final ExportsTracker instance = ExportsTracker._();

  final _jobs = <String, ExportJob>{};
  final _timers = <String, Timer>{};
  final _pollStart = <String, DateTime>{};
  final _errors = <String, int>{};
  final _downloads = <String, Future<String>>{};

  /// job id -> local file (this session only).
  final files = <String, String>{};

  /// job id -> download progress (null = unknown).
  final downloading = <String, double?>{};

  bool listLoading = false;
  bool listLoaded = false;
  String? listError;

  int _epoch = 0; // bumped on sign-out so old timers do nothing

  List<ExportJob> get jobs {
    final l = _jobs.values.toList()
      ..sort(
        (a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
      );
    return l;
  }

  int get activeCount => _jobs.values.where((j) => j.isActive).length;

  ExportJob? job(String id) => _jobs[id];

  // ---------- polling ----------

  void _upsert(ExportJob j) {
    _jobs[j.id] = j;
    if (j.isActive) {
      _pollStart.putIfAbsent(j.id, DateTime.now);
      if (!_timers.containsKey(j.id)) _schedule(j.id);
    } else {
      _timers.remove(j.id)?.cancel();
      _pollStart.remove(j.id);
      _errors.remove(j.id);
    }
  }

  void _schedule(String id) {
    final elapsed = DateTime.now().difference(_pollStart[id] ?? DateTime.now());
    final delay = elapsed < const Duration(seconds: 20)
        ? const Duration(seconds: 2)
        : const Duration(seconds: 5);
    final epoch = _epoch;
    _timers[id] = Timer(delay, () => _tick(id, epoch));
  }

  Future<void> _tick(String id, int epoch) async {
    _timers.remove(id);
    if (epoch != _epoch) return;

    try {
      final j = await ExportService.get(id);
      if (epoch != _epoch) return;
      _errors.remove(id);
      _upsert(j);
      notifyListeners();
    } on ApiException catch (e) {
      if (epoch != _epoch) return;
      if (e.message.toLowerCase().contains('not found')) {
        _jobs.remove(id); // gone from the server
        _pollStart.remove(id);
        notifyListeners();
        return;
      }
      final n = (_errors[id] ?? 0) + 1;
      _errors[id] = n;
      if (n < 6) _schedule(id); // a bad connection should not stop the polling
    }
  }

  // ---------- requests ----------

  Future<ExportCreated> start({
    required ExportType type,
    required ExportFormat format,
    required Map<String, dynamic> filters,
  }) async {
    final c = await ExportService.create(
      type: type,
      format: format,
      filters: filters,
    );
    _upsert(c.job);
    notifyListeners();
    return c;
  }

  Future<void> refreshList() async {
    listLoading = true;
    listError = null;
    scheduleMicrotask(notifyListeners);
    final epoch = _epoch;
    try {
      final list = await ExportService.list();
      if (epoch != _epoch) return;

      final keep = _jobs.values.where(
        (j) => j.isActive && !list.any((x) => x.id == j.id),
      );
      _jobs
        ..clear()
        ..addEntries([
          for (final j in [...list, ...keep]) MapEntry(j.id, j),
        ]);
      for (final j in _jobs.values.toList()) {
        _upsert(j);
      }
      listLoaded = true;
    } on ApiException catch (e) {
      if (epoch == _epoch) listError = e.message;
    } finally {
      if (epoch == _epoch) {
        listLoading = false;
        notifyListeners();
      }
    }
  }

  // ---------- files ----------

  Future<String> download(ExportJob job) =>
      _downloads[job.id] ??= _doDownload(job).whenComplete(() {
        _downloads.remove(job.id);
        downloading.remove(job.id);
        notifyListeners();
      });

  Future<String> _doDownload(ExportJob job) async {
    downloading[job.id] = null;
    notifyListeners();

    var last = -1.0;
    final path = await ExportFiles.download(
      job,
      onProgress: (p) {
        // about 1% steps, so the UI is not rebuilt on every chunk
        if (p == null || p - last >= 0.01) {
          last = p ?? last;
          downloading[job.id] = p;
          notifyListeners();
        }
      },
    );
    files[job.id] = path;
    return path;
  }

  /// Downloads (once) and then opens or shares the file.
  Future<void> use(ExportJob job, {required bool share}) async {
    var path = files[job.id];
    if (path == null || !File(path).existsSync()) path = await download(job);
    if (share) {
      await ExportFiles.share(path);
    } else {
      await ExportFiles.open(path);
    }
  }

  /// Sign-out: nothing from this account may stay behind.
  void clear() {
    _epoch++;
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
    _jobs.clear();
    _pollStart.clear();
    _errors.clear();
    _downloads.clear();
    files.clear();
    downloading.clear();
    listLoaded = false;
    listError = null;
    listLoading = false;
    notifyListeners();
  }
}
