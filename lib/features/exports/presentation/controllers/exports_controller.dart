import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/features/exports/data/export_providers.dart';
import 'package:micro_lending_app/features/exports/domain/entities/export.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/l10n/locale_controller.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';
import 'package:micro_lending_app/shared/session/session_state.dart';

@immutable
class ExportsState {
  final Map<String, ExportJob> jobs;

  /// job id -> local file (this session only).
  final Map<String, String> files;

  /// job id -> download progress (null = unknown). Present while downloading.
  final Map<String, double?> downloading;

  final bool listLoading;
  final bool listLoaded;
  final String? listError;

  const ExportsState({
    this.jobs = const {},
    this.files = const {},
    this.downloading = const {},
    this.listLoading = false,
    this.listLoaded = false,
    this.listError,
  });

  static const _keep = Object();

  ExportsState copyWith({
    Map<String, ExportJob>? jobs,
    Map<String, String>? files,
    Map<String, double?>? downloading,
    bool? listLoading,
    bool? listLoaded,
    Object? listError = _keep,
  }) => ExportsState(
    jobs: jobs ?? this.jobs,
    files: files ?? this.files,
    downloading: downloading ?? this.downloading,
    listLoading: listLoading ?? this.listLoading,
    listLoaded: listLoaded ?? this.listLoaded,
    listError: identical(listError, _keep)
        ? this.listError
        : listError as String?,
  );
}

/// Every export of this session, polled while it builds. App-wide: jobs keep
/// building, and their badge keeps counting, after the sheet is closed.
final exportsProvider = NotifierProvider<ExportsController, ExportsState>(
  ExportsController.new,
);

class ExportsController extends Notifier<ExportsState> {
  final _timers = <String, Timer>{};
  final _pollStart = <String, DateTime>{};
  final _errors = <String, int>{};
  final _downloads = <String, Future<String>>{};

  int _epoch = 0; // bumped on sign-out so old timers do nothing

  @override
  ExportsState build() {
    // Sign-out: nothing from this account may stay behind.
    ref.listen(sessionProvider.select((s) => s.status), (_, next) {
      if (next == AuthStatus.signedOut) clear();
    });
    ref.onDispose(_cancelTimers);
    return const ExportsState();
  }

  // ---------- read access for the screens ----------

  List<ExportJob> get jobs => state.jobs.values.toList()
    ..sort(
      (a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
    );

  int get activeCount => state.jobs.values.where((j) => j.isActive).length;
  ExportJob? job(String id) => state.jobs[id];
  Map<String, String> get files => state.files;
  Map<String, double?> get downloading => state.downloading;
  bool get listLoading => state.listLoading;
  bool get listLoaded => state.listLoaded;
  String? get listError => state.listError;

  AppLocalizations get _l => lookupAppLocalizations(ref.read(localeProvider));

  // ---------- polling ----------

  /// Puts [j] in the jobs map and starts or stops polling for it.
  Map<String, ExportJob> _upsert(Map<String, ExportJob> jobs, ExportJob j) {
    final next = {...jobs, j.id: j};
    if (j.isActive) {
      _pollStart.putIfAbsent(j.id, DateTime.now);
      if (!_timers.containsKey(j.id)) _schedule(j.id);
    } else {
      _timers.remove(j.id)?.cancel();
      _pollStart.remove(j.id);
      _errors.remove(j.id);
    }
    return next;
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
    if (epoch != _epoch || !ref.mounted) return;

    try {
      final j = await ref.read(exportRepositoryProvider).get(id);
      if (epoch != _epoch || !ref.mounted) return;
      _errors.remove(id);
      state = state.copyWith(jobs: _upsert(state.jobs, j));
    } on ApiException catch (e) {
      if (epoch != _epoch || !ref.mounted) return;
      if (e.message.toLowerCase().contains('not found')) {
        _pollStart.remove(id);
        state = state.copyWith(jobs: {...state.jobs}..remove(id)); // gone
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
    final c = await ref
        .read(exportRepositoryProvider)
        .create(type: type, format: format, filters: filters);
    state = state.copyWith(jobs: _upsert(state.jobs, c.job));
    return c;
  }

  Future<void> refreshList() async {
    // deferred: the Downloads screen calls this while it is being built
    scheduleMicrotask(() {
      if (ref.mounted) {
        state = state.copyWith(listLoading: true, listError: null);
      }
    });
    final epoch = _epoch;
    try {
      // the first page (20, newest first), as before
      final list = (await ref.read(exportRepositoryProvider).list()).items;
      if (epoch != _epoch || !ref.mounted) return;

      final keep = state.jobs.values.where(
        (j) => j.isActive && !list.any((x) => x.id == j.id),
      );
      var jobs = <String, ExportJob>{
        for (final j in [...list, ...keep]) j.id: j,
      };
      for (final j in jobs.values.toList()) {
        jobs = _upsert(jobs, j);
      }
      state = state.copyWith(jobs: jobs, listLoaded: true, listLoading: false);
    } on ApiException catch (e) {
      if (epoch == _epoch && ref.mounted) {
        state = state.copyWith(listError: e.message, listLoading: false);
      }
    }
  }

  // ---------- files ----------

  /// Downloads once (parallel calls share the same download).
  Future<String> download(ExportJob job) =>
      _downloads[job.id] ??= _doDownload(job).whenComplete(() {
        _downloads.remove(job.id);
        if (ref.mounted) {
          state = state.copyWith(
            downloading: {...state.downloading}..remove(job.id),
          );
        }
      });

  void _setProgress(String id, double? p) {
    if (!ref.mounted) return;
    state = state.copyWith(downloading: {...state.downloading, id: p});
  }

  Future<String> _doDownload(ExportJob job) async {
    _setProgress(job.id, null);

    // ask for a fresh, signed link: the one in the list may be old or absent
    final fresh = await ref.read(exportRepositoryProvider).get(job.id);
    final url = fresh.downloadUrl;
    if (fresh.isExpired) {
      throw ApiException(message: _l.expDownloadExpired, code: 'EXPIRED');
    }
    if (fresh.status != ExportStatus.done || url == null) {
      throw ApiException(message: _l.expDownloadNotReady, code: 'NOT_READY');
    }

    var last = -1.0;
    final String path;
    try {
      path = await ref
          .read(exportFilesProvider)
          .download(
            url,
            fresh.fileName ?? 'export_${job.id}.${fresh.format.ext}',
            onProgress: (p) {
              // about 1% steps, so the UI is not rebuilt on every chunk
              if (p == null || p - last >= 0.01) {
                last = p ?? last;
                _setProgress(job.id, p);
              }
            },
          );
    } on ApiException catch (e) {
      throw ApiException(
        message: switch (e.code) {
          'DOWNLOAD_EMPTY' => _l.expDownloadEmpty,
          'STORAGE_DENIED' => _l.expStorageDenied,
          _ => _l.expDownloadFailed,
        },
        code: e.code,
      );
    }
    if (ref.mounted) {
      state = state.copyWith(files: {...state.files, job.id: path});
    }
    return path;
  }

  /// Downloads (once) and then opens or shares the file. Returns the
  /// folder it was saved in (`Lending Docs/2026-11-24`) when it was just
  /// downloaded, or null when it was already on the phone.
  Future<String?> use(ExportJob job, {required bool share}) async {
    final files = ref.read(exportFilesProvider);
    var path = state.files[job.id];
    String? savedIn;
    if (path == null || !files.exists(path)) {
      path = await download(job);
      savedIn = folderLabel(path);
    }
    if (share) {
      await files.share(path);
    } else {
      await files.open(path);
    }
    return savedIn;
  }

  /// `…/Lending Docs/2026-11-24/file.pdf` -> `Lending Docs/2026-11-24`.
  static String folderLabel(String path) {
    final parts = path.split(RegExp(r'[/\\]'));
    return parts.length >= 3
        ? '${parts[parts.length - 3]}/${parts[parts.length - 2]}'
        : path;
  }

  void _cancelTimers() {
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
  }

  /// Sign-out: nothing from this account may stay behind.
  void clear() {
    _epoch++;
    _cancelTimers();
    _pollStart.clear();
    _errors.clear();
    _downloads.clear();
    state = const ExportsState();
  }
}
