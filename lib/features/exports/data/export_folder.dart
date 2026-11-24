import 'dart:io';

/// Where downloaded exports are kept: `Lending Docs/<yyyy-MM-dd>/<file>`,
/// one folder per day, inside the phone's Download folder (Android) or the
/// app's Documents folder, which the Files app shows (iOS).
abstract final class ExportFolder {
  static const rootName = 'Lending Docs';

  /// `2026-11-24`: sorts by date in any file manager.
  static String dayName(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// `Lending Docs/2026-11-24`, for messages.
  static String relativeDay(DateTime d) => '$rootName/${dayName(d)}';

  static String dayPath(String base, DateTime d) =>
      '$base/$rootName/${dayName(d)}';

  /// Keeps letters, digits, `.`, `_` and `-`, so the name is valid on
  /// every file system.
  static String safeName(String name) {
    final s = name.trim().replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return s.isEmpty || s.startsWith('.') ? 'export$s' : s;
  }

  /// [name] in [dir], or `name (1).ext`, `name (2).ext`... when that file
  /// already exists, so a second download never overwrites the first.
  static String uniquePath(String dir, String name) {
    final dot = name.lastIndexOf('.');
    final stem = dot > 0 ? name.substring(0, dot) : name;
    final ext = dot > 0 ? name.substring(dot) : '';
    var candidate = '$dir/$name';
    for (var n = 1; File(candidate).existsSync(); n++) {
      candidate = '$dir/$stem ($n)$ext';
    }
    return candidate;
  }
}
