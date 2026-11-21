import 'package:flutter/foundation.dart';

/// State of an infinite-scroll list: first page, more pages, and errors.
@immutable
class PagedState<T> {
  final List<T> items;

  /// First page in flight with a skeleton showing.
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final int page;

  /// First-page failure: the screen shows an error view instead of the list.
  final String? error;

  /// Next-page failure: the list stays, the footer offers a retry.
  final String? loadMoreError;

  /// Bumped on every successful first-page load, so screens can react
  /// (scroll checks, header resets) without comparing lists.
  final int generation;

  const PagedState({
    this.items = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasNext = false,
    this.page = 1,
    this.error,
    this.loadMoreError,
    this.generation = 0,
  });

  static const _keep = Object();

  PagedState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasNext,
    int? page,
    Object? error = _keep,
    Object? loadMoreError = _keep,
    int? generation,
  }) => PagedState<T>(
    items: items ?? this.items,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasNext: hasNext ?? this.hasNext,
    page: page ?? this.page,
    error: identical(error, _keep) ? this.error : error as String?,
    loadMoreError: identical(loadMoreError, _keep)
        ? this.loadMoreError
        : loadMoreError as String?,
    generation: generation ?? this.generation,
  );
}
