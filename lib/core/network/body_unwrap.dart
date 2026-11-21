/// Accepts { success, message, ...fields } and { success, message, data: {...fields} }.
Map<String, dynamic> unwrapBody(dynamic res) {
  if (res is! Map) return <String, dynamic>{};
  final body = Map<String, dynamic>.from(res);
  final inner = body['data'];
  return inner is Map ? {...body, ...Map<String, dynamic>.from(inner)} : body;
}
