import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';

class ResponseParser {
  ResponseParser._();

  static dynamic _data(dynamic res) => res is Map ? res['data'] : null;

  /// data = {...} or data = { [key]: {...} }
  static Map<String, dynamic> object(dynamic res, String key) {
    var d = _data(res);
    if (d is Map && d[key] is Map) d = d[key];
    if (d is Map) return Map<String, dynamic>.from(d);
    throw const ApiException(
      message: 'Unexpected response from server',
      code: 'BAD_RESPONSE',
    );
  }

  /// data = [...] or data = { [key]: [...] }
  static List<Map<String, dynamic>> list(dynamic res, String key) {
    var d = _data(res);
    if (d is Map && d[key] is List) d = d[key];
    if (d is! List) return [];
    return d.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static bool hasNextPage(dynamic res) {
    final data = res is Map ? res['data'] : null;
    final meta = data is Map ? data['metadata'] : null;
    return meta is Map && meta['has_next_page'] == true;
  }

  /// A full response body `{ data: { [key]: [...], metadata } }` as a page.
  static PagedResult<T> paged<T>(
    dynamic res,
    String key,
    T Function(Map<String, dynamic>) make, {
    required int page,
  }) => pagedData(_data(res), key, make, page: page);

  /// The same from the `data` map itself (what the analytics gateway and
  /// `unwrapBody` hand back). `current_page` wins over the requested page.
  static PagedResult<T> pagedData<T>(
    dynamic data,
    String key,
    T Function(Map<String, dynamic>) make, {
    required int page,
  }) {
    final list = data is Map ? data[key] : null;
    final meta = data is Map ? data['metadata'] : null;
    final current = meta is Map ? meta['current_page'] : null;
    return PagedResult(
      items: [
        if (list is List)
          for (final e in list)
            if (e is Map) make(Map<String, dynamic>.from(e)),
      ],
      page: current is int ? current : page,
      hasNextPage: meta is Map && meta['has_next_page'] == true,
    );
  }
}
