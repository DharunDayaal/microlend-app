import 'package:micro_lending_app/utils/network/api_exception.dart';

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
}
