import 'package:flutter/foundation.dart';
import 'package:micro_lending_app/data/models/audit_model.dart';
import 'package:micro_lending_app/data/services/audit_service.dart';
import 'package:micro_lending_app/features/audit/audit_filters.dart';
import 'package:micro_lending_app/utils/loggers/app_logger.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';
import 'package:micro_lending_app/utils/session/current_user.dart';

class AuditController extends ChangeNotifier {
  AuditController(this.filters) {
    filters.addListener(_onFilters);
  }

  final AuditFilters filters;
  final items = <AuditLog>[];

  int total = 0;
  bool hasNext = false;
  bool loading = true;
  bool silent = false; // a pull to refresh keeps the list on screen
  bool loadingMore = false;
  bool forbidden = false;
  String? error; // full-page error, only when there is nothing to show
  String? notice; // 400 or a failed reload: the last good list stays
  String? moreError;

  int _page = 1;
  int _req = 0; // a slow answer from an older request is ignored
  bool _disposed = false;

  void _onFilters() => load();

  @override
  void dispose() {
    _disposed = true;
    filters.removeListener(_onFilters);
    super.dispose();
  }

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load({bool pull = false}) async {
    final id = ++_req;
    loading = true;
    silent = pull;
    error = null;
    notice = null;
    moreError = null;
    loadingMore = false;
    _emit();

    try {
      final p = await AuditService.list(
        filters.query(1, isSuper: CurrentUser.instance.isSuperAdmin),
      );
      if (id != _req) return;
      items
        ..clear()
        ..addAll(p.logs);
      hasNext = p.hasNext;
      total = p.total;
      _page = 1;
      forbidden = false;
    } on ApiException catch (e) {
      if (id != _req) return;
      switch (classifyAudit(e)) {
        case AuditErrorKind.forbidden:
          forbidden = true;
        case AuditErrorKind.badRequest:
          notice = e.message; // keep the last good list
        default:
          if (items.isEmpty) {
            error = e.message;
          } else {
            notice = e.message;
          }
      }
    } catch (e, st) {
      AppLogger.error('Audit list failed', tag: 'Audit', error: e, stack: st);
      if (id == _req) {
        if (items.isEmpty) {
          error = 'Something went wrong. Please try again.';
        } else {
          notice = 'Something went wrong. Please try again.';
        }
      }
    } finally {
      if (id == _req) {
        loading = false;
        silent = false;
        _emit();
      }
    }
  }

  Future<void> loadMore() async {
    if (loading || loadingMore || !hasNext || moreError != null) return;
    final id = _req;
    loadingMore = true;
    _emit();

    try {
      final p = await AuditService.list(
        filters.query(_page + 1, isSuper: CurrentUser.instance.isSuperAdmin),
      );
      if (id != _req) return;
      final have = items.map((l) => l.id).toSet(); // rows shift while scrolling
      items.addAll(p.logs.where((l) => !have.contains(l.id)));
      hasNext = p.hasNext;
      _page += 1;
    } on ApiException catch (e) {
      if (id == _req) moreError = e.message;
    } finally {
      if (id == _req) {
        loadingMore = false;
        _emit();
      }
    }
  }

  void retryMore() {
    moreError = null;
    loadMore();
  }
}
