import 'package:flutter/foundation.dart';
import 'package:micro_lending_app/data/models/managed_account.dart';
import 'package:micro_lending_app/utils/loggers/app_logger.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

class ManageController extends ChangeNotifier {
  ManageController({required this.loader});

  final Future<PageOf<ManagedAccount>> Function(
    String status,
    String search,
    int page,
  )
  loader;

  final items = <ManagedAccount>[];
  String status = 'pending';
  String search = '';
  bool hasNext = false;
  bool loading = true;
  bool loadingMore = false;
  String? error;
  String? moreError;

  int _page = 1;
  int _req = 0; // a slow answer from an older request is ignored
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load({bool silent = false}) async {
    final id = ++_req;
    if (!silent) loading = true;
    error = null;
    moreError = null;
    loadingMore = false;
    _emit();

    try {
      final r = await loader(status, search, 1);
      if (id != _req) return;
      items
        ..clear()
        ..addAll(r.items);
      hasNext = r.hasNext;
      _page = 1;
    } on ApiException catch (e) {
      if (id == _req) error = e.message;
    } catch (e, st) {
      AppLogger.error('Manage list failed', tag: 'Manage', error: e, stack: st);
      if (id == _req) error = 'Something went wrong. Please try again.';
    } finally {
      if (id == _req) {
        loading = false;
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
      final r = await loader(status, search, _page + 1);
      if (id != _req) return;
      final have = items.map((a) => a.id).toSet();
      items.addAll(r.items.where((a) => !have.contains(a.id)));
      hasNext = r.hasNext;
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

  void setStatus(String s) {
    if (s == status) return;
    status = s;
    items.clear();
    load();
  }

  void setSearch(String q) {
    if (q == search) return;
    search = q;
    load();
  }

  /// Puts the server's version of a row in place, or drops it when its new
  /// status no longer belongs to the open tab.
  void replace(ManagedAccount updated) {
    final i = items.indexWhere((a) => a.id == updated.id);
    if (i < 0) return;
    final merged = updated.withFallback(items[i]);
    if (merged.status.name != status) {
      items.removeAt(i);
    } else {
      items[i] = merged;
    }
    _emit();
  }
}
