class PagedResult<T> {
  final List<T> items;
  final int page;
  final bool hasNextPage;

  const PagedResult({
    required this.items,
    required this.page,
    required this.hasNextPage,
  });
}