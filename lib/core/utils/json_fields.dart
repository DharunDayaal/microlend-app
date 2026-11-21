/// Lenient readers for JSON fields that may be missing, null, or the wrong
/// type (numbers sent as strings and so on).
library;

double? jNum(dynamic v) => v == null ? null : num.tryParse('$v')?.toDouble();
double jDbl(dynamic v, [double fallback = 0]) => jNum(v) ?? fallback;
int jInt(dynamic v) => (jNum(v) ?? 0).round();
String jStr(dynamic v) => v == null ? '' : '$v';
Map<String, dynamic> jMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
List<Map<String, dynamic>> jMaps(dynamic v) => v is List
    ? [
        for (final e in v)
          if (e is Map) Map<String, dynamic>.from(e),
      ]
    : const [];
