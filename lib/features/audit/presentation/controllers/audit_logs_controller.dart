import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/logging/app_logger.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/features/audit/data/audit_providers.dart';
import 'package:micro_lending_app/features/audit/domain/audit_error.dart';
import 'package:micro_lending_app/features/audit/domain/entities/audit_log.dart';
import 'package:micro_lending_app/features/audit/presentation/audit_filters.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/l10n/locale_controller.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';

@immutable
class AuditLogsState {
  final List<AuditLog> items;
  final int total;
  final bool hasNext;
  final bool loading;

  /// A pull to refresh: the list stays on screen while it reloads.
  final bool silent;
  final bool loadingMore;
  final bool forbidden;

  /// Full-page error, only when there is nothing to show.
  final String? error;

  /// A 400 or a failed reload: the last good list stays, with this banner.
  final String? notice;
  final String? moreError;

  /// Bumped when a filter changes, so the screen can jump back to the top.
  final int filterVersion;

  const AuditLogsState({
    this.items = const [],
    this.total = 0,
    this.hasNext = false,
    this.loading = true,
    this.silent = false,
    this.loadingMore = false,
    this.forbidden = false,
    this.error,
    this.notice,
    this.moreError,
    this.filterVersion = 0,
  });

  static const _keep = Object();

  AuditLogsState copyWith({
    List<AuditLog>? items,
    int? total,
    bool? hasNext,
    bool? loading,
    bool? silent,
    bool? loadingMore,
    bool? forbidden,
    Object? error = _keep,
    Object? notice = _keep,
    Object? moreError = _keep,
    int? filterVersion,
  }) {
    String? pick(Object? v, String? current) =>
        identical(v, _keep) ? current : v as String?;
    return AuditLogsState(
      items: items ?? this.items,
      total: total ?? this.total,
      hasNext: hasNext ?? this.hasNext,
      loading: loading ?? this.loading,
      silent: silent ?? this.silent,
      loadingMore: loadingMore ?? this.loadingMore,
      forbidden: forbidden ?? this.forbidden,
      error: pick(error, this.error),
      notice: pick(notice, this.notice),
      moreError: pick(moreError, this.moreError),
      filterVersion: filterVersion ?? this.filterVersion,
    );
  }
}

/// The audit log list, or one record's History (keyed by its [AuditScope]).
final auditLogsProvider = NotifierProvider.autoDispose
    .family<AuditLogsController, AuditLogsState, AuditScope?>(
      AuditLogsController.new,
    );

class AuditLogsController extends Notifier<AuditLogsState> {
  final AuditScope? scope;
  AuditLogsController(this.scope);

  /// The screen's filter form. Every change reloads page 1.
  late AuditFilters filters;

  int _page = 1;
  int _req = 0; // a slow answer from an older request is ignored

  @override
  AuditLogsState build() {
    filters = AuditFilters(scope: scope);
    void onFilters() {
      state = state.copyWith(filterVersion: state.filterVersion + 1);
      load();
    }

    filters.addListener(onFilters);
    ref.onDispose(() {
      filters.removeListener(onFilters);
      filters.dispose();
    });
    Future.microtask(load);
    return const AuditLogsState();
  }

  // ---------- read access for the screen ----------

  List<AuditLog> get items => state.items;
  int get total => state.total;
  bool get hasNext => state.hasNext;
  bool get loading => state.loading;
  bool get silent => state.silent;
  bool get loadingMore => state.loadingMore;
  bool get forbidden => state.forbidden;
  String? get error => state.error;
  String? get notice => state.notice;
  String? get moreError => state.moreError;

  String get _somethingWrong =>
      lookupAppLocalizations(ref.read(localeProvider)).commonSomethingWrong;

  Map<String, dynamic> _query(int page) =>
      filters.query(page, isSuper: ref.read(sessionProvider).isSuperAdmin);

  Future<void> load({bool pull = false}) async {
    final id = ++_req;
    state = state.copyWith(
      loading: true,
      silent: pull,
      error: null,
      notice: null,
      moreError: null,
      loadingMore: false,
    );

    try {
      final p = await ref.read(auditRepositoryProvider).list(_query(1));
      if (!ref.mounted || id != _req) return;
      _page = 1;
      state = state.copyWith(
        items: List.unmodifiable(p.logs),
        hasNext: p.hasNext,
        total: p.total,
        forbidden: false,
        loading: false,
        silent: false,
      );
    } on ApiException catch (e) {
      if (!ref.mounted || id != _req) return;
      state = switch (classifyAudit(e)) {
        AuditErrorKind.forbidden => state.copyWith(forbidden: true),
        AuditErrorKind.badRequest => state.copyWith(notice: e.message),
        _ =>
          state.items.isEmpty
              ? state.copyWith(error: e.message)
              : state.copyWith(notice: e.message),
      }.copyWith(loading: false, silent: false);
    } catch (e, st) {
      AppLogger.error('Audit list failed', tag: 'Audit', error: e, stack: st);
      if (!ref.mounted || id != _req) return;
      state =
          (state.items.isEmpty
                  ? state.copyWith(error: _somethingWrong)
                  : state.copyWith(notice: _somethingWrong))
              .copyWith(loading: false, silent: false);
    }
  }

  Future<void> loadMore() async {
    final s = state;
    if (s.loading || s.loadingMore || !s.hasNext || s.moreError != null) {
      return;
    }
    final id = _req;
    state = s.copyWith(loadingMore: true);

    try {
      final p = await ref.read(auditRepositoryProvider).list(_query(_page + 1));
      if (!ref.mounted || id != _req) return;
      final have = state.items
          .map((l) => l.id)
          .toSet(); // rows shift while scrolling
      _page += 1;
      state = state.copyWith(
        items: List.unmodifiable([
          ...state.items,
          ...p.logs.where((l) => !have.contains(l.id)),
        ]),
        hasNext: p.hasNext,
        loadingMore: false,
      );
    } on ApiException catch (e) {
      if (!ref.mounted || id != _req) return;
      state = state.copyWith(moreError: e.message, loadingMore: false);
    }
  }

  void retryMore() {
    state = state.copyWith(moreError: null);
    unawaited(loadMore());
  }
}
