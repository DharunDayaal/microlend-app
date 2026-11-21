import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/logging/app_logger.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/l10n/locale_controller.dart';
import 'package:micro_lending_app/shared/pagination/paged_state.dart';

/// Shared paging logic: first page, next page, retry, and ignoring responses
/// from requests that a newer refresh has replaced.
///
/// Subclasses implement [fetchPage] and [idOf]. By default the first page
/// starts loading as soon as the provider is first read ([autoLoad]).
abstract class PagedNotifier<T> extends Notifier<PagedState<T>> {
  int get pageSize => 20;

  /// Load page 1 as soon as the provider is first read. Turn off when the
  /// screen must supply filters first, then call [refresh] itself.
  bool get autoLoad => true;

  Future<PagedResult<T>> fetchPage(int page, int limit);

  /// Used to drop duplicates when pages overlap.
  Object idOf(T item);

  /// Called with every page that is kept (not stale), before it is shown.
  /// Override to pick up extra data a page carries, such as totals.
  void onPageAccepted(PagedResult<T> page) {}

  /// Bumped on every first-page load. Older responses are ignored.
  int _requestId = 0;

  /// True while page 1 reloads, even silently: no next page meanwhile.
  bool _refreshing = false;

  @override
  PagedState<T> build() {
    _requestId = 0;
    _refreshing = false;
    if (autoLoad) Future.microtask(refresh);
    return PagedState<T>();
  }

  /// Message for failures that are not API errors (bugs, bad data). They are
  /// logged; the user sees a generic, translated message.
  String _unexpected(Object e, StackTrace st) {
    AppLogger.error(
      'Paged list failed',
      tag: runtimeType.toString(),
      error: e,
      stack: st,
    );
    return lookupAppLocalizations(ref.read(localeProvider))
        .commonSomethingWrong;
  }

  /// Loads page 1 again. [showSkeleton] is false for pull-to-refresh.
  Future<void> refresh({bool showSkeleton = true}) async {
    final id = ++_requestId;
    _refreshing = true;
    state = state.copyWith(
      isLoading: showSkeleton ? true : null,
      error: null,
      loadMoreError: null,
      isLoadingMore: false,
    );

    try {
      final r = await fetchPage(1, pageSize);
      if (!ref.mounted || id != _requestId) return;
      onPageAccepted(r);
      state = state.copyWith(
        items: List.unmodifiable(r.items),
        page: 1,
        hasNext: r.hasNextPage,
        isLoading: false,
        generation: state.generation + 1,
      );
    } on ApiException catch (e) {
      if (!ref.mounted || id != _requestId) return;
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e, st) {
      if (!ref.mounted || id != _requestId) return;
      state = state.copyWith(error: _unexpected(e, st), isLoading: false);
    } finally {
      if (ref.mounted && id == _requestId) _refreshing = false;
    }
  }

  Future<void> loadMore() async {
    final s = state;
    if (s.isLoading ||
        _refreshing ||
        s.isLoadingMore ||
        !s.hasNext ||
        s.loadMoreError != null) {
      return;
    }

    final id = _requestId;
    state = s.copyWith(isLoadingMore: true);

    try {
      final r = await fetchPage(s.page + 1, pageSize);
      if (!ref.mounted || id != _requestId) return;
      onPageAccepted(r);
      final have = state.items.map(idOf).toSet();
      state = state.copyWith(
        items: List.unmodifiable([
          ...state.items,
          ...r.items.where((x) => !have.contains(idOf(x))),
        ]),
        page: state.page + 1,
        hasNext: r.hasNextPage,
        isLoadingMore: false,
      );
    } on ApiException catch (e) {
      if (!ref.mounted || id != _requestId) return;
      state = state.copyWith(loadMoreError: e.message, isLoadingMore: false);
    } catch (e, st) {
      if (!ref.mounted || id != _requestId) return;
      state = state.copyWith(
        loadMoreError: _unexpected(e, st),
        isLoadingMore: false,
      );
    }
  }

  void retryLoadMore() {
    state = state.copyWith(loadMoreError: null);
    unawaited(loadMore());
  }

  /// Changes the loaded rows in place (after a payment, a status change),
  /// without a reload.
  void editItems(List<T> Function(List<T> items) edit) {
    state = state.copyWith(items: List.unmodifiable(edit(state.items)));
  }
}
