/// One page of a list endpoint. Every paginated API is read into this.
///
/// The server sends `data: { list_key: [...], metadata: { current_page,
/// limit, has_next_page } }`; `ResponseParser.paged` builds it from that.
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

/// Largest `limit` the list endpoints accept.
const kMaxPageLimit = 100;

/// Loads page after page while `has_next_page` is true, for screens that need
/// the whole list (cycle numbers, pickers, counts). [maxPages] guards against
/// a server that never says "no more".
Future<List<T>> fetchAllPages<T>(
  Future<PagedResult<T>> Function(int page) load, {
  int maxPages = 50,
}) async {
  final all = <T>[];
  for (var page = 1; page <= maxPages; page++) {
    final r = await load(page);
    all.addAll(r.items);
    if (!r.hasNextPage || r.items.isEmpty) break;
  }
  return all;
}
